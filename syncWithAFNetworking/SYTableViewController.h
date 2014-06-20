//
//  SYTableViewController.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 19/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SYSoundCloudSyncEngine.h"

@interface SYTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, soundCloudSyncEngineDelegate>

@end
