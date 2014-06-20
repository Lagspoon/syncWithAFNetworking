//
//  SYSoundCloudParser.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYParser.h"
#import "SYSyncEngine.h"
#import <CoreData/CoreData.h>

#define objectNumber @"objectNumber"
#define downloadNumber @"downloadNumber"
#define errorNumber @"errorNumber"

@interface SYParser ()

@property (nonatomic, strong) SYSyncEngine *syncEngine;
@property (nonatomic, strong) NSMutableDictionary *objectsDownloadMonitoring;
//objectNumber, downloadNumber, errorNumber
@end

@implementation SYParser

- (SYSyncEngine *) syncEngine {
    if (!_syncEngine) {
        _syncEngine = [SYSyncEngine sharedEngine];
    }
    return _syncEngine;
}

- (NSURL *) filesDirectory {
    NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]];
    NSURL *audioFilesDirectory = [documentsDirectoryPath URLByAppendingPathComponent:@"syncDirectory"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[audioFilesDirectory path]])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:[audioFilesDirectory path] withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder if it doesn't already exist
        if (error) {
            NSLog(@"error in directory creation %@", [error description]);
        }
    }
    return audioFilesDirectory;
}


- (NSMutableDictionary *) objectsDownloadMonitoring {
    if (!_objectsDownloadMonitoring) {
        _objectsDownloadMonitoring = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _objectsDownloadMonitoring;
}

- (void) objectsDownloadMonitoringIncrementKey:(NSString *)key By:(NSUInteger)nb {
    NSInteger value =[[self.objectsDownloadMonitoring valueForKey:key] integerValue];
    value = (value + nb);
    [self.objectsDownloadMonitoring setValue:[NSNumber numberWithInteger:value] forKey:key];
    
}

- (void) objectsDownloadMonitoringIncrementDownloadsBy:(NSUInteger)nb {
    [self objectsDownloadMonitoringIncrementKey:downloadNumber By:nb];
}

- (void) objectsDownloadMonitoringIncrementErrorsBy:(NSUInteger)nb {
    [self objectsDownloadMonitoringIncrementKey:errorNumber By:nb];
}

- (void) objectsDownloadMonitoringIncrementObjectsBy:(NSUInteger)nb {
    [self objectsDownloadMonitoringIncrementKey:objectNumber By:nb];
}

- (BOOL) objectsDownloadMonitoringCompleted {
    if ([[self.objectsDownloadMonitoring valueForKey:objectNumber] integerValue]==([[self.objectsDownloadMonitoring valueForKey:downloadNumber] integerValue]+[[self.objectsDownloadMonitoring valueForKey:errorNumber] integerValue])) {
        return YES;
    } else return NO;
}

- (BOOL) objectsDownloadMonitoringStop {
    if ([self.objectsDownloadMonitoring valueForKey:errorNumber]) {
        return YES;
    } else return NO;
}

- (BOOL) saveObjectsDownloaded {
    BOOL success = NO;
    success = [self saveBackgroundContext];
    [self.syncEngine.delegate managedObjectContextUpdated];
    return success;
}

- (void) resetObjectsDownloaded {
    [self.backgroundManagedObjectContext reset];
}



// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)backgroundManagedObjectContext {
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    if ([self.syncEngine.delegate managedObjectContext]) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext performBlockAndWait:^{
            [_backgroundManagedObjectContext setParentContext:[self.syncEngine.delegate managedObjectContext]];
            //[_backgroundManagedObjectContext setPersistentStoreCoordinator: self.persistentStoreCoordinator];
            
        }];
    }
    
    return _backgroundManagedObjectContext;
}


- (BOOL) saveBackgroundContext {
    __block BOOL success = YES;
    [self.backgroundManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if(![self.backgroundManagedObjectContext save:&error]) {
            success = NO;
            NSLog(@"Could not save master context due to %@", error);
        } else {
            if (![[self.syncEngine.delegate managedObjectContext] save:&error]) {
                NSLog(@"Cannot save managedObjectContext");
                success = NO;
            }
        }
    }];
    return success;
}
@end
