//
//  Soundcloud.h
//  coreDataStack
//
//  Created by Olivier Delecueillerie on 17/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Soundcloud : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * audio;
@property (nonatomic, retain) NSDate * updatedAt;

@end
