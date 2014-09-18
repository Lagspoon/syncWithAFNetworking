//
//  SYSoundCloudParser.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYParser.h"

#define objectNumber @"objectNumber"
#define downloadNumber @"downloadNumber"
#define errorNumber @"errorNumber"

@interface SYParser ()

@property (nonatomic, strong) NSMutableDictionary *objectsDownloadMonitoring;
@end

@implementation SYParser

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

- (void) objectsDownloadMonitoringReset {
    [self.objectsDownloadMonitoring removeAllObjects];
}


@end
