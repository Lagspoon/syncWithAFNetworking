//
//  SYSoundCloudSyncEngine.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
//#import "SYHTTPClient.h"

@protocol syncEngineDelegate <NSObject>

//- (void) dictionaryDownloaded:(NSDictionary *)dictionary;
- (void) managedObjectContextUpdated;
- (NSManagedObjectContext *) managedObjectContext;

@end


@interface SYSyncEngine : NSObject
+ (id)sharedEngine;
@property (weak, nonatomic) id <syncEngineDelegate> delegate;
@property (strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;


//- (void) downloadClassFromParseDotCom:(NSString *)className;
- (void) downloadPhoneme;


//parser delegate
- (void) saveObjectsDownloaded;
- (void) resetObjectsDownloaded;
- (BOOL) saveBackgroundContext;

@end
