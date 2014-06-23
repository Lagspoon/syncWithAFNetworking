//
//  SYParseHTTPClient.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 13/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//
#import "SYParseHTTPClient.h"
#import "SYParseParser.h"
#import "APIKey.h"

@interface SYParseHTTPClient ()

@property (strong, nonatomic) SYParseParser *parser;

@end

@implementation SYParseHTTPClient

+ (SYParseHTTPClient *)sharedHTTPClientWithBaseURL:(NSString *)baseURL
{
    static SYParseHTTPClient *_sharedHTTPClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHTTPClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
    
    return _sharedHTTPClient;
}

- (id) initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    [self.requestSerializer setValue:parseAPIApplicationId forHTTPHeaderField:@"X-Parse-Application-Id"];
    [self.requestSerializer setValue:parseAPIRestKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    self.parser = [[SYParseParser alloc] init];
    return self;
}

- (void) downloadClass :(NSString *)className {
    
    NSString *URLString = [NSString stringWithFormat:@"classes/%@",className];
    NSLog(@"header %@", [self.requestSerializer.HTTPRequestHeaders description]);
    [self GET:URLString parameters:nil

     
      success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray * arrayOfObjectDictionary = [self.parser objectDictionaryFromResponseObject:responseObject];
          NSLog(@"sucess %@", [arrayOfObjectDictionary description]);
//           [self.parser objectsDownloadMonitoringIncrementObjectsBy:[arrayOfTrackDictionary count]];
          for (NSDictionary *objectDictionary in arrayOfObjectDictionary) {
              [self.parser newManagedObjectFromObjectDictionary:objectDictionary];
          }
//          for (NSDictionary * trackDictionary in arrayOfTrackDictionary) {
//              [self importTrackDictionary:trackDictionary];
//          }
      }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure %@", [error description]);
    }];
    
    NSLog(@"finish downloadClass");
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
