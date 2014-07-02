//
//  SYSoundCloudSyncEngine.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SYSyncEngine.h"
#import "SYSoundCloudHTTPClient.h"

@protocol soundCloudSyncEngineDelegate

//-(void) mappingManagedObject:(NSManagedObject *)managedObject audio:(NSData *)audio name:(NSString *)name createdAt:(NSDate *)createdAt ;

@end

@interface SYSoundCloudSyncEngine : SYSyncEngine

+ (SYSoundCloudSyncEngine *) sharedEngine;
- (void) downloadTracksFromPlaylist:(NSString *) playListID;
@property (weak, nonatomic) id <soundCloudSyncEngineDelegate> soundcloudDelegate;


@end
