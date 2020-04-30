//
//  OfflineStorage.m
//  SuperHFRplus
//
//  Created by ezzz on 09/10/2019.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest+Tools.h"
#import "OfflineStorage.h"
#import "OfflineTableViewController.h"
#import "HTMLparser.h"
#import "Constants.h"
#define IMAGE_CACHE_DIRECTORY @"image_cache"

@implementation OfflineStorage

@synthesize dicOfflineTopics, dicImageCacheList;

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
        self.dicImageCacheList = [[NSMutableDictionary alloc] init];

        // load local storage data
        [self load];
        [self loadImageCache];
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
    if ([self.dicOfflineTopics objectForKey:[NSNumber numberWithInt:topic.postID]]) {
        [self.dicOfflineTopics removeObjectForKey:[NSNumber numberWithInt:topic.postID]];
        topic.isTopicLoadedInCache = NO;
        [self save];
    }
}

- (void)load {
    // In worse case, take what is present in cache
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:OFFLINE_TOPICS_DICO_FILE]];

    if ([fileManager fileExistsAtPath:filename]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];// error:&error];
        self.dicOfflineTopics = [unarchiver decodeObject];
        [unarchiver finishDecoding];
    }
    else {
        [self.dicOfflineTopics removeAllObjects];
    }
}

- (void)loadImageCache {
    // In worse case, take what is present in cache
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:OFFLINE_IMAGECACHE_DICO_FILE]];

    if ([fileManager fileExistsAtPath:filename]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filename];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];// error:&error];
        self.dicImageCacheList = [unarchiver decodeObject];
        [unarchiver finishDecoding];
    }
    else {
        [self.dicImageCacheList removeAllObjects];
    }
}


- (void)save {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:OFFLINE_TOPICS_DICO_FILE]];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];// error:&error];
    [archiver encodeObject:self.dicOfflineTopics];
    [archiver finishEncoding];
    [data writeToFile:filename atomically:YES];
}

- (void)saveImageCache {
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filename = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:OFFLINE_IMAGECACHE_DICO_FILE]];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];// error:&error];
    [archiver encodeObject:self.dicImageCacheList];
    [archiver finishEncoding];
    [data writeToFile:filename atomically:YES];
}


