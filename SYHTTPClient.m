//
//  SYHTTPRequestOperation.m
//  makeMyMouthWater
//
//  Created by Olivier Delecueillerie on 12/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYHTTPClient.h"

#warning need2update
#define kAPIBaseURLString @"https://api.parse.com/1/"
#define kAPIApplicationId @""
#define kAPIRestKey @""

@interface SYHTTPClient()

@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;

@end

@implementation SYHTTPClient

////////////////////////////////////////////////////
//LAZY INSTANTIATION
#pragma mark - LAZY INSTANTIATION
////////////////////////////////////////////////////
- (AFHTTPRequestOperationManager *) requestOpManager {
if(!_requestOpManager) _requestOpManager=[[AFHTTPRequestOperationManager alloc]initWithBaseURL:[[NSURL alloc]initWithString:kAPIBaseURLString]];
    
    _requestOpManager.requestSerializer = [AFJSONRequestSerializer serializer];
    _requestOpManager.responseSerializer = [AFJSONResponseSerializer serializer];
    return _requestOpManager;
}


- (AFHTTPRequestSerializer *) requestSerializer {
    if (!_requestSerializer) _requestSerializer = [AFJSONRequestSerializer serializer];
    [_requestSerializer setValue:kAPIApplicationId forHTTPHeaderField:@"X-Parse-Application-Id"];
    [_requestSerializer setValue:kAPIRestKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    return _requestSerializer;
}

////////////////////////////////////////////////////
//CLASS INSTANTIATION
#pragma mark - CLASS INSTANTIATION
////////////////////////////////////////////////////
+ (SYHTTPClient *) sharedClient {
    static SYHTTPClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[SYHTTPClient alloc] init];
    });
    return sharedClient;
}

////////////////////////////////////////////////////
//REQUEST CREATION
#pragma mark - REQUEST CREATION
////////////////////////////////////////////////////
- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;
    NSMutableString *URL = [NSMutableString stringWithString:kAPIBaseURLString ];
    [URL appendString:[NSString stringWithFormat:@"classes/%@", className]];

    request = [self.requestSerializer requestWithMethod:@"GET" URLString:URL parameters:parameters];
               
    return request;
}

- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate {
    NSMutableURLRequest *request = nil;
    NSDictionary *parameters = nil;
    if (updatedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'999Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        NSString *jsonString = [NSString stringWithFormat:@"{\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}",[dateFormatter stringFromDate:updatedDate]];
        parameters = [NSDictionary dictionaryWithObject:jsonString forKey:@"where"];
    }
    request = [self GETRequestForClass:className parameters:parameters];

    return request;
}

- (NSMutableURLRequest *)POSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableString *URL = [NSMutableString stringWithString:kAPIBaseURLString ];
    [URL appendString:[NSString stringWithFormat:@"classes/%@", className]];

    request = [self.requestSerializer requestWithMethod:@"POST" URLString:URL parameters:parameters];
    return request;
}

- (NSMutableURLRequest *)DELETERequestForClass:(NSString *)className forObjectWithId:(NSString *)objectId {
    NSMutableURLRequest *request = nil;
    NSMutableString *URL = [NSMutableString stringWithString:kAPIBaseURLString ];
    [URL appendString:[NSString stringWithFormat:@"classes/%@/%@", className,objectId]];
    request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:URL parameters:nil];
    return request;
}

@end
