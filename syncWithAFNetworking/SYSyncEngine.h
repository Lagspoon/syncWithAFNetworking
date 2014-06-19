//
//  SYSoundCloudSyncEngine.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYCoreDataStackWithSyncStuff.h"

@protocol syncEngineDelegate

-(void) objectsDownloadedThanksToUpdateUI;
@end

@interface SYSyncEngine : NSObject <NSObject>

@property (strong, nonatomic) id <syncEngineDelegate> delegate;


@end
