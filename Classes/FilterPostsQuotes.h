//
//  FilterPostsQuotes.h
//  SuperHFRplus
//
//  Created by ezzz on 05/04/2020.
//

#import "Topic.h"
#import "ASIHTTPRequest.h"

@class FavoritesTableViewController, MessagesTableViewController, Topic;

@interface FilterPostsQuotes : NSObject
{
}

@property ASIHTTPRequest *request;
@property NSArray* arrData;
@property Topic* topic;
@property int iStartPage, iLastPageLoaded;
@property BOOL bIsFinished;
@property BOOL bShowPostsRequired, stopRequired;

@property (nonatomic, strong) UIAlertController *alertProgress;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) FavoritesTableViewController* favoriteVC;
@property (nonatomic, strong) MessagesTableViewController* messagesTableVC;

//+ (FilterPostsQuotes *)shared;

- (void)checkPostsAndQuotesForTopic:(Topic *)topic andVC:(FavoritesTableViewController*)vc;
- (void)checkPostsAndQuotesForAllTopics:(NSArray *)arrTopics andVC:(FavoritesTableViewController*)vc;

- (void)checkNextPostsAndQuotesWithVC:(MessagesTableViewController*) vc;

- (void)fetchContentForTopic:(Topic*)topic;
- (void)fetchContentForTopic:(Topic*)topic startPage:(int)iStartPage;

@end
