//
//  OfflineStorage.h
//  SuperHFRplus
//
//  Created by ezzz on 09/10/2019.
//

#import <Foundation/Foundation.h>
#import "Topic.h"
#import "OfflineTableViewController.h"

@interface OfflineStorage : NSObject
{

}

@property NSMutableDictionary*    dicOfflineTopics;
@property NSMutableDictionary*    dicImageCacheList;

+ (OfflineStorage *)shared;
- (BOOL)isOfflineTopic:(Topic*)topic;

// To activate / deactivate offline mode for a topic
- (void)toggleOfflineTopics:(Topic*)topic;
- (void)updateOfflineTopic:(Topic*)newTopic;
//- (void)addTopicToOfflineTopics:(Topic*)topic withPage:(Topic*)page;
- (void)removeTopicFromOfflineTopics:(Topic*)topic;
- (BOOL)loadTopicToCache:(Topic*)topic fromInstance:(OfflineTableViewController*)vc totalPages:(int)t;
- (void)eraseAllTopicsInCache;
- (void)eraseAllTopics;
- (void)verifyCacheIntegrity;
- (BOOL)checkTopicOffline:(Topic*)topic;
- (NSData*)getDataFromTopicOffline:(Topic*)topic page:(int)iPage;

- (void)copyAllRequiredResourcesFromBundleToCache;
- (NSURL*)createHtmlFileInCacheForTopic:(Topic*)topic withContent:(NSString*)sHtml;
- (NSURL*)cacheURL;

@end
