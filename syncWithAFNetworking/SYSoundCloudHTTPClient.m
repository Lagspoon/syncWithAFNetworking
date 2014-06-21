//
//  SYSoundCloudHTTPClient.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 13/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSoundCloudHTTPClient.h"
#import "SYSoundCloudParser.h"

@interface SYSoundCloudHTTPClient ()

@property (strong, nonatomic) SYSoundCloudParser *parser;

@end

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

- (id) initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    self.parser = [[SYSoundCloudParser alloc] init];
    return self;
}

- (void) downloadSetWithId :(NSString *) playlist withClientId:(NSString *)clientId {
    
    NSString *URLString = [NSString stringWithFormat:@"http://api.soundcloud.com/playlists/%@.json?client_id=%@",playlist,clientId ];
    [self GET:URLString parameters:nil

      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSArray * arrayOfTrackDictionary = [self.parser objectDictionaryFromResponseObject:responseObject];
          [self.parser objectsDownloadMonitoringIncrementObjectsBy:[arrayOfTrackDictionary count]];
        
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
    
    NSString *URL = [trackDictionary valueForKey:objectDictionaryKeyDownloadURL];
    NSString *title = [trackDictionary valueForKey:objectDictionaryKeyTitle];
    NSURL *completedURL = [NSURL URLWithString:[URL stringByAppendingString:@"?client_id=3dcd38cb94d6a8b051826000a5aa7428"]];
    NSProgress *progress;
    NSMutableDictionary *trackDictionaryUpdated = [NSMutableDictionary dictionaryWithDictionary:trackDictionary];

    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:[NSURLRequest requestWithURL:completedURL] progress:&progress
                      
                destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    NSURL *URLDestination = [[self.parser filesDirectory] URLByAppendingPathComponent:title];
                    [trackDictionaryUpdated setValue:URLDestination forKey:objectDictionaryKeyFileURL];
                    return URLDestination; //[targetPath lastPathComponent]];

                }
                                              
                completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    NSLog(@"File downloaded to: %@", filePath);
                    [self.parser newManagedObjectFromObjectDictionary:trackDictionaryUpdated];
                    
                    if (error) {
                        [self.parser objectsDownloadMonitoringIncrementErrorsBy:1];
                    }
                }
                                              ];
    [downloadTask resume];
}



@end
