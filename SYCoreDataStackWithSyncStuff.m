//
//  SYCoreDataStackWithSyncStuff.m
//  makeMyMouthWater
//
//  Created by Olivier Delecueillerie on 13/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYCoreDataStackWithSyncStuff.h"
#import <CoreData/CoreData.h>
@interface SYCoreDataStackWithSyncStuff()
@property (strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;
@end


@implementation SYCoreDataStackWithSyncStuff


+ (id)sharedInstance {
    static dispatch_once_t once;
    static SYCoreDataStackWithSyncStuff *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)backgroundManagedObjectContext {
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    if (self.managedObjectContext != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext performBlockAndWait:^{
            [_backgroundManagedObjectContext setParentContext:self.managedObjectContext];
            //[_backgroundManagedObjectContext setPersistentStoreCoordinator: self.persistentStoreCoordinator];

        }];
    }
    
    return _backgroundManagedObjectContext;
}




- (void) saveBackgroundContext {
        [self.backgroundManagedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            //!!!!!!!!!!!!!!!!!!!
            if (![self.backgroundManagedObjectContext save:&error]) {
                // do some real error handling
                NSLog(@"Could not save master context due to %@", error);
            }
            if (![self.managedObjectContext save:&error]) {
                // do some real error handling
                NSLog(@"Could not save master context due to %@", error);
            }
        }];
}
@end
