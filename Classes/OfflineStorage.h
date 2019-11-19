//
//  OfflineStorage.h
//  SuperHFRplus
//
//  Created by ezzz on 09/10/2019.
//

#import <Foundation/Foundation.h>
#import "Topic.h"

@interface OfflineStorage : NSObject
{

}

@property NSMutableDictionary*    dicOfflineTopics;

+ (OfflineStorage *)shared;

- (BOOL)isOfflineTopic:(Topic*)topic;


// To activate / deactivate offline mode for a topic
- (void)toggleOfflineTopics:(Topic*)topic;
- (void)addTopicToOfflineTopics:(Topic*)topic withPage:(Topic*)page;
- (void)removeTopicFromOfflineTopics:(Topic*)topic;
- (BOOL)loadTopicToCache:(Topic*)topic;
- (void)eraseAllTopicsInCache;
- (void)verifyCacheIntegrity;
- (BOOL)checkTopicOffline:(Topic*)topic;
- (NSData*)getDataFromTopicOffline:(Topic*)topic page:(int)iPage;

@end
