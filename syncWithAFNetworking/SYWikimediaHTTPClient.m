//
//  SYWikimediaHTTPClient.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 24/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYWikimediaHTTPClient.h"

@interface SYWikimediaHTTPClient ()

@property (strong, nonatomic) SYParser *parser;


@end

@implementation SYWikimediaHTTPClient

- (id) initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    //[self.requestSerializer setValue: wikimediaUserAgent forHTTPHeaderField:@"User-Agent"];
    self.parser = [[SYParser alloc] init];
    return self;
}



- (void) downloadWordInfo {
    
    //NSString *URLString = @"http://en.wikipedia.org/w/api.php?action=query&titles=San_Francisco&prop=images&imlimit=20&format=json";rvprop=content
    //https://fr.wiktionary.org/wiki/bonjour
    NSString *URLString = @"http://fr.wiktionary.org/w/api.php?action=query&titles=bonjour&format=json";
    NSLog(@"header %@", [self.requestSerializer.HTTPRequestHeaders description]);
    [self GET:URLString parameters:nil
     
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSLog(@"responseObject %@",[responseObject description]);
          [self downloadWordPronunciation];
          
          /*NSArray * arrayOfObjectDictionary = [self.parser objectDictionaryFromResponseObject:responseObject];
          NSLog(@"sucess %@", [arrayOfObjectDictionary description]);
          for (NSDictionary *objectDictionary in arrayOfObjectDictionary) {
              NSLog(@"objectDic %@",[objectDictionary description]);
              // [self.parser newManagedObjectFromObjectDictionary:objectDictionary];
          }*/
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          NSLog(@"failure %@", [error description]);
      }];
    
    NSLog(@"finish downloadClass");
}

-(void) downloadWordPronunciation {// :(NSURL *)track {
    
    NSString *URL = @"http://commons.wikimedia.org/wiki/File:Fr-lagune.ogg";
    
    NSString *title = @"Fr-lagune.ogg";
    NSURL *completedURL = [NSURL URLWithString:[URL stringByAppendingString:@""]];
    NSProgress *progress;
    //NSMutableDictionary *trackDictionaryUpdated = [NSMutableDictionary dictionaryWithDictionary:trackDictionary];
    
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:[NSURLRequest requestWithURL:completedURL] progress:&progress
                                              
                                                               destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                   NSURL *URLDestination = [[self.parser filesDirectory] URLByAppendingPathComponent:title];
                                                                   //[trackDictionaryUpdated setValue:URLDestination forKey:objectDictionaryKeyFileURL];
                                                                   return URLDestination; //[targetPath lastPathComponent]];
                                                                   
                                                               }
                                              
                                                         completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                             NSLog(@"File downloaded to: %@", filePath);
                                                             //[self.parser newManagedObjectFromObjectDictionary:trackDictionaryUpdated];
                                                             
                                                             if (error) {
                                                                 //[self.parser objectsDownloadMonitoringIncrementErrorsBy:1];
                                                                 NSLog(@"error completion hanlder : %@", [error description]);
                                                             }
                                                         }
                                              ];
    [downloadTask resume];
}

@end
