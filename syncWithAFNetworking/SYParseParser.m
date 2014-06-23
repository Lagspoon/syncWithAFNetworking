//
//  SYParseParser.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYParseParser.h"
#import "SYParseSyncEngine.h"
#import <CoreData/CoreData.h>

@interface SYParseParser ()
@property (nonatomic, strong) SYParseSyncEngine *syncEngine;

@end

@implementation SYParseParser

- (SYParseSyncEngine *) syncEngine {
    if (!_syncEngine) {
        _syncEngine = [SYParseSyncEngine sharedEngine];
    }
    return _syncEngine;
}

-(NSArray *) objectDictionaryFromResponseObject:(NSDictionary *) responseObject {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSArray *arrayOfObjects;
    arrayOfObjects = [responseObject valueForKey:@"results"];
    for (NSDictionary * object in arrayOfObjects) {
        NSDictionary *objectDictionary = @{ objectDictionaryKeyGrapheme :[object valueForKey:@"grapheme"],
                                           objectDictionaryKeyPhonemeAPI:[object valueForKey:@"phoneme"],
                                           objectDictionaryKeyCreatedAt :[object valueForKey:@"createdAt"],
                                           objectDictionaryKeyCreatedAt :[object valueForKey:@"createdAt"]
                                           };
                                          
        [mutableArray addObject:objectDictionary];
    }
    NSLog(@"objectDictionary %@", [mutableArray description]);
    
    return (NSArray *)mutableArray;

}


- (void) newManagedObjectFromObjectDictionary:(NSDictionary *)objectDictionary {

    
    NSURL *phonemeAPI = [objectDictionary valueForKey:objectDictionaryKeyPhonemeAPI];
    NSString *grapheme = [objectDictionary valueForKey:objectDictionaryKeyGrapheme];
    NSArray *words = [objectDictionary valueForKey:objectDictionaryKeyWordArray];

    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[[SYParseSyncEngine sharedEngine].delegate entityName] inManagedObjectContext:self.backgroundManagedObjectContext];

    //[[SYParseSyncEngine sharedEngine].delegate mappingManagedObject:newManagedObject audio:dataFromAudio name:title createdAt:nil];
    
    //remove file
    NSError *error;
//    [[NSFileManager defaultManager] removeItemAtURL:file error:&error];
    if (error) {
  //      [self objectsDownloadMonitoringIncrementErrorsBy:1];
  //      NSLog(@"error in removing file%@", file);
    } else {
        [self objectsDownloadMonitoringIncrementDownloadsBy:1];
    }
/*
    if ([self objectsDownloadMonitoringCompleted]) {
        if ([self objectsDownloadMonitoringStop]) {
            [self resetObjectsDownloaded];
        } else {
            [self saveObjectsDownloaded];
            NSLog(@"save MOC");
        }
    }
 */
}



@end
