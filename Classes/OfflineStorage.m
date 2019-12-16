//
//  OfflineStorage.m
//  SuperHFRplus
//
//  Created by ezzz on 09/10/2019.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "OfflineStorage.h"
#import "HTMLparser.h"
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
        topic.isTopicLoadedInCache = NO;
        [self save];
    }
    else {
        [self.dicOfflineTopics setObject:topic forKey:[NSNumber numberWithInt:topic.postID]];
        [self save];
    }
}

- (void)updateOfflineTopic:(Topic*)newTopic {
    Topic* oldTopic = [self.dicOfflineTopics objectForKey:[NSNumber numberWithInt:newTopic.postID]];
    if (oldTopic) {
        newTopic.isTopicLoadedInCache = oldTopic.isTopicLoadedInCache;
        newTopic.maxTopicPageLoaded = oldTopic.maxTopicPageLoaded;
        newTopic.curTopicPageLoaded = oldTopic.curTopicPageLoaded;
        newTopic.minTopicPageLoaded = oldTopic.minTopicPageLoaded;
        [self.dicOfflineTopics setObject:newTopic forKey:[NSNumber numberWithInt:newTopic.postID]];
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
        topic.isTopicLoadedInCache = NO;
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
        NSError * error = nil;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];// error:&error];
        self.dicOfflineTopics = [unarchiver decodeObject];
        [unarchiver finishDecoding];
    }
    else {
        [self.dicOfflineTopics removeAllObjects];
    }
}

- (void)save {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:OFFLINETOPICSDICO_FILE]];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSError * error = nil;
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];// error:&error];
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
    
    int iPageToLoad = topic.curTopicPage;
    // If already in cache, start from last page
    if (topic.isTopicLoadedInCache) {
        iPageToLoad = topic.maxTopicPageLoaded;
    }
    while (iPageToLoad <= topic.maxTopicPage) {
        NSLog(@"Loading Topic %d (%@) - <<<<page %d>>>>", topic.postID, topic._aTitle, iPageToLoad);
        NSString* topicDirectory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d-%d", topic.postID, iPageToLoad]];
        NSString* filename = [topicDirectory stringByAppendingPathComponent:@"index.html"];

        // Check if page is already loaded in cache. For last page, there may be new posts, so it is reloaded each time.
        if ((iPageToLoad < topic.maxTopicPage) && [fileManager fileExistsAtPath:topicDirectory]) {
            NSLog(@"Filename %@ found. Skipping to next page", filename);
            iPageToLoad++;
            continue;
        } else if (iPageToLoad == topic.maxTopicPage) {
            NSError* error = nil;
            [fileManager removeItemAtPath:topicDirectory error:&error];
        }

        if (![fileManager fileExistsAtPath:topicDirectory isDirectory:&isDir]) {
            NSError* error = nil;
            [fileManager createDirectoryAtPath:topicDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
            if (error) {
                return NO;
            }
        }

        [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMaxi];
        NSString* sURL = [NSString stringWithFormat:@"https://forum.hardware.fr%@", [topic getURLforPage:iPageToLoad]];
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
                //NSLog(@"======================================================");
                //NSLog(@"OFFLINE HTML %@", [request responseString]);
                //NSLog(@"======================================================");
                
                NSError* error;
                HTMLParser *myParser = [[HTMLParser alloc] initWithData:[request responseData] error:&error];
                HTMLNode * bodyNode = [myParser body]; //Find the body tag
                NSArray *arrayMessages = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"messCase2" allowPartial:NO];
                int iImageNumber = 0;
                
                for (HTMLNode * nodeMessage in arrayMessages) { //Loop through all the images
                    if (nodeMessage.children.count >= 2) {
                        NSArray *arrayImages = [[nodeMessage.children objectAtIndex:1] findChildTags:@"img"];
                        for (HTMLNode * imgNode in arrayImages) { //Loop through all the images
                            NSString* sFilename = [NSString stringWithFormat:@"img%d",iImageNumber];
                            NSString* sPathFilename = [topicDirectory stringByAppendingPathComponent:sFilename];
                            //NSLog(@"Saving image: %@ to file %@", [imgNode getAttributeNamed:@"src"], sFilename);
                            //
                            if ([self loadImageWithName:[imgNode getAttributeNamed:@"src"] intoFilename:sPathFilename]) {
                                //NSLog(@"Before : %@", rawContentsOfNode([imgNode _node], [myParser _doc]));
                                NSString* sImgAttr = [NSString stringWithFormat:@"file://%@", sPathFilename];
                                [imgNode setAttributeNamed:@"src" withValue:sImgAttr];
                                //NSLog(@"After : %@", rawContentsOfNode([imgNode _node], [myParser _doc]));
                            }
                            iImageNumber++;
                        }
                    }
                }
                
                NSString* output = rawContentsOfNode([bodyNode _node], [myParser _doc]);
                output = [output stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                output = [output stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                output = [NSString stringWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" lang=\"fr\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" /></head>%@</html>", output];
                /*
                 NSLog(@"------------------------------------------------------");
                NSLog(@"Output %@", output);
                NSLog(@"------------------------------------------------------");

                NSLog(@"Writing file  %@", filename);
                 */
                NSData* data = [output dataUsingEncoding:NSUTF8StringEncoding];
                [data writeToFile:filename atomically:YES];// error:&errorWrite];
            }
        } else {
            NSLog(@"error in request. Stopping.");
            return NO;
        }

        if (iPageToLoad == topic.curTopicPage) {
            topic.curTopicPageLoaded = iPageToLoad;
            topic.minTopicPageLoaded = iPageToLoad;
        }
        
        iPageToLoad++;
    }
    
    topic.maxTopicPageLoaded = topic.maxTopicPage;
    topic.isTopicLoadedInCache = YES;
    
    [self save];
    
    return YES;
}

