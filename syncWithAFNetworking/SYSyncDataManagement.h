//
//  SYSyncDataManagement.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 06/01/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYAPIKey.h"




@interface SYSyncDataManagement : NSObject

- (void)processJSONDataRecordsIntoCoreData:(webservice)webservice initialSyncComplete:(BOOL) initialSyncComplete registeredClassesToSync:(NSArray *) registeredClassesToSync;
- (void)processJSONDataRecordsForDeletion:(webservice)webservice registeredClassesToSync:(NSArray *)registeredClassesToSync;

@end
