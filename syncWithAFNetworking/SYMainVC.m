//
//  SYMainVC.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 24/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYMainVC.h"
#import "APIKey.h"

@interface SYMainVC ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation SYMainVC


- (IBAction)parseDownload:(id)sender {
    SYParseSyncEngine *parseEngine = [SYParseSyncEngine sharedEngine];
    parseEngine.delegate = self;
    [parseEngine downloadClass:@"test3"];
}

- (IBAction)wikimediaDownload:(id)sender {
    SYWikimediaEngine *wikimediaEngine = [SYWikimediaEngine sharedEngine];
    wikimediaEngine.delegate = self;
    [wikimediaEngine download];
}


- (IBAction)soundcloudDownload:(id)sender {
    SYSoundCloudSyncEngine *soundcloudEngine = [SYSoundCloudSyncEngine sharedEngine];
    soundcloudEngine.delegate = self;
    [soundcloudEngine downloadTracksFromPlaylist:soundCloudPlaylistPhonemeFrench];
    
}



- (IBAction)flickr:(id)sender {

    
}


/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//SYSyncDelegate
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

- (void) dictionaryDownloaded:(NSDictionary *)dictionary {
    self.textView.text = [NSString stringWithFormat:@"%@ \n %@",self.textView.text,[dictionary description]];
}
@end
