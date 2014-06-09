//
//  SYSyncFileManagement.m
//  syncWithAFNetworking
//
//  Created by Olivier Delecueillerie on 06/01/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "SYSyncFileManagement.h"

@implementation SYSyncFileManagement


////////////////////////////////////////////////////
//FILE MANAGEMENT
#pragma mark - FILE MANAGEMENT
////////////////////////////////////////////////////

- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)JSONDataRecordsDirectory{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"JSONRecords/" relativeToURL:[self applicationCacheDirectory]];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }

    return url;
}


- (BOOL)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if ([(NSDictionary *)response writeToFile:[fileURL path] atomically:YES]) {
        return YES;
    }else {
        NSLog(@"Error saving response to disk, will attempt to remove NSNull values and try again.");
        // remove NSNulls and try again...
        NSArray *records = [response objectForKey:@"results"];
        NSMutableArray *nullFreeRecords = [NSMutableArray array];
        for (NSDictionary *record in records) {
            NSMutableDictionary *nullFreeRecord = [NSMutableDictionary dictionaryWithDictionary:record];
            [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNull class]]) {
                    [nullFreeRecord setValue:nil forKey:key];
                }
            }];
            [nullFreeRecords addObject:nullFreeRecord];
        }

        NSDictionary *nullFreeDictionary = [NSDictionary dictionaryWithObject:nullFreeRecords forKey:@"results"];

        if ([nullFreeDictionary writeToFile:[fileURL path] atomically:YES]) {
            return YES;
        } else {
            NSLog(@"Failed all attempts to save response to disk: %@", response);
            return NO;
        }
    }
}

@end
