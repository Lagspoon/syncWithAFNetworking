//
//  SYSyncDataManagement.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 06/01/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSyncDataManagement.h"
#import "SYSyncFileManagement.h"
#import "SYCoreDataStackWithSyncStuff.h"
#import "NSManagedObject+JSON.h"
#import "SYSyncForParse.h" //specific data modification for Parse REST API
#import "AFHTTPRequestOperation.h"
#import "SYHTTPClient.h"

@interface SYSyncDataManagement()

@property (nonatomic, strong) SYSyncFileManagement *fileManagement; //used to deal with file manipulation
@property (nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;

@end

@implementation SYSyncDataManagement

///////////////////////////////////////////////////////////////////
//LAZY instantiation
#pragma mark - LAZY instantiation
///////////////////////////////////////////////////////////////////
- (NSManagedObjectContext *) backgroundManagedObjectContext {
    if (!_backgroundManagedObjectContext) _backgroundManagedObjectContext=[[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext];
    return _backgroundManagedObjectContext;
}

////////////////////////////////////////////////////
//BASIC TOOLS
#pragma mark - BASIC TOOLS
////////////////////////////////////////////////////

//return the result of a get request, JSON format,  of a specified class
- (NSDictionary *)JSONDictionaryForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self.fileManagement JSONDataRecordsDirectory]];
    return [NSDictionary dictionaryWithContentsOfURL:fileURL];
}

//return the array of dictionary sorted by key
- (NSArray *)JSONDataRecordsForClass:(NSString *)className sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];
    NSArray *records = [JSONDictionary objectForKey:@"results"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}

//delete the JSON file
- (void)deleteJSONDataRecordsForClassWithName:(NSString *)className {
    NSURL *url = [NSURL URLWithString:className relativeToURL:[self.fileManagement JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        NSLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

//Create a new record in COre Data
- (void)newManagedObjectWithClassName:(NSString *)className forRecord:(NSDictionary *)record fromWebService:(webservice)webservice {
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:self.backgroundManagedObjectContext];
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        switch (webservice) {
            case parse:
                [[[SYSyncForParse alloc]init] setValue:obj forKey:key forManagedObject:newManagedObject];
                break;
            case flickr:
#warning complete with flickr specific
                break;
            default:
                break;
        }
    }];
    [record setValue:[NSNumber numberWithInt:SDObjectSynced] forKey:@"syncStatus"];
}

//Update a record in Core Data
- (void)updateManagedObject:(NSManagedObject *)managedObject withRecord:(NSDictionary *)record fromWebservice:(webservice)webservice {
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        switch (webservice) {
            case parse:
                [[[SYSyncForParse alloc]init] setValue:obj forKey:key forManagedObject:managedObject];
                break;
            case flickr:
#warning complete with flickr specific
                break;
            default:
                break;
        }
    }];
    [record setValue:[NSNumber numberWithInt:SDObjectSynced] forKey:@"syncStatus"];

}

//get object from a class with a specific syncstatus
- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(SDObjectSyncStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncStatus = %d", syncStatus];
    [fetchRequest setPredicate:predicate];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];

    return results;
}

