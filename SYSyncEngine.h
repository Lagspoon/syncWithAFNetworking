//
//  SYSyncEngine.h
//  makeMyMouthWater
//
//  Created by Olivier Delecueillerie on 13/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYSyncEngine : NSObject

+ (SYSyncEngine *)sharedEngine;

- (void) registerNSManagedObjectClassToSync:(Class)aClass;
- (void) startSync;
//Parse.com date format is just a teeny bit different than NSDate —this small function make the necessary changes to date strings
- (NSString *)dateStringForAPIUsingDate:(NSDate *)date;

@property (atomic, readonly) BOOL syncInProgress;

typedef enum {
    SDObjectSynced = 0,
    SDObjectCreated,
    SDObjectDeleted,
} SDObjectSyncStatus;

@end
