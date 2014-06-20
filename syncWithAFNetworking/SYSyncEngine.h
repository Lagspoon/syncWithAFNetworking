//
//  SYSoundCloudSyncEngine.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol syncEngineDelegate

-(NSString *)entityName;
-(NSManagedObjectContext *)managedObjectContext;
- (void) managedObjectContextUpdated;

@end

@interface SYSyncEngine : NSObject
+ (SYSyncEngine *)sharedEngine;
@property (weak, nonatomic) id <syncEngineDelegate> delegate;

@end