//get object from a class that there ID are (or not : argument choice ) in a array of Ids
- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate;
    if (inIds) {
        predicate = [NSPredicate predicateWithFormat:@"objectId IN %@", idArray];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"NOT (objectId IN %@)", idArray];
    }

    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];

    return results;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 1/4 IMPORT OBJECT ON LOCAL
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)processJSONDataRecordsIntoCoreData:(webservice)webservice initialSyncComplete:(BOOL)initialSyncComplete registeredClassesToSync:(NSArray *)registeredClassesToSync {
    NSManagedObjectContext *managedObjectContext = self.backgroundManagedObjectContext;
    //
    // Iterate over all registered classes to sync
    //
    for (NSDictionary *dicionary in registeredClassesToSync) {
        NSString *className = [dicionary valueForKey:@"className"];
        if (!initialSyncComplete) { // import all downloaded data to Core Data for initial sync
            //
            // If this is the initial sync then the logic is pretty simple, you will fetch the JSON data from disk
            // for the class of the current iteration and create new NSManagedObjects for each record
            //
            NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];

            switch (webservice) {
                case parse:
                {
                    NSArray *records = [JSONDictionary objectForKey:@"results"];
                    for (NSDictionary *record in records) {
                        [self newManagedObjectWithClassName:className forRecord:record fromWebService:webservice];
                    }
                }
                    break;

                case flickr:
                {
                    NSArray *records = [[JSONDictionary objectForKey:@"photoset"] objectForKey:@"photo"];
                    NSMutableArray * operations = [[NSMutableArray alloc]init];
                    for (NSDictionary *record in records) {
                        NSMutableURLRequest *request =[[SYHTTPClient sharedClientFor:flickr] flickrGETPhotoWithFarmId:[record valueForKey:@"farm"] serverId:[record valueForKey:@"server"] photoId:[record valueForKey:@"id"] secret:[record valueForKey:@"secret"] size:@"o"];
                        AFHTTPRequestOperation *operation = [[SYHTTPClient sharedClientFor:flickr].requestOpManager HTTPRequestOperationWithRequest:request
                                                                                                                                            success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                             {
                                                                 NSDictionary * recordThatMatchDataModel = @{@"image": responseObject , };

                                                                 [self newManagedObjectWithClassName:className forRecord:recordThatMatchDataModel fromWebService:flickr];


                                                             }
                                                                                                                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                                             {
                                                                 NSLog(@"%@",operation.responseString);
                                                                 NSLog(@"Request for class %@ failed with error: %@", className, error);
                                                             }];
                        [operations addObject:operation];
                    }

                    NSArray * batchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations
                                                                                     progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
                                                 {
                                                     NSLog(@"%d of %d complete", numberOfFinishedOperations, totalNumberOfOperations);
                                                 }
                                                                                   completionBlock:^(NSArray *operations)
                                                 {
                                                     NSLog(@"All operations in batch complete");
                                                 }];

                    [[NSOperationQueue mainQueue] addOperations:batchOperations waitUntilFinished:NO];
                }

                default:
                    break;
            }

        }
        else {
            //
            // Otherwise you need to do some more logic to determine if the record is new or has been updated.
            // First get the downloaded records from the JSON response, verify there is at least one object in
            // the data, and then fetch all records stored in Core Data whose objectId matches those from the JSON response.
            //
            NSArray *downloadedRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
            if ([downloadedRecords lastObject]) {
                //
                // Now you have a set of objects from the remote service and all of the matching objects
                // (based on objectId) from your Core Data store. Iterate over all of the downloaded records
                // from the remote service.
                //
                NSArray *storedRecords = [self managedObjectsForClass:className sortedByKey:@"objectId" usingArrayOfIds:[downloadedRecords valueForKey:@"objectId"] inArrayOfIds:YES];
                int currentIndex = 0;
                //
                // If the number of records in your Core Data store is less than the currentIndex, you know that
                // you have a potential match between the downloaded records and stored records because you sorted
                // both lists by objectId, this means that an update has come in from the remote service
                //
                for (NSDictionary *record in downloadedRecords) {
                    NSManagedObject *storedManagedObject = nil;

                    // Make sure we don't access an index that is out of bounds as we are iterating over both collections together
                    if ([storedRecords count] > currentIndex) {
                        storedManagedObject = [storedRecords objectAtIndex:currentIndex];
                    }

                    if ([[storedManagedObject valueForKey:@"objectId"] isEqualToString:[record valueForKey:@"objectId"]]) {
                        //
                        // Do a quick spot check to validate the objectIds in fact do match, if they do update the stored
                        // object with the values received from the remote service
                        //
                        [self updateManagedObject:[storedRecords objectAtIndex:currentIndex] withRecord:record fromWebservice:webservice];
                    } else {
                        //
                        // Otherwise you have a new object coming in from your remote service so create a new
                        // NSManagedObject to represent this remote object locally
                        //
                        [self newManagedObjectWithClassName:className forRecord:record fromWebService:webservice];
                    }
                    currentIndex++;
                }
            }
        }
        //
        // Once all NSManagedObjects are created in your context you can save the context to persist the objects
        // to your persistent store. In this case though you used an NSManagedObjectContext who has a parent context
        // so all changes will be pushed to the parent context
        //
        [managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"Unable to save context for class %@", className);
            }
        }];

        //
        // You are now done with the downloaded JSON responses so you can delete them to clean up after yourself,
        // then call your -executeSyncCompletedOperations to save off your master context and set the
        // syncInProgress flag to NO
        //
        [self deleteJSONDataRecordsForClassWithName:className];
    }

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2/4 DELETE OBJECT ON LOCAL
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)processJSONDataRecordsForDeletion:(webservice)webservice registeredClassesToSync:(NSArray *)registeredClassesToSync {
    NSManagedObjectContext *managedObjectContext = [[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext];
    //
    // Iterate over all registered classes to sync
    //
    for (NSString *className in registeredClassesToSync) {
        //
        // Retrieve the JSON response records from disk
        //
        NSArray *JSONRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
        if ([JSONRecords count] > 0) {
            //
            // If there are any records fetch all locally stored records that are NOT in the list of downloaded records
            //
            NSArray *storedRecords = [self
                                      managedObjectsForClass:className
                                      sortedByKey:@"objectId"
                                      usingArrayOfIds:[JSONRecords valueForKey:@"objectId"]
                                      inArrayOfIds:NO];

            //
            // Schedule the NSManagedObject for deletion and save the context
            //
            [managedObjectContext performBlockAndWait:^{
                for (NSManagedObject *managedObject in storedRecords) {
                    [managedObjectContext deleteObject:managedObject];
                }
                NSError *error = nil;
                BOOL saved = [managedObjectContext save:&error];
                if (!saved) {
                    NSLog(@"Unable to save context after deleting records for class %@ because %@", className, error);
                }
            }];
        }

        //
        // Delete all JSON Record response files to clean up after yourself
        //
        [self deleteJSONDataRecordsForClassWithName:className];
    }

    //
    // Execute the sync completion operations as this is now the final step of the sync process
    //

#warning I think that postLocalObjectsToServer could be called
    [self postLocalObjectsToServerForClasses:webservice registeredClassesToSync:registeredClassesToSync];
    [self deleteObjectsOnServerForClasses:webservice registeredClassesToSync:registeredClassesToSync];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 3/4 COPY LOCAL OBJECT ON SERVER
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)postLocalObjectsToServerForClasses:(webservice)webservice registeredClassesToSync:(NSArray *)registeredClassesToSync {
    NSMutableArray *operations = [NSMutableArray array];
    //
    // Iterate over all register classes to sync
    //
    for (NSString *className in registeredClassesToSync) {
        //
        // Fetch all objects from Core Data whose syncStatus is equal to SDObjectCreated
        //
        NSArray *objectsToCreate = [self managedObjectsForClass:className withSyncStatus:SDObjectCreated];
        //
        // Iterate over all fetched objects who syncStatus is equal to SDObjectCreated
        //
        for (NSManagedObject *objectToCreate in objectsToCreate) {
            //
            // Get the JSON representation of the NSManagedObject
            //
            NSDictionary *jsonString = [objectToCreate JSONToCreateObjectOnServer];
            //
            // Create a request using your POST method with the JSON representation of the NSManagedObject
            SYHTTPClient *httpCLient = [SYHTTPClient sharedClientFor:webservice];

            NSMutableURLRequest *request = [httpCLient parsePOSTRequestForClass:className parameters:jsonString];
            AFHTTPRequestOperation *operation = [httpCLient.requestOpManager HTTPRequestOperationWithRequest:request
                                                                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                         //
                                                                                                         // Set the completion block for the operation to update the NSManagedObject with the createdDate from the
                                                                                                         // remote service and objectId, then set the syncStatus to SDObjectSynced so that the sync engine does not
                                                                                                         // attempt to create it again
                                                                                                         //
                                                                                                         NSLog(@"Success creation: %@", responseObject);
                                                                                                         NSDictionary *responseDictionary = responseObject;
                                                                                                         NSDate *createdDate = [[[SYSyncForParse alloc]init] dateUsingStringFromAPI:[responseDictionary valueForKey:@"createdAt"]];
                                                                                                         [objectToCreate setValue:createdDate forKey:@"createdAt"];
                                                                                                         [objectToCreate setValue:[responseDictionary valueForKey:@"objectId"] forKey:@"objectId"];
                                                                                                         [objectToCreate setValue:[NSNumber numberWithInt:SDObjectSynced] forKey:@"syncStatus"];

                                                                                                     }
                                                                                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                         //
                                                                                                         // Log an error if there was one, proper error handling should be done if necessary, in this case it may not
                                                                                                         // be required to do anything as the object will attempt to sync again next time. There could be a possibility
                                                                                                         // that the data was malformed, fields were missing, extra fields were present etc... so it is a good idea to
                                                                                                         // determine the best error handling approach for your production applications.
                                                                                                         //
                                                                                                         NSLog(@"Failed creation: %@", error);
                                                                                                     }];


            //
            // Add all operations to the operations NSArray
            //
            [operations addObject:operation];
        }
    }


    //
    // Pass off operations array to the sharedClient so that they are all executed
    //


    NSArray * batchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
                                 {
                                     //NSLog(@"%d of %d complete", numberOfFinishedOperations, totalNumberOfOperations);
                                 } completionBlock:^(NSArray *operations)
                                 {
                                     // Set the completion block to save the backgroundContext
                                     //
                                     if ([operations count] > 0) {
                                         [[SYCoreDataStackWithSyncStuff sharedInstance] saveBackgroundContext];
                                     }
                                     //
                                     // Invoke executeSyncCompletionOperations as this is now the final step of the sync engine's flow
                                     //
                                     //[self executeSyncCompletedOperations];
                                 }];
    [[NSOperationQueue mainQueue] addOperations:batchOperations waitUntilFinished:NO];
}





