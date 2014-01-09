//
//  SYHTTPRequestOperation.m
//  makeMyMouthWater
//
//  Created by Olivier Delecueillerie on 12/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYHTTPClient.h"


@interface SYHTTPClient()

@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;
@property (nonatomic, weak) NSDictionary *webServiceInfo;
@property (nonatomic, strong) NSString *baseURLString;
@end

@implementation SYHTTPClient


////////////////////////////////////////////////////
//CLASS INSTANTIATION
#pragma mark - CLASS INSTANTIATION
////////////////////////////////////////////////////
+ (SYHTTPClient *) sharedClientFor:(webservice)webservice {

    static SYHTTPClient *sharedClient = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedClient = [[SYHTTPClient alloc] initFor:webservice];
        });

    return sharedClient;
}



- (SYHTTPClient *) initFor:(webservice)webservice {
    self = [super init];

    if (self) {
        switch (webservice) {
            case parse:
            {
                self.requestSerializer = [AFJSONRequestSerializer serializer];
                [self.requestSerializer setValue:parseAPIApplicationId forHTTPHeaderField:@"X-Parse-Application-Id"];
                [self.requestSerializer setValue:parseAPIRestKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
                self.requestOpManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[[NSURL alloc]initWithString:parseAPIBaseURLString]];
                self.requestOpManager.requestSerializer = self.requestSerializer;
                self.requestOpManager.responseSerializer = [AFJSONResponseSerializer serializer];
                self.baseURLString = parseAPIBaseURLString;
                break;
            }
            case flickr:
            {
                self.requestSerializer = [AFHTTPRequestSerializer serializer];
                self.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
                self.requestOpManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[[NSURL alloc]initWithString:flickrAPIBaseURLString]];
                self.requestOpManager.requestSerializer =self.requestSerializer;
                self.requestOpManager.responseSerializer = self.responseSerializer;
                self.baseURLString = flickrAPIBaseURLString;
            }
            default:
                break;
        }
    }
    return self;
}

////////////////////////////////////////////////////
//GENERIC REQUEST CREATION
#pragma mark - GENERIC REQUEST CREATION
////////////////////////////////////////////////////
- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className withWebService:(webservice)webservice updatedAfterDate:(NSDate *)updatedDate {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    if (updatedDate) {
        switch (webservice) {

            case parse:
            {
                if (updatedDate) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'999Z'"];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                NSString *jsonString = [NSString stringWithFormat:@"{\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}}",[dateFormatter stringFromDate:updatedDate]];
                parameters = [NSMutableDictionary dictionaryWithObject:jsonString forKey:@"where"];
                }

            }
                break;
            case flickr:
            {



#warning no updatedAfterDate predicate implemented

            }
            default:
                break;
        }
    }
    return [self GETRequestForClass:className withWebService:webservice parameters:parameters];
}

- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className withWebService:(webservice)webservice parameters:(NSMutableDictionary *)parameters {
    NSMutableString *URL = [NSMutableString stringWithString:self.baseURLString];

    switch (webservice) {
        case parse: //parse webservice
            [URL appendString:[NSString stringWithFormat:@"classes/%@", className]];
            break;
        case flickr: //flickr
        {

        }
            break;
        default:
            break;
    }
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:URL parameters:parameters];

    return request;
}


////////////////////////////////////////////////////
//PARSE REQUEST CREATION
#pragma mark - PARSE REQUEST CREATION
////////////////////////////////////////////////////



- (NSMutableURLRequest *)parsePOSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableString *URL = [NSMutableString stringWithString:parseAPIBaseURLString ];
    [URL appendString:[NSString stringWithFormat:@"classes/%@", className]];

    request = [self.requestSerializer requestWithMethod:@"POST" URLString:URL parameters:parameters];
    return request;
}

- (NSMutableURLRequest *)parseDELETERequestForClass:(NSString *)className forObjectWithId:(NSString *)objectId {
    NSMutableURLRequest *request = nil;
    NSMutableString *URL = [NSMutableString stringWithString:parseAPIBaseURLString ];
    [URL appendString:[NSString stringWithFormat:@"classes/%@/%@", className,objectId]];
    request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:URL parameters:nil];
    return request;
}

////////////////////////////////////////////////////
//FLICKR REQUEST CREATION
#pragma mark - FLICKR REQUEST CREATION
////////////////////////////////////////////////////
- (NSMutableURLRequest *) flickrGETPhotoWithFarmId:(NSString *)farmId  serverId:(NSString *)serverId photoId:(NSString *)photoId secret:(NSString *)secret size:(NSString *)size {
    NSMutableString *URL = [NSMutableString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_%@.jpg",farmId,serverId,photoId,secret,size];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:URL parameters:nil];
    return request;
}

- (NSMutableURLRequest *) flickrGETRequest:(NSString *) method parameters:(NSDictionary *)parameters {
#warning to complete
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];

    return request;
}

- (NSMutableURLRequest *) flickrGETPhotosFromPhotoset:(NSString *) photoset {

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters addEntriesFromDictionary:@{@"api_key": flickrAPIKey, @"photoset_id" : flickrPhotosetClub1810, @"format":@"json",@"nojsoncallback":@"1"}];
    //nojsoncallback key is to receive from Flickr only JSON and no callback fonction

    NSMutableString *URL = [NSMutableString stringWithString:self.baseURLString];
    [URL appendString:@"method=flickr.photosets.getPhotos"];

    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:URL parameters:parameters];

    return request;
}

@end
