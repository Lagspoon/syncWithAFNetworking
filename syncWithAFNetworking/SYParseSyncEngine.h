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

@protocol parseParseDelegate

-(NSManagedObject *) mappingManagedObjectPhoneme:(NSString *)phoneme inManagedObjectContext:(NSManagedObjectContext *)MOC;
-(NSManagedObject *) mappingManagedObjectGrapheme:(NSString *)grapheme inManagedObjectContext:(NSManagedObjectContext *)MOC;
-(NSManagedObject *) mappingManagedObjectWords :(NSArray *)words inManagedObjectContext:(NSManagedObjectContext *)MOC;
-(void) linkingPhoneme:(NSManagedObject *)phoneme withGrapheme:(NSManagedObject *)grapheme withWords:(NSArray *)words;

@end

@interface SYParseSyncEngine : SYSyncEngine

+ (SYParseSyncEngine *) sharedEngine;
- (void) downloadClass:(NSString *)className;
@property (weak, nonatomic) id <parseParseDelegate> parseDelegate;


@end
