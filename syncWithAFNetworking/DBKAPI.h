//
//  DBKAPI.h
//  menu2Read
//
//  Created by Olivier Delecueillerie on 22/12/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBKAPI : NSObject

@property(nonatomic, strong) NSString *kAPIBaseURLString;
@property(nonatomic, strong) NSString *kAPIApplicationId;
@property(nonatomic, strong) NSString *kAPIRestKey;

@end
