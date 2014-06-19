//
//  SYSoundCloudParser.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYSoundCloudHTTPClient.h"
#import "SYParser.h"

@protocol soundCloudParserSyncEngineDelegate <parserSynEngineDelegate>

@end

@interface SYSoundCloudParser : SYParser <soundCloudHTTPClientParserDelegate>

@property (nonatomic, weak) id <soundCloudParserSyncEngineDelegate> delegateSyncEngine;


@end
