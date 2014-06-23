//
//  SYParseHTTPClient.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 13/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYHTTPClient.h"

@interface SYParseHTTPClient : SYHTTPClient

+ (SYParseHTTPClient *)sharedHTTPClientWithBaseURL:(NSString *)baseURL;
- (void) downloadClass :(NSString *)className;

@end
