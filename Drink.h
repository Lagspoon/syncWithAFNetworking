//
//  Drink.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 24/11/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Drink : NSManagedObject

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSNumber * alcool;
@property (nonatomic, retain) NSString * brand;
@property (nonatomic, retain) NSString * containing;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * ingredient;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * volume;

@end
