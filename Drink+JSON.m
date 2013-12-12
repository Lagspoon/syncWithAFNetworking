//
//  Drink+JSON.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 23/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "Drink+JSON.h"
#import "NSManagedObject+JSON.h"
#import "SYSyncEngine.h"

@implementation Drink (JSON)

- (NSDictionary *)JSONToCreateObjectOnServer {
#warning to complete
    /*NSDictionary *date = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Date", @"__type",
                          [[SYSyncEngine sharedEngine] dateStringForAPIUsingDate:self.date], @"iso" , nil];*/

    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.name, @"name",
                                    nil];
    return jsonDictionary;
}

@end
