//
//  SYParseSyncEngine.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SYSyncEngine.h"
#import "SYParseHTTPClient.h"

@protocol parseSyncEngineDelegate <syncEngineDelegate>

//-(void) mappingManagedObject:(NSManagedObject *)managedObject audio:(NSData *)audio name:(NSString *)name createdAt:(NSDate *)createdAt ;

@end

@interface SYParseSyncEngine : SYSyncEngine

+ (SYParseSyncEngine *) sharedEngine;
- (void) downloadClass:(NSString *)className;
@property (weak, nonatomic) id <parseSyncEngineDelegate> delegate;


@end
