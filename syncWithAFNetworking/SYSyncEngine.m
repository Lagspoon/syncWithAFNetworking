//
//  SYSyncEngine.m
//  makeMyMouthWater
//
//  Created by Olivier Delecueillerie on 13/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYSyncEngine.h"
#import <CoreData/CoreData.h>
#import "SYCoreDataStackWithSyncStuff.h"

#import "AFHTTPRequestOperation.h"

#import "SYHTTPClient.h"
#import "SYSyncDataManagement.h"



NSString * const SYInitialSyncCompleted = @"SYInitialSyncCompleted";
NSString * const SYSyncCompleted = @"SYSyncCompleted";

@interface SYSyncEngine()

//this array contains all the entity to sync and the webservice it is linked with. Couple Entity/Webservice is made by a NSDictionary with keys (className, webService)
@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;
@property (nonatomic, strong) SYSyncDataManagement *dataManagement; //used to transform data receive from webservice

@end


@implementation SYSyncEngine

///////////////////////////////////////////////////////////////////
//LAZY instantiation
#pragma mark - LAZY instantiation
///////////////////////////////////////////////////////////////////
- (NSManagedObjectContext *) backgroundManagedObjectContext {
    if (!_backgroundManagedObjectContext) _backgroundManagedObjectContext=[[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext];
        return _backgroundManagedObjectContext;
}

- (NSMutableArray *) registeredClassesToSync {
    if (!_registeredClassesToSync) _registeredClassesToSync=[[NSMutableArray alloc]init];
    return _registeredClassesToSync;
}


- (SYSyncDataManagement *) dataManagement {
    if (!_dataManagement) _dataManagement = [[SYSyncDataManagement alloc]init];
    return _dataManagement;
}
///////////////////////////////////////////////////////////////////
//Instanciation of the class
#pragma mark - class instantiation
///////////////////////////////////////////////////////////////////

+ (SYSyncEngine *)sharedEngine {
    static SYSyncEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[SYSyncEngine alloc] init];
    });
    return sharedEngine;
}



////////////////////////////////////////////////////
//SYNC MANAGEMENT
#pragma mark - SYNC MANAGEMENT
////////////////////////////////////////////////////
//This is the method that start the sync process
//Only one Sync at once with the help of the syncInProgress flag
- (void) startSync {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadDataForRegisteredObjects:YES toDeleteLocalRecords:YES];
        });
    }
}

- (BOOL)initialSyncComplete {
    //return [[[NSUserDefaults standardUserDefaults] valueForKey:SYInitialSyncCompleted] boolValue];
#warning to correct
    return NO;
}

- (void)setInitialSyncCompleted {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:SYInitialSyncCompleted];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//When sync operations are completed we call this method to save object contaxt, send a notification and change the flag syncInProgress
- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        
        [self.backgroundManagedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            BOOL saved = [self.backgroundManagedObjectContext save:&error];
            if (!saved) {
                // do some real error handling
                NSLog(@"Could not save background context due to %@", error);
            }
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SYSyncCompleted object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}


////////////////////////////////////////////////////
//DATA TO SYNC
#pragma mark - DATA 2 SYNC
////////////////////////////////////////////////////

//this method is called when app starting
- (void) registerNSManagedObjectClassToSync:(Class)aClass withWebService:(webservice) webservice {

    if ([aClass isSubclassOfClass:[NSManagedObject class]]){
        NSNumber *webserviceNumber = [NSNumber numberWithInt:webservice];
        NSDictionary *dictionary =@{@"className": NSStringFromClass(aClass), @"webservice":webserviceNumber};
        if (![self.registeredClassesToSync containsObject:dictionary]) {
            [self.registeredClassesToSync addObject:dictionary];
        }
    } else NSLog(@"In registerNSManagedObjectClassToSync method, class or webservice are not correct object");
}


- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName {
    __block NSDate *date = nil;

    // Create a new fetch request for the specified entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // Set the sort descriptors on the request to sort by updatedAt in descending order
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    //
    // You are only interested in 1 result so limit the request to 1
    [request setFetchLimit:1];
    [[[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        NSArray *results = [[[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext] executeFetchRequest:request error:&error];
        if ([results lastObject])   {
            //
            // Set date to the fetched result
            //
            date = [[results lastObject] valueForKey:@"updatedAt"];
        }
    }];
    
    return date;
}


//this is the first method of the sync process : we download JSON record from webservices for object that are registered
- (void)downloadDataForRegisteredObjects:(BOOL)useUpdatedAtDate toDeleteLocalRecords:(BOOL)toDelete {
    webservice webservice;

    for (NSDictionary *Class2Sync in self.registeredClassesToSync)
    {
        NSString *className = [Class2Sync valueForKey:@"className"];
        webservice = [[Class2Sync valueForKey:@"webservice"] integerValue];

        NSDate *mostRecentUpdatedDate;
        if (useUpdatedAtDate)
        {
            mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:className];
        }


        dispatch_queue_t SyncQueue = dispatch_queue_create("sync", NULL);
        dispatch_async(SyncQueue, ^{

            SYHTTPClient *httpClient = [SYHTTPClient sharedClientFor:webservice];
            [httpClient downloadDataForClass:className withWebService:webservice updatedAfterDate: mostRecentUpdatedDate];
            // Process JSON records into Core Data
            [self.dataManagement processJSONDataRecordsIntoCoreData:webservice initialSyncComplete:[self initialSyncComplete] registeredClassesToSync:self.registeredClassesToSync];
            if (toDelete) {
                [self.dataManagement processJSONDataRecordsForDeletion:webservice registeredClassesToSync:self.registeredClassesToSync];
            }
            [self executeSyncCompletedOperations];

        });
    }
}






@end
