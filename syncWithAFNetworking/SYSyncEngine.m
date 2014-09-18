//
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSyncEngine.h"

//HTTP Client
#import "SYParseHTTPClient.h"
#import "SYSoundCloudHTTPClient.h"
#import "SYWikimediaHTTPClient.h"

//Parser
#import "SYParser.h"
#import "SYParseParser.h"
#import "SYSoundCloudParser.h"

@interface SYSyncEngine ()

@end

@implementation SYSyncEngine

+ (id)sharedEngine
{
    static SYSyncEngine *_sharedEngine = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEngine = [[self alloc] init];
    });
    
    return _sharedEngine;
}




- (void) saveObjectsDownloaded {
    if ([self saveBackgroundContext]) {
        [self.delegate managedObjectContextUpdated];
    } else {
        [self resetObjectsDownloaded];
    }
}

- (void) resetObjectsDownloaded {
    [self.backgroundManagedObjectContext reset];
}

// Return the NSManagedObjectContext to be used in the background during sync
- (NSManagedObjectContext *)backgroundManagedObjectContext {
    if (_backgroundManagedObjectContext != nil) {
        return _backgroundManagedObjectContext;
    }
    
    if ([self.delegate managedObjectContext]) {
        _backgroundManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_backgroundManagedObjectContext performBlockAndWait:^{
            [_backgroundManagedObjectContext setParentContext:[self.delegate managedObjectContext]];
            //[_backgroundManagedObjectContext setPersistentStoreCoordinator: self.persistentStoreCoordinator];
            
        }];
    }
    
    return _backgroundManagedObjectContext;
}


- (BOOL) saveBackgroundContext {
    __block BOOL success = YES;
    [self.backgroundManagedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        if(![self.backgroundManagedObjectContext save:&error]) {
            success = NO;
            NSLog(@"Could not save master context due to %@", error);
        } else {
            if (![[self.delegate managedObjectContext] save:&error]) {
                NSLog(@"Cannot save managedObjectContext");
                success = NO;
            }
        }
    }];
    return success;
}



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Parse delegate
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSManagedObjectContext *) managedObjectContext {
    return [self.delegate managedObjectContext];
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Parse.com services
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) downloadClassFromParseDotCom:(NSString *)className {
    SYParseHTTPClient *HTTPClient = [SYParseHTTPClient sharedHTTPClientWithBaseURL:parseAPIBaseURLString];
    
    dispatch_queue_t downloadQ = dispatch_queue_create("downloader queue", NULL);
    dispatch_async(downloadQ, ^{
        [HTTPClient downloadClass:className];
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SoundCloud services
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) downloadTracksFromPlaylist:(NSString *) playListID {
    SYSoundCloudHTTPClient *HTTPClient = [SYSoundCloudHTTPClient sharedHTTPClientWithBaseURL:soudCloudBaseURLString];
    
    dispatch_queue_t downloadQ = dispatch_queue_create("downloader queue", NULL);
    dispatch_async(downloadQ, ^{
        [HTTPClient downloadSetWithId:playListID withClientId:soundCloudClientID];
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wikimedia services
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) download {
    SYWikimediaHTTPClient *HTTPClient = [SYWikimediaHTTPClient sharedHTTPClientWithBaseURL:wikimediaBaseURLString];
    [HTTPClient downloadWordInfo];
}





- (void) downloadPhoneme {
    [self downloadClassFromParseDotCom:@"Phoneme"];
}



@end
