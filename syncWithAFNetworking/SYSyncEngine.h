//
//  SYSoundCloudSyncEngine.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SYHTTPClient.h"

@protocol syncEngineDelegate

- (void) dictionaryDownloaded:(NSDictionary *)dictionary;


@end

@interface SYSyncEngine : NSObject
+ (id)sharedEngine;
@property (strong, nonatomic) id HTTPClient;
@property (weak, nonatomic) id <syncEngineDelegate> delegate;

@end
