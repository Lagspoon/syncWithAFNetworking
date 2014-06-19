//
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSyncEngine.h"





@interface SYSyncEngine ()

@end

@implementation SYSyncEngine

- (void) managedObjectContextUpdated {
    [self.delegate objectsDownloadedThanksToUpdateUI];
}


@end
