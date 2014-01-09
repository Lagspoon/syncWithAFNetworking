//
//  SYSyncForParse.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 07/01/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SYSyncForParse : NSObject


//Parse.com date format is just a teeny bit different than NSDate —this small function make the necessary changes to date strings
- (NSString *)dateStringForAPIUsingDate:(NSDate *)date;
- (NSDate *)dateUsingStringFromAPI:(NSString *)dateString;
- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject;

@end
