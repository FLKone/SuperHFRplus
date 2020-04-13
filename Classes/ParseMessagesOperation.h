//
//  parseMessagesOperation.h
//  HFRplus
//
//  Created by FLK on 06/08/10.
//

@class LinkItem;
@class HTMLParser;
@protocol ParseMessagesOperationDelegate;


@interface ParseMessagesOperation : NSOperation
{
@private
    id <ParseMessagesOperationDelegate> __weak delegate;
    NSData          *dataToParse;
    LinkItem		*workingEntry;
    BOOL            reverse;
	int				index;

    NSOperationQueue		*queue;
}
@property     NSMutableArray        *workingArray;

- (id)initWithData:(NSData *)data index:(int)theIndex reverse:(BOOL)isReverse delegate:(id <ParseMessagesOperationDelegate>)theDelegate;
- (void)parseData:(HTMLParser*)myParser;
- (void)parseData:(HTMLParser *)myParser filterPostsQuotes:(BOOL)bFilterPostsQuotes topicUrl:(NSString*)sTopicUrl topicPage:(int)iPage;

@end

@protocol ParseMessagesOperationDelegate
- (void)didFinishParsing:(NSArray *)appList;
- (void)didStartParsing:(HTMLParser *)myParser;
@end
