//
//  SYCoreDataStackWithSyncStuff.h
//
//  Created by Olivier Delecueillerie on 13/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "DBCoreDataStack.h"
#import "SYParser.h"


@interface SYCoreDataStackWithSyncStuff : DBCoreDataStack <parserCoreDataDelegate>

+ (id)sharedInstance;
//parserDelegate property
@property (strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;
- (BOOL) saveBackgroundContext;
@end
