//
//  SYAPIKey.h
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 27/12/2013.
//  Copyright (c) 2013 Olivier Delecueillerie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYAPIKey : NSObject

typedef enum {
    parse = 0,
    flickr
} webservice;

typedef enum {
    SDObjectSynced = 0,
    SDObjectCreated,
    SDObjectDeleted,
} SDObjectSyncStatus;

#define parseWebService @"parse"
#define parseAPIBaseURLString @"https://api.parse.com/1/"
#define parseAPIApplicationId @"KquflPuBJrDPXryGCNoA1D5oAynrpo3Lqy2Nrsf8"
#define parseAPIRestKey @"xFy9ghmgp9Mdy4kfjLDZGiEmdPmxRokHZL7OX0t4"


#define flickrWebService @"flickr"
#define flickrAPIKey @"706f2fbd2baa75982beb3664809ef96e"
#define flickrAPIBaseURLString @"http://api.flickr.com/services/rest/?"
#define flickrAPIUserId @"112101684@N05"
#define flickrPhotosetClub1810 @"72157638931026294"

@end
