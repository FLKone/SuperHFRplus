//
//  FilterPostsQuotes.h
//  SuperHFRplus
//
//  Created by ezzz on 05/04/2020.
//

#import "Topic.h"
#import "ASIHTTPRequest.h"

@interface FilterPostsQuotes : NSObject
{
}

+ (FilterPostsQuotes *)shared;
@property ASIHTTPRequest *request;
@property NSArray* arrData;

- (BOOL)fetchContentForTopic:(Topic*)topic;

@end