- (BOOL)loadTopicToCache:(Topic*)topic fromInstance:(OfflineTableViewController*)vc totalPages:(int)t {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    directory = [directory stringByAppendingPathComponent:@"cache"];
    NSString* sDirectoryImages = [directory stringByAppendingPathComponent:IMAGE_CACHE_DIRECTORY];
    if(![fileManager createDirectoryAtPath:sDirectoryImages withIntermediateDirectories:YES attributes:nil error:NULL]) {
        return NO;
    }
    
    directory = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", topic.postID]];
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDir]) {
        if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL]) {
            return NO;
        }
    }
    
    int iNbMaxPageToLoad = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"offline_max_pages"];
    int nbPageToLoad = 0;
    int nbPageLoaded = 0;
    int iFirstPageToLoad = topic.curTopicPage; // By default start loading at current page
    if (topic.isTopicLoadedInCache) {
        if ((topic.maxTopicPageLoaded - topic.curTopicPageLoaded + 1) >= iNbMaxPageToLoad) {
            nbPageToLoad = 0; // Everything is already loaded
        } else {
            nbPageToLoad = MINIMUM(iNbMaxPageToLoad, iNbMaxPageToLoad - (topic.maxTopicPageLoaded - topic.curTopicPageLoaded + 1));
            nbPageToLoad = MINIMUM(nbPageToLoad, (topic.maxTopicPage - topic.maxTopicPageLoaded));
            iFirstPageToLoad = topic.maxTopicPageLoaded + 1;
        }
    } else {
        if ((topic.maxTopicPage - topic.curTopicPage + 1) >= iNbMaxPageToLoad) {
            nbPageToLoad = iNbMaxPageToLoad;
        } else {
            nbPageToLoad = (topic.maxTopicPage - topic.curTopicPage + 1);
        }
    }

    if (nbPageToLoad > 0) {
        int iPageToLoad = iFirstPageToLoad;
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
            [request setShouldRedirect:YES];
            [request setDelegate:self];
            [request setUseCookiePersistence:NO];
            [request setRequestCookies:[[NSMutableArray alloc]init]];
            [request startSynchronous];
            if (request) {
                if ([request error]) {
                    NSLog(@"error: %@", [[request error] localizedDescription]);
                    return NO;
                }
                
                if ([request safeResponseData]) {
                    //NSLog(@"======================================================");
                    //NSLog(@"OFFLINE URL  %@", sURL);
                    //NSLog(@"OFFLINE HTML %@", [request safeResponseString]);
                    //NSLog(@"======================================================");
                    
                    NSError* error;
                    HTMLParser *myParser = [[HTMLParser alloc] initWithData:[request safeResponseData] error:&error];
                    HTMLNode * bodyNode = [myParser body]; //Find the body tag
                    NSArray *arrayMessages = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"messCase2" allowPartial:NO];
                    int iImageNumber = 0;
                    
                    for (HTMLNode * nodeMessage in arrayMessages) { //Loop through all the images
                        if (nodeMessage.children.count >= 2) {
                            NSArray *arrayImages = [[nodeMessage.children objectAtIndex:1] findChildTags:@"img"];
                            for (HTMLNode * imgNode in arrayImages) { //Loop through all the images
                                NSString* sFilename = [self loadImageWithName:[imgNode getAttributeNamed:@"src"]];
                                if (sFilename) {
                                    //NSLog(@"Before : %@", rawContentsOfNode([imgNode _node], [myParser _doc]));
                                    NSString* sImgAttr = [NSString stringWithFormat:@"file://%@", sFilename];
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
                    
                    NSString* sTitleTopic = topic._aTitle;
                    if (sTitleTopic.length > 25) sTitleTopic = [NSString stringWithFormat:@"%@...", [sTitleTopic substringToIndex:25]];
                    NSString* sMessage = [NSString stringWithFormat:@"%@\nPage %d", sTitleTopic, iPageToLoad];
                    vc.iNbPagesLoaded++;
                    float fProgress = ((float)vc.iNbPagesLoaded)/t;
                    [vc updateProgressBarWithPercent:fProgress andMessage: sMessage];
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
            nbPageLoaded++;
            if (nbPageLoaded >= nbPageToLoad) {
                break;
            }
        }
        
        topic.maxTopicPageLoaded = iPageToLoad - 1;
        topic.isTopicLoadedInCache = YES;
        
        [self save];
    }
    
    return YES;
}

- (NSString*)loadImageWithName:(NSString*)sURL {
    @try {
        //NSLog(@"### IMAGE CACHE ### Loading image from URL [%@]", sURL);
        sURL = [sURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@":/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-"]];
        //NSLog(@"### IMAGE CACHE ### Updated URL [%@]", sURL);

        // If image in cache, do not reload it
        NSString* sFilename = [self.dicImageCacheList objectForKey:sURL];
        if (sFilename && [[[NSFileManager alloc] init] fileExistsAtPath:sFilename]) {
            NSLog(@"### IMAGE CACHE ### File found for url (u:%@,f:%@)",sURL,sFilename);
            return sFilename;
        }
        else {
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sURL]];
            [request setShouldRedirect:NO];
            [request setTimeOutSeconds:2];
            [request setDelegate:self];
            [request startSynchronous];
            NSData* dResponseData = [request responseData];
            if (dResponseData) {
                NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                directory = [directory stringByAppendingPathComponent:@"cache"];
                directory = [directory stringByAppendingPathComponent:IMAGE_CACHE_DIRECTORY];
                NSString* sFilenameNewImage = [directory stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
                [dResponseData writeToFile:sFilenameNewImage atomically:YES];
                [self.dicImageCacheList setObject:sFilenameNewImage forKey:sURL];
                NSLog(@"### IMAGE CACHE ### File saved into cache (u:%@,f:%@)", sURL, sFilenameNewImage);
                return sFilenameNewImage;
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        NSLog(@"### IMAGE CACHE ### ERROR loading image : %@",sURL);
        return nil;
    }
    @finally {}
    return nil;
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
    while (iPageToCheck <= topic.maxTopicPageLoaded) {
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

