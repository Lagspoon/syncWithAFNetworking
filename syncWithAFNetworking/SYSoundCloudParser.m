//
//  SYSoundCloudParser.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSoundCloudParser.h"
#import <CoreData/CoreData.h>

@interface SYSoundCloudParser ()

@end

@implementation SYSoundCloudParser


-(NSArray *) trackDictionaryFromResponseObject:(NSDictionary *) responseObject {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSArray *arrayOfTracks;
    arrayOfTracks = [responseObject valueForKey:@"tracks"];
    for (NSDictionary * initialTrackDictionary in arrayOfTracks) {
        NSDictionary *trackDictionary = @{objectDictionaryKeyDownloadURL: [initialTrackDictionary valueForKey:@"download_url"],
                                          objectDictionaryKeyTitle:[initialTrackDictionary valueForKey:@"title"],
                                          objectDictionaryKeyCreatedAt :[initialTrackDictionary valueForKey:@"created_at"]};
                                          
        [mutableArray addObject:trackDictionary];
        [self trackDictionaryToManagedObject:trackDictionary];
    }
    NSLog(@"tracksURL %@", [mutableArray description]);
    
    return (NSArray *)mutableArray;

}

- (void) trackDictionaryToManagedObject:(NSDictionary *)trackDictionary {
    
}

@end
