//
//  SYSoundCloudHTTPClient.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 13/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYHTTPClient.h"

@interface SYSoundCloudHTTPClient : SYHTTPClient

+ (SYSoundCloudHTTPClient *)sharedHTTPClientWithBaseURL:(NSString *)baseURL;
- (void) downloadSetWithId :(NSString *) playlist withClientId:(NSString *)clientId;

@end
