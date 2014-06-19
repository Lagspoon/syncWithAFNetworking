//
//  SYSoundCloudSyncEngine.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYSyncEngine.h"
#import "SYSoundCloudHTTPClient.h"
#import "SYSoundCloudParser.h"

@interface SYSoundCloudSyncEngine : SYSyncEngine <soundCloudParserSyncEngineDelegate>

+ (SYSoundCloudSyncEngine *) sharedEngine;
- (void) downloadTracksFromPlaylist:(NSString *) playListID;

@end
