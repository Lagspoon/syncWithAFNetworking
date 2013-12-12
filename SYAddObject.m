//
//  SYAddObject.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 22/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYAddObject.h"
#import "SYSyncEngine.h"
#import "SYCoreDataStackWithSyncStuff.h"
#import <CoreData/CoreData.h>

@interface SYAddObject ()
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;
@end

@implementation SYAddObject


///////////////////////////////////////////////////////////////////
//LAZY instantiation
#pragma mark - class instantiation
///////////////////////////////////////////////////////////////////
- (NSManagedObjectContext *) backgroundManagedObjectContext {
    if (!_backgroundManagedObjectContext) _backgroundManagedObjectContext=[[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext];
    return _backgroundManagedObjectContext;
}

#warning FOR DEMONSTRATION PURPOSE ONLY
//New object to add
- (void)saveButtonTouched {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Drink" inManagedObjectContext:self.backgroundManagedObjectContext];
    [newManagedObject setValue:@"Push Record locally2record" forKey:@"name"];
    [newManagedObject setValue:[NSNumber numberWithInt:SDObjectCreated] forKey:@"syncStatus"];

    [self.backgroundManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.backgroundManagedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Could not save background context due to %@", error);
        }
    }];
#warning THE SYNC MUST NOT BE CALL EACH TIME, PAY ATTENTION OF THE LOADING
    [[SYSyncEngine sharedEngine] startSync];

}

@end
