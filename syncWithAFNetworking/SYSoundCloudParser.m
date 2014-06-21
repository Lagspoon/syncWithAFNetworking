//
//  SYSoundCloudParser.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSoundCloudParser.h"
#import "SYSoundCloudSyncEngine.h"
#import <CoreData/CoreData.h>

@interface SYSoundCloudParser ()
@property (nonatomic, strong) SYSoundCloudSyncEngine *syncEngine;

@end

@implementation SYSoundCloudParser

- (SYSoundCloudSyncEngine *) syncEngine {
    if (!_syncEngine) {
        _syncEngine = [SYSoundCloudSyncEngine sharedEngine];
    }
    return _syncEngine;
}

-(NSArray *) objectDictionaryFromResponseObject:(NSDictionary *) responseObject {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSArray *arrayOfTracks;
    arrayOfTracks = [responseObject valueForKey:@"tracks"];
    for (NSDictionary * initialTrackDictionary in arrayOfTracks) {
        NSDictionary *trackDictionary = @{objectDictionaryKeyDownloadURL: [initialTrackDictionary valueForKey:@"download_url"],
                                          objectDictionaryKeyTitle:[initialTrackDictionary valueForKey:@"title"],
                                          objectDictionaryKeyCreatedAt :[initialTrackDictionary valueForKey:@"created_at"]};
                                          
        [mutableArray addObject:trackDictionary];
    }
    NSLog(@"tracksURL %@", [mutableArray description]);
    
    return (NSArray *)mutableArray;

}


- (void) newManagedObjectFromObjectDictionary:(NSDictionary *)objectDictionary {

    NSURL *file = [objectDictionary valueForKey:objectDictionaryKeyFileURL];
    NSString *title = [objectDictionary valueForKey:objectDictionaryKeyTitle];
    NSData *dataFromAudio = [[NSData alloc] initWithContentsOfURL:file];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[[SYSoundCloudSyncEngine sharedEngine].delegate entityName] inManagedObjectContext:self.backgroundManagedObjectContext];

    [[SYSoundCloudSyncEngine sharedEngine].delegate mappingManagedObject:newManagedObject audio:dataFromAudio name:title createdAt:nil];
    
    //remove file
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:file error:&error];
    if (error) {
        [self objectsDownloadMonitoringIncrementErrorsBy:1];
        NSLog(@"error in removing file%@", file);
    } else {
        [self objectsDownloadMonitoringIncrementDownloadsBy:1];
    }
    
    if ([self objectsDownloadMonitoringCompleted]) {
        if ([self objectsDownloadMonitoringStop]) {
            [self resetObjectsDownloaded];
        } else {
            [self saveObjectsDownloaded];
            NSLog(@"save MOC");
        }
    }
}



@end
