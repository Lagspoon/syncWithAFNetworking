//
//  SYSyncFileManagement.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 06/01/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYSyncFileManagement : NSObject


- (NSURL *)JSONDataRecordsDirectory;
- (void)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className;

@end