////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 4/4 DELETE OBJECT ON SERVER
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)deleteObjectsOnServerForClasses:(webservice)webservice registeredClassesToSync:(NSArray *)registeredClassesToSync {

    NSMutableArray *operations = [NSMutableArray array];

    //
    // Iterate over all registered classes to sync
    //
    for (NSString *className in registeredClassesToSync) {
        //
        // Fetch all records from Core Data whose syncStatus is equal to SDObjectDeleted
        //
        NSArray *objectsToDelete = [self managedObjectsForClass:className withSyncStatus:SDObjectDeleted];
        //
        // Iterate over all fetched records from Core Data
        //
        for (NSManagedObject *objectToDelete in objectsToDelete) {
            //
            // Create a request for each record
            //
            SYHTTPClient *httpCLient = [SYHTTPClient sharedClientFor:webservice];
            NSMutableURLRequest *request = [httpCLient parseDELETERequestForClass:className
                                                                  forObjectWithId:[objectToDelete valueForKey:@"objectId"]];

            AFHTTPRequestOperation *operation = [httpCLient.requestOpManager HTTPRequestOperationWithRequest:request
                                                                                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                                         NSLog(@"Success deletion: %@", responseObject);
                                                                                                         //
                                                                                                         // In the operations completion block delete the NSManagedObject from Core data locally since it has been
                                                                                                         // deleted on the server
                                                                                                         //
                                                                                                         [[[SYCoreDataStackWithSyncStuff sharedInstance] backgroundManagedObjectContext] deleteObject:objectToDelete];
                                                                                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                                         NSLog(@"Failed to delete: %@", error);
                                                                                                     }];

            
            //
            // Add each operation to the operations array
            //
            [operations addObject:operation];
        }
    }
    NSArray * batchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        
    } completionBlock:^(NSArray *operations) {
        if ([operations count] > 0) {
            //
            // Save the background context after all operations have completed
            //
            [[SYCoreDataStackWithSyncStuff sharedInstance] saveBackgroundContext];
        }
        //[self executeSyncCompletedOperations];
    }];
    
    [[NSOperationQueue mainQueue] addOperations:batchOperations waitUntilFinished:NO];
}

@end
