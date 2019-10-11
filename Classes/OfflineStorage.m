//
//  OfflineStorage.m
//  SuperHFRplus
//
//  Created by ezzz on 09/10/2019.
//

#import <Foundation/Foundation.h>

#import "OfflineStorage.h"
#import "Constants.h"

@implementation OfflineStorage

@synthesize dicOfflineTopics;

static OfflineStorage *_shared = nil;    // static instance variable

+ (OfflineStorage *)shared {
    if (_shared == nil) {
        _shared = [[super allocWithZone:NULL] init];
    }
    return _shared;
}

- (id)init {
    if ( (self = [super init]) ) {
        // your custom initialization
        self.dicOfflineTopics = [[NSMutableDictionary alloc] init];

        // load local storage data
        [self load];
    }
    return self;
}

- (BOOL)isOfflineTopic:(Topic*)topic {
    if ([self.dicOfflineTopics objectForKey:[NSNumber numberWithInt:topic.postID]]) {
        return YES;
    }
    return NO;
}


- (void)toggleOfflineTopics:(Topic*)topic {
    if ([self.dicOfflineTopics objectForKey:[NSNumber numberWithInt:topic.postID]]) {
        [self.dicOfflineTopics removeObjectForKey:[NSNumber numberWithInt:topic.postID]];
        [self save];
    }
    else {
        [self.dicOfflineTopics setObject:topic forKey:[NSNumber numberWithInt:topic.postID]];
        [self save];
    }
}

- (void)addTopicToOfflineTopics:(Topic*)topic {
    if (![self.dicOfflineTopics objectForKey:[NSNumber numberWithInt:topic.postID]]) {
        [self.dicOfflineTopics setObject:topic forKey:[NSNumber numberWithInt:topic.postID]];
        [self save];
    }
}

- (void)removeTopicFromOfflineTopics:(Topic*)topic {
    if (![self.dicOfflineTopics objectForKey:[NSNumber numberWithInt:topic.postID]]) {
        [self.dicOfflineTopics removeObjectForKey:[NSNumber numberWithInt:topic.postID]];
        [self save];
    }
}

- (void)load {
    // In worse case, take what is present in cache
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:OFFLINETOPICSDICO_FILE]];

    if ([fileManager fileExistsAtPath:filename]) {
        self.dicOfflineTopics = [NSMutableDictionary dictionaryWithContentsOfFile:filename];
    }
    else {
        [self.dicOfflineTopics removeAllObjects];
    }
}

- (void)save {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:OFFLINETOPICSDICO_FILE]];
    [self.dicOfflineTopics writeToFile:filename atomically:YES];
}

@end

