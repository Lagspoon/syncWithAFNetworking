//
//  SYHTTPRequestOperation.h
//  makeMyMouthWater
//
//  Created by Olivier Delecueillerie on 12/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "SYAPIKey.h"


@interface SYHTTPClient : NSObject



+ (SYHTTPClient *)sharedClientFor:(webservice)webservice;
@property (nonatomic, strong) AFHTTPRequestOperationManager *requestOpManager;

//GENERIC REQUEST
- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className withWebService:(webservice)webservice parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className withWebService:(webservice)webservice updatedAfterDate:(NSDate *)updatedDate;

//PARSE REQUEST
- (NSMutableURLRequest *)parsePOSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)parseDELETERequestForClass:(NSString *)className forObjectWithId:(NSString *)objectId;


//FLICKR REQUEST
- (NSMutableURLRequest *) flickrGETRequest:(NSString *) method parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *) flickrGETPhotoWithFarmId:(NSString *)farmId  serverId:(NSString *)serverId photoId:(NSString *)photoId secret:(NSString *)secret size:(NSString *)size;


@end
