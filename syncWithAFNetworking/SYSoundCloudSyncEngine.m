//
//  SYSoundCloudSyncEngine.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSoundCloudSyncEngine.h"
#import "SYSoundCloudHTTPClient.h"
#import "APIKey.h"

@interface SYSoundCloudSyncEngine ()
@property (nonatomic, strong) SYSoundCloudHTTPClient *HTTPClient;

@end

@implementation SYSoundCloudSyncEngine



+ (SYSoundCloudSyncEngine *)sharedEngine
{
    static SYSoundCloudSyncEngine *_sharedEngine = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[self alloc] init];
    });
    
    return _sharedEngine;
}



- (id) init {
    self = [super init];
    if (self) {
        self.HTTPClient = [SYSoundCloudHTTPClient sharedHTTPClientWithBaseURL:soudCloudBaseURLString];
    }
    return self;
}

- (void) downloadTracksFromPlaylist:(NSString *) playListID {
    dispatch_queue_t downloadQ = dispatch_queue_create("downloader queue", NULL);
    dispatch_async(downloadQ, ^{
        [self.HTTPClient downloadSetWithId:playListID withClientId:soundCloudClientID];
    });
}

-(void) mappingManagedObject:(NSManagedObject *)managedObject fromEntity:(NSString *(^)(void))entityName withAudio:(NSData *)audio name:(NSString *)name createdAt:(NSDate *)createdAt {
        
    
}

@end
