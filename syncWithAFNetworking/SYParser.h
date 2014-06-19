//
//  SYSoundCloudParser.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYHTTPClient.h"

@protocol parserSynEngineDelegate <NSObject>

- (void) managedObjectContextUpdated;

@end


@protocol parserCoreDataDelegate <NSObject>

@property (strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;
- (BOOL) saveBackgroundContext;

@end



@interface SYParser : NSObject <HTTPClientParserDelegate>
@property (nonatomic, weak) id <parserCoreDataDelegate> delegateCoreData;
@property (nonatomic, weak) id <parserSynEngineDelegate> delegateSyncEngine;
@end
