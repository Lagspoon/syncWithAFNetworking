//
//  SYParseParser.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYParseParser.h"
#import "SYSyncEngine.h"
#import <CoreData/CoreData.h>

@interface SYParseParser ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SYParseParser

-(void) phonemeDictionaryFromResponseObject:(NSDictionary *) responseObject {
    NSArray *arrayOfObjects;
    arrayOfObjects = [responseObject valueForKey:@"results"];
    [self objectsDownloadMonitoringIncrementObjectsBy:[arrayOfObjects count]];
    for (NSDictionary * object in arrayOfObjects) {
        
        NSDate *createdAt = [self dateUsingStringFromAPI:[object valueForKey:objectDictionaryKeyCreatedAt]];
        NSArray *graphemeArray = [object valueForKey:objectDictionaryKeyGrapheme];
        NSString *phoneme = [object valueForKey:objectDictionaryKeyPhoneme];
        NSString *objectId = [object valueForKey:objectDictionaryKeyObjectId];
        NSDate *updatedAt = [self dateUsingStringFromAPI:[object valueForKey:objectDictionaryKeyUpdatedAt]];
        
        NSLog(@"arrayOfGrapheme %@",[graphemeArray description]);

        
        NSDictionary *objectDictionary = @{
                                           objectDictionaryKeyEntityName    :   @"Phoneme",
                                           objectDictionaryKeyGrapheme      :   [graphemeArray componentsJoinedByString:@","],
                                           objectDictionaryKeyPhoneme       :   phoneme,
                                           objectDictionaryKeyCreatedAt     :   createdAt,
                                           objectDictionaryKeyUpdatedAt     :   updatedAt,
                                           objectDictionaryKeyObjectId      :   objectId
                                           };
        
        NSLog(@"object dictionary description%@", [objectDictionary description]);
        [self phonemeDictionaryToManagedObject:objectDictionary];
    }
}

- (void) phonemeDictionaryToManagedObject:(NSDictionary *)dictionary {
    
    if ([[dictionary valueForKey:objectDictionaryKeyEntityName] isEqualToString:@"Phoneme"]) {
        
        NSFetchRequest *fetchREquest = [NSFetchRequest fetchRequestWithEntityName:@"Phoneme"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@", @"objectId", [dictionary valueForKey:objectDictionaryKeyObjectId]];
        [fetchREquest setPredicate:predicate];
        NSError *error;
        NSArray *fectchingResult = [[[SYSyncEngine sharedEngine] backgroundManagedObjectContext] executeFetchRequest:fetchREquest error:&error];
        
        if (error) {
            NSLog(@"error in fetching%@", [error description]);
        }
        else if ([fectchingResult count] > 0) {
            NSManagedObject *fetchedObject = [fectchingResult firstObject];
            NSLog(@"object previously in DB%@",[self description]);
            NSDate *fetchedUpdatedAt = [fetchedObject valueForKey:@"updatedAt"];
            NSDate *newUpdatedAt = [dictionary valueForKey:objectDictionaryKeyUpdatedAt];
            if ([newUpdatedAt isEqualToDate:[fetchedUpdatedAt earlierDate:newUpdatedAt]]) {
                [fetchedObject setValue:[dictionary valueForKey:objectDictionaryKeyPhoneme] forKey:@"api"];
                [fetchedObject setValue:[dictionary valueForKey:objectDictionaryKeyGrapheme]forKey:@"grapheme"];
                [fetchedObject setValue:[dictionary valueForKey:objectDictionaryKeyObjectId] forKey:@"objectId"];
                [fetchedObject setValue:[dictionary valueForKey:objectDictionaryKeyUpdatedAt] forKey:@"updatedAt"];
            }
        }
        else if ([fectchingResult count] ==0) {
            NSManagedObject *phonemeNew = [NSEntityDescription insertNewObjectForEntityForName:@"Phoneme" inManagedObjectContext:[[SYSyncEngine sharedEngine] backgroundManagedObjectContext]];
            [phonemeNew setValue:[dictionary valueForKey:objectDictionaryKeyPhoneme] forKey:@"api"];
            [phonemeNew setValue:[dictionary valueForKey:objectDictionaryKeyGrapheme]forKey:@"grapheme"];
            [phonemeNew setValue:[dictionary valueForKey:objectDictionaryKeyObjectId] forKey:@"objectId"];
            [phonemeNew setValue:[dictionary valueForKey:objectDictionaryKeyUpdatedAt] forKey:@"updatedAt"];
        }
        
        [self objectsDownloadMonitoringIncrementDownloadsBy:1];
    }
    
    if ([self objectsDownloadMonitoringCompleted]) {
        [self objectsDownloadMonitoringReset];
        [[SYSyncEngine sharedEngine] saveObjectsDownloaded];
    }
}


- (BOOL) isObjectUpdated :(NSManagedObject *)object {
    BOOL result = YES;
    

    return result;
}

////////////////////////////////////////////////////
//RECORD TRANSLATION
#pragma mark - RECORD TRANSLATION
////////////////////////////////////////////////////

- (void)initializeDateFormatter {
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
}

- (NSDate *)dateUsingStringFromAPI:(NSString *)dateString {
    [self initializeDateFormatter];
    // NSDateFormatter does not like ISO 8601 so strip the milliseconds and timezone
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-5)];
    
    return [self.dateFormatter dateFromString:dateString];
}

- (NSString *)dateStringForAPIUsingDate:(NSDate *)date {
    [self initializeDateFormatter];
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    // remove Z
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-1)];
    // add milliseconds and put Z back on
    dateString = [dateString stringByAppendingFormat:@".000Z"];
    
    return dateString;
}




/*

- (NSPredicate *) predicateWithAttributeName:(NSString *) attributeName value:(NSString *)attributeValue  {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@", attributeName, attributeValue];
    return predicate;
}
*/

@end
