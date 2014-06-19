//
//  SYSoundCloudHTTPClient.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 13/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSoundCloudHTTPClient.h"
//#import "SYAPIKey.h"
#import "SYSoundCloudParser.h"

@implementation SYSoundCloudHTTPClient

+ (SYSoundCloudHTTPClient *)sharedHTTPClientWithBaseURL:(NSString *)baseURL
{
    static SYSoundCloudHTTPClient *_sharedHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
    
    return _sharedHTTPClient;
}


- (void) downloadSetWithId :(NSString *) playlist withClientId:(NSString *)clientId {
    
    NSString *URLString = [NSString stringWithFormat:@"http://api.soundcloud.com/playlists/%@.json?client_id=%@",playlist,clientId ];

    [self GET:URLString parameters:nil

      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray * arrayOfTrackDictionary = [self.delegateParser objectDictionaryFromResponseObject:responseObject];
          [self.delegateParser objectsDownloadMonitoringIncrementObjectsBy:[arrayOfTrackDictionary count]];
        
          for (NSDictionary * trackDictionary in arrayOfTrackDictionary) {
              [self importTrackDictionary:trackDictionary];
          }
      }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure %@", [error description]);
    }];
    
    NSLog(@"finish sownloadSetWithId");
}




-(void) importTrackDictionary :(NSDictionary *)trackDictionary {
    
    NSString *URL = [trackDictionary valueForKey:@"URL"];
    NSString *title = [trackDictionary valueForKey:@"title"];
    NSURL *completedURL = [NSURL URLWithString:[URL stringByAppendingString:@"?client_id=3dcd38cb94d6a8b051826000a5aa7428"]];
    NSProgress *progress;
    NSMutableDictionary *trackDictionaryUpdated = [NSMutableDictionary dictionaryWithDictionary:trackDictionary];

    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:[NSURLRequest requestWithURL:completedURL] progress:&progress
                      
                destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    NSURL *URLDestination = [[self.delegateParser filesDirectory] URLByAppendingPathComponent:title];
                    return URLDestination; //[targetPath lastPathComponent]];
                    [trackDictionaryUpdated addEntriesFromDictionary:@{@"file": URLDestination}];
                }
                                              
                completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    NSLog(@"File downloaded to: %@", filePath);
                    [self.delegateParser newManagedObjectFromObjectDictionary:trackDictionaryUpdated];
                    
                    if (error) {
                        [self.delegateParser objectsDownloadMonitoringIncrementErrorsBy:1];
                    }
                }
                                              ];
    [downloadTask resume];
}



@end
