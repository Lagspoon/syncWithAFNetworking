//
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSyncEngine.h"

@interface SYSyncEngine ()

@end

@implementation SYSyncEngine


+ (SYSyncEngine *)sharedEngine
{
    static SYSyncEngine *_sharedEngine = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[self alloc] init];
    });
    
    return _sharedEngine;
}


@end
