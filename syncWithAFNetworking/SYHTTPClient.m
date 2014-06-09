//
//  SYHTTPRequestOperation.m
//  makeMyMouthWater
//
//  Created by Olivier Delecueillerie on 12/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "SYHTTPClient.h"
#import "SYSyncFileManagement.h"


@interface SYHTTPClient()

@property (nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *responseSerializer;
@property (nonatomic, weak) NSDictionary *webServiceInfo;
@property (nonatomic, strong) NSString *baseURLString;
@property (nonatomic, strong) SYSyncFileManagement *fileManagement; //used to deal with file manipulation

@end

@implementation SYHTTPClient




- (SYSyncFileManagement *) fileManagement {
    if (!_fileManagement) _fileManagement = [[SYSyncFileManagement alloc]init];
    return _fileManagement;
}
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
- (BOOL) downloadDataForClass:(NSString *)className withWebService:(webservice)webservice updatedAfterDate:(NSDate *)updatedDate {
    __block BOOL success;
    NSMutableString *URL = [NSMutableString stringWithString:self.baseURLString];
    NSMutableURLRequest *request;
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    NSMutableArray *operations = [NSMutableArray array];

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
            [URL appendString:[NSString stringWithFormat:@"classes/%@", className]];
            request = [self.requestSerializer requestWithMethod:@"GET" URLString:URL parameters:parameters];
        }
            break;
        case flickr:
        {
            request = [self flickrGETPhotosFromPhotoset:flickrPhotosetClub1810];
#warning no updatedAfterDate predicate implemented
        }
        default:
            break;
    }

    AFHTTPRequestOperation *operation = [self.requestOpManager HTTPRequestOperationWithRequest:request
                                                                                             success:(BOOL)^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                 //Write JSON files to disk
                                                 if ([self.fileManagement writeJSONResponse:responseObject toDiskForClassWithName:className]) {
                                                     return YES;
                                                 };
                                             } else {
                                                 return NO;
                                             }
                                         }
                                                                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             NSLog(@"Operation responseString : %@", operation.responseString);
                                             NSLog(@"Request for class %@ failed with error: %@", className, error);
                                         }];

    [operations addObject:operation];

    NSArray * batchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations
                                                                     progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations)
                                 {
                                     NSLog(@"%d of %d complete", numberOfFinishedOperations, totalNumberOfOperations);
                                 }
                                                                   completionBlock:^(NSArray *operations)
                                 {
                                     NSLog(@"All operations in batch complete");
                                 }];
    
    [[NSOperationQueue mainQueue] addOperations:batchOperations waitUntilFinished:YES];

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

- (UIImage *) downloadPhotoFromFlickr:(NSDictionary *)record {

    __block UIImage * photo;
    NSMutableURLRequest *request =[self flickrGETPhotoWithFarmId:[record valueForKey:@"farm"] serverId:[record valueForKey:@"server"] photoId:[record valueForKey:@"id"] secret:[record valueForKey:@"secret"] size:@"o"];
    AFHTTPRequestOperation *operation = [[SYHTTPClient sharedClientFor:flickr].requestOpManager HTTPRequestOperationWithRequest:request
                                                                                                                            success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                 photo = [UIImage imageWithData:(NSData *)responseObject];
                                             }
                                                                                                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                             {
                                                 NSLog(@"%@",operation.responseString);
                                                 NSLog(@"Request downloadPhotosFromFlickr failed with error: %@", error);
                                             }];
    return photo;
}

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
