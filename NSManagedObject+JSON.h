//
//  NSManagedObject+JSON.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 23/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (JSON)
- (NSDictionary *)JSONToCreateObjectOnServer;
- (NSString *)dateStringForAPIUsingDate:(NSDate *)date;
@end
