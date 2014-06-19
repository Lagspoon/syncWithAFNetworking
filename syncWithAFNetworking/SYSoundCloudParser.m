//
//  SYSoundCloudParser.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSoundCloudParser.h"
#import <CoreData/CoreData.h>
#import "Soundcloud.h"

@implementation SYSoundCloudParser


-(NSArray *) objectDictionaryFromResponseObject:(NSDictionary *) responseObject {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSArray *arrayOfTracks;
    arrayOfTracks = [responseObject valueForKey:@"tracks"];
    for (NSDictionary * initialTrackDictionary in arrayOfTracks) {
        NSDictionary *trackDictionary = @{@"URL": [initialTrackDictionary valueForKey:@"download_url"],
                                          @"title":[initialTrackDictionary valueForKey:@"title"],
                                          @"createdAt" :[initialTrackDictionary valueForKey:@"created_at"]};
                                          
        [mutableArray addObject:trackDictionary];
    }
    NSLog(@"tracksURL %@", [mutableArray description]);
    
    return (NSArray *)mutableArray;

}


- (void) newManagedObjectFromObjectDictionary:(NSDictionary *)objectDictionary {

    NSURL *file = [objectDictionary valueForKey:@"file"];
    NSString *title = [objectDictionary valueForKey:@"title"];
    NSData *dataFromAudio = [[NSData alloc] initWithContentsOfURL:file];
    
    Soundcloud *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Soundcloud" inManagedObjectContext:self.delegateCoreData.backgroundManagedObjectContext];
    newManagedObject.name = title;
    newManagedObject.audio = dataFromAudio;
    
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
