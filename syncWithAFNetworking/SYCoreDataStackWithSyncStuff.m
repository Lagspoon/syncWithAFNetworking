//
//  SYCoreDataStackWithSyncStuff.m
//  makeMyMouthWater
//
//  Created by Olivier Delecueillerie on 13/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYCoreDataStackWithSyncStuff.h"

@interface SYCoreDataStackWithSyncStuff()
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
    
    NSManagedObjectContext *masterContext = self.managedObjectContext;
    if (masterContext != nil) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext performBlockAndWait:^{
            //[_backgroundManagedObjectContext setParentContext:masterContext];
            [_backgroundManagedObjectContext setPersistentStoreCoordinator: self.persistentStoreCoordinator];

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
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Cannot save managedObjectContext");
                    success = NO;
                }
            }
        }];
    return success;
}
@end
