//
//  DBKAPI.m
//  menu2Read
//
//  Created by Olivier Delecueillerie on 22/12/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import "DBKAPI.h"

#define APIBaseURLString @"https://api.parse.com/1/"
#define APIApplicationId @"KquflPuBJrDPXryGCNoA1D5oAynrpo3Lqy2Nrsf8"
#define APIRestKey @"xFy9ghmgp9Mdy4kfjLDZGiEmdPmxRokHZL7OX0t4"

/*
 Clé
706f2fbd2baa75982beb3664809ef96e

Secret :
68af3dc5cef1d203 
 */
@implementation DBKAPI

- (NSString *) kAPIBaseURLString {
    if (!_kAPIBaseURLString) _kAPIBaseURLString=APIBaseURLString;
    return _kAPIBaseURLString;
}

- (NSString *) kAPIApplicationId {
    if (!_kAPIApplicationId) _kAPIApplicationId=APIApplicationId;
    return _kAPIApplicationId;
}

- (NSString *) kAPIRestKey {
    if (!_kAPIRestKey) _kAPIRestKey=APIRestKey;
    return _kAPIRestKey;
}
@end
