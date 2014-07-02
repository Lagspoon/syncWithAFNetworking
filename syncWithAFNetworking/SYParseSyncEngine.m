//
//  SYParseSyncEngine.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYParseSyncEngine.h"
#import "SYParseHTTPClient.h"
#import "APIKey.h"

@interface SYParseSyncEngine ()
@property (nonatomic, strong) SYParseHTTPClient *HTTPClient;

@end

@implementation SYParseSyncEngine



+ (SYParseSyncEngine *)sharedEngine
{
    static SYParseSyncEngine *_sharedEngine = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[self alloc] init];
    });
    
    return _sharedEngine;
}



- (id) init {
    self = [super init];
    if (self) {
        self.HTTPClient = [SYParseHTTPClient sharedHTTPClientWithBaseURL:parseAPIBaseURLString];
    }
    return self;
}

- (void) downloadClass:(NSString *)className {
    dispatch_queue_t downloadQ = dispatch_queue_create("downloader queue", NULL);
    dispatch_async(downloadQ, ^{
        [self.HTTPClient downloadClass:className];
    });
}

@end
