//
//  SYSoundCloudParser.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYSyncEngine.h"
#import "SYParserConfig.h"

@interface SYParser : NSObject

- (NSURL *) filesDirectory;
- (void) objectsDownloadMonitoringIncrementDownloadsBy:(NSUInteger)nb;
- (void) objectsDownloadMonitoringIncrementErrorsBy:(NSUInteger)nb;
- (void) objectsDownloadMonitoringIncrementObjectsBy:(NSUInteger)nb;
- (BOOL) objectsDownloadMonitoringCompleted;
- (BOOL) objectsDownloadMonitoringStop;
- (BOOL) saveObjectsDownloaded;
- (void) resetObjectsDownloaded;
- (BOOL) saveBackgroundContext;

@property (strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;

@end
