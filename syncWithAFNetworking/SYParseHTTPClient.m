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
          NSLog(@"responseObject %@",[responseObject description]);
        NSArray * arrayOfObjectDictionary = [self.parser objectDictionaryFromResponseObject:responseObject];
          NSLog(@"sucess %@", [arrayOfObjectDictionary description]);
          for (NSDictionary *objectDictionary in arrayOfObjectDictionary) {
              NSLog(@"objectDic %@",[objectDictionary description]);
             // [self.parser newManagedObjectFromObjectDictionary:objectDictionary];
          }
      }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"failure %@", [error description]);
    }];
    
    NSLog(@"finish downloadClass");
}


@end