- (BOOL)loadImageWithName:(NSString*)sURL intoFilename:(NSString*)sFilename {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sURL]];
    [request setShouldRedirect:NO];
    [request setDelegate:self];
    [request startSynchronous];
    if ([request responseData]) {
        [[request responseData] writeToFile:sFilename atomically:YES];
        return YES;
    }
    return NO;
}

- (void)eraseAllTopicsInCache {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"cache"];
    NSError* error = nil;
    [fileManager removeItemAtPath:directory error:&error];
    if (error) {
        NSLog(@"Error erasing cache: %@ ", [error userInfo]);
    }
    
    for (NSNumber* keyTopidID in [dicOfflineTopics allKeys])
    {
        Topic *topic = [dicOfflineTopics objectForKey:keyTopidID];
        topic.isTopicLoadedInCache = NO;
    }
}

- (void)eraseAllTopics {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"cache"];
    NSError* error = nil;
    [fileManager removeItemAtPath:directory error:&error];
    if (error) {
        NSLog(@"Error erasing cache: %@ ", [error userInfo]);
    }
    
    for (NSNumber* keyTopidID in [dicOfflineTopics allKeys])
    {
        Topic *topic = [dicOfflineTopics objectForKey:keyTopidID];
        [self.dicOfflineTopics removeObjectForKey:[NSNumber numberWithInt:topic.postID]];
    }
    [self save];
}


- (void)verifyCacheIntegrity {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"cache"];

    for (NSNumber* keyTopidID in [dicOfflineTopics allKeys])
    {
        Topic *topic = [dicOfflineTopics objectForKey:keyTopidID];
        int iPageToCheck = topic.curTopicPage;
        if (topic.minTopicPageLoaded > 0) { // At least one page should be in cache
            iPageToCheck = topic.minTopicPageLoaded; // We start to check at first page loaded
        }
        while (iPageToCheck <= topic.maxTopicPage) { // up to the last known page of the topic
            NSString* topicDirectory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d-%d", topic.postID, iPageToCheck]];
            NSString* filename = [topicDirectory stringByAppendingPathComponent:@"index.html"];
            if (![fileManager fileExistsAtPath:filename]) {
                break; // Search is finished for this topic
            } else {
                if (topic.minTopicPageLoaded < 0) {
                    topic.minTopicPageLoaded = iPageToCheck;
                }
                topic.maxTopicPageLoaded = iPageToCheck; // maxTopicPageLoaded = last loaded page in cache
                topic.isTopicLoadedInCache = YES;
            }
            iPageToCheck++;
        }

    }
    
    [self save];
}

- (BOOL)checkTopicOffline:(Topic*)topic {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"cache"];
    directory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", topic.postID]];

    int iPageToCheck = topic.curTopicPage;
    while (iPageToCheck <= topic.maxTopicPage) {
        NSString* topicDirectory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d-%d", topic.postID, iPageToCheck]];
        NSString* filename = [topicDirectory stringByAppendingPathComponent:@"index.html"];
        if (![fileManager fileExistsAtPath:filename]) {
            topic.isTopicLoadedInCache = NO;
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
    NSString* topicDirectory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d-%d", topic.postID, iPage]];
    NSString* filename = [topicDirectory stringByAppendingPathComponent:@"index.html"];
    return  [fileManager contentsAtPath:filename];
}


@end

