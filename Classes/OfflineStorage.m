//
//  OfflineStorage.m
//  SuperHFRplus
//
//  Created by ezzz on 09/10/2019.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
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
        NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.dicOfflineTopics = [unarchiver decodeObject];
        [unarchiver finishDecoding];    }
    else {
        [self.dicOfflineTopics removeAllObjects];
    }
}

- (void)save {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:OFFLINETOPICSDICO_FILE]];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.dicOfflineTopics];
    [archiver finishEncoding];
    [data writeToFile:filename atomically:YES];
}

- (BOOL)loadTopicToCache:(Topic*)topic {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"cache"];
    directory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", topic.postID]];
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
        if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL]) {
            return NO;
        }
    }
    
    // TBD : remove pages < curTopicPage
    
    int iPageToLoad = topic.curTopicPage;
    while (iPageToLoad <= topic.maxTopicPage) {
        NSLog(@"Loading Topic %d (%@) - <<<<page %d>>>>", topic.postID, topic._aTitle, iPageToLoad);
        NSString *filename = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d-%d.dat", topic.postID, iPageToLoad]];

        // Check if page is already loaded in cache. For last page, there may be new posts, so it is reloaded each time.
        if ((iPageToLoad < topic.maxTopicPage) && [fileManager fileExistsAtPath:filename]) {
            NSLog(@"Filename %@ found. Skipping to next page", filename);
            iPageToLoad++;
            continue;
        }
         
        [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMaxi];
        NSString* sURL = [NSString stringWithFormat:@"https://forum.hardware.fr%@", [topic getURLforPage:iPageToLoad]];
        NSLog(@"URL <%@>", sURL);
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sURL]];
        [request setShouldRedirect:NO];
        [request setDelegate:self];
        [request startSynchronous];
        if (request) {
            if ([request error]) {
                NSLog(@"error: %@", [[request error] localizedDescription]);
                return NO;
            }
            
            if ([request responseData]) {
                NSLog(@"Writing filename %@", filename);
                [[request responseData] writeToFile:filename atomically:YES];
            }
        } else {
            NSLog(@"error in request. Stopping.");
            return NO;
        }

        iPageToLoad++;
    }

    return YES;
}

- (BOOL)checkTopicOffline:(Topic*)topic {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"cache"];
    directory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", topic.postID]];

    int iPageToCheck = topic.curTopicPage;
    while (iPageToCheck <= topic.maxTopicPage) {
        NSString *filename = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d-%d.dat", topic.postID, iPageToCheck]];
        if (![fileManager fileExistsAtPath:filename]) {
            return NO;
        }
        iPageToCheck++;
    }
    
    return YES;
}

- (NSData*)getDataFromTopicOffline:(Topic*)topic page:(int)iPage {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"cache"];
    directory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", topic.postID]];
    NSString *filename = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d-%d.dat", topic.postID, iPage]];
    return [fileManager contentsAtPath:filename];
}


@end

