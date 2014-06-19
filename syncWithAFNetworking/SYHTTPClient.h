//
//  SYSoundCloudHTTPClient.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 13/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import <CoreData/CoreData.h>

@protocol HTTPClientParserDelegate <NSObject>

- (NSURL *) filesDirectory;
- (void) objectsDownloadMonitoringIncrementDownloadsBy:(NSUInteger)nb;
- (void) objectsDownloadMonitoringIncrementErrorsBy:(NSUInteger)nb;
- (void) objectsDownloadMonitoringIncrementObjectsBy:(NSUInteger)nb;
- (BOOL) objectsDownloadMonitoringCompleted;
- (BOOL) objectsDownloadMonitoringStop;
- (BOOL) saveObjectsDownloaded;
- (void) resetObjectsDownloaded;
@end

@interface SYHTTPClient : AFHTTPSessionManager

- (instancetype)initWithBaseURL:(NSURL *)url;
@property (nonatomic, weak) id <HTTPClientParserDelegate> delegateParser;

@end
