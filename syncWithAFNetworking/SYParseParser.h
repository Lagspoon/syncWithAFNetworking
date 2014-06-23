//
//  SYParseParser.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYParser.h"


@interface SYParseParser : SYParser
-(NSArray *) objectDictionaryFromResponseObject:(NSDictionary *) responseObject;
- (void) newManagedObjectFromObjectDictionary:(NSDictionary *)objectDictionary;

@end
