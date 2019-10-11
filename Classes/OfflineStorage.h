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
- (void)toggleOfflineTopics:(Topic*)topicID;
- (void)addTopicToOfflineTopics:(Topic*)topicID withPage:(Topic*)page;
- (void)removeTopicFromOfflineTopics:(Topic*)topicID;

@end
