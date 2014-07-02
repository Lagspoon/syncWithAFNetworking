//
//  SYWikimediaEngine.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 24/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYWikimediaEngine.h"
#import "APIKey.h"

@implementation SYWikimediaEngine



- (id) init {
    self = [super init];
    if (self) {
        self.HTTPClient = [SYWikimediaHTTPClient sharedHTTPClientWithBaseURL:wikimediaBaseURLString];
    }
    return self;
}


- (void) download {
    [self.HTTPClient downloadWordInfo];
}
@end
