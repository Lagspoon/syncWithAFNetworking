//
//  SYSoundCloudHTTPClient.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 13/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "SYParser.h"

@interface SYHTTPClient : AFHTTPSessionManager

- (instancetype)initWithBaseURL:(NSURL *)url;

@end
