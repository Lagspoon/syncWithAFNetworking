//
//  SYParseParser.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 14/06/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYParseParser.h"
#import "SYParseSyncEngine.h"
#import <CoreData/CoreData.h>

@interface SYParseParser ()
@property (nonatomic, strong) SYParseSyncEngine *syncEngine;

@end

@implementation SYParseParser

- (SYParseSyncEngine *) syncEngine {
    if (!_syncEngine) {
        _syncEngine = [SYParseSyncEngine sharedEngine];
    }
    return _syncEngine;
}

-(NSArray *) objectDictionaryFromResponseObject:(NSDictionary *) responseObject {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    NSArray *arrayOfObjects;
    arrayOfObjects = [responseObject valueForKey:@"results"];
    for (NSDictionary * object in arrayOfObjects) {
        NSDictionary *objectDictionary = @{ objectDictionaryKeyGrapheme :[object valueForKey:@"grapheme"],
                                           objectDictionaryKeyPhoneme:[object valueForKey:@"phoneme"],
                                           objectDictionaryKeyCreatedAt :[object valueForKey:@"createdAt"],
                                           };
        
        [self.syncEngine.delegate dictionaryDownloaded:objectDictionary];
        [mutableArray addObject:objectDictionary];
    }
    NSLog(@"objectDictionary %@", [mutableArray description]);
    
    return (NSArray *)mutableArray;

}

/*
- (void) newManagedObjectFromObjectDictionary:(NSDictionary *)objectDictionary {
    
    NSString *phoneme = [objectDictionary valueForKey:objectDictionaryKeyPhoneme];
    NSArray *graphemeArray = [objectDictionary valueForKey:objectDictionaryKeyGrapheme];

    NSManagedObject *phonemeObject  =   [self getUpdatedObjectInEntityName:modelPhonemeEntityName attributeName:@"api" attributeValue:phoneme];
    [phonemeObject setValue:graphemeArray forKey:@"grapheme"];
    
    [self saveObjectsDownloaded];
    NSLog(@"save MOC");
}
*/
/*
- (NSManagedObject *) getUpdatedObjectInEntityName:(NSString *)entityName attributeName:(NSString *) attributeName attributeValue:(NSString *)attributeValue {
    
    NSFetchRequest *fetchREquest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate *predicate = [self predicateWithAttributeName:attributeName value:attributeValue];
    
    [fetchREquest setPredicate:predicate];
    NSError *error;
    NSArray *fectchingResult = [self.backgroundManagedObjectContext executeFetchRequest:fetchREquest error:&error];

    if (error) {
        NSLog(@"error in fetching%@", [error description]);
        return nil;
    } else if ([fectchingResult count] > 0) {
        NSManagedObject *fetchedObject = [fectchingResult firstObject];
        NSLog(@"object previously in DB%@",[self description]);
        return fetchedObject;
    } else {
        return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.backgroundManagedObjectContext];
    }
}

- (NSPredicate *) predicateWithAttributeName:(NSString *) attributeName value:(NSString *)attributeValue  {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like %@", attributeName, attributeValue];
    return predicate;
}
*/

/*
- (void) updateObject:(NSManagedObject *)object withDictionary:(NSDictionary *)dictionary {
    if ([[object.entity name] isEqualToString:modelPhonemeEntityName]) {
        for (NSString *keyName in [dictionary allKeys]) {
            [object setValue:[dictionary valueForKey:keyName] forKey:keyName];
        }
    }
}
*/
@end
