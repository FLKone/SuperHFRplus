//
//  FilterPostsQuotes.m
//  SuperHFRplus
//
//  Created by ezzz on 05/04/2020.
//

#import "FilterPostsQuotes.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "ParseMessagesOperation.h"

@implementation FilterPostsQuotes

@synthesize request, arrData;

static FilterPostsQuotes *_shared = nil;    // static instance variable

// --------------------------------------------------------------------------------
// Init methods
// --------------------------------------------------------------------------------

+ (FilterPostsQuotes *)shared {
    if (_shared == nil) {
        _shared = [[super allocWithZone:NULL] init];
    }
    return _shared;
}

- (id)init {
    if ( (self = [super init]) ) {
        // your custom initialization
    }
    return self;
}

- (BOOL)fetchContentForTopic:(Topic*)topic {
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMaxi];
    self.arrData = [[NSMutableArray alloc] init];
    int iPageToLoad = topic.curTopicPage;
    int iNbPagesLoaded = 0;
    while (iPageToLoad <= topic.maxTopicPage) {
        NSLog(@"Loading Topic page %d", iPageToLoad);
    
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
            
            if ([request responseData]) {
                ParseMessagesOperation *parser = [[ParseMessagesOperation alloc] initWithData:[request responseData] index:0 reverse:NO delegate:nil];
                NSError * error = nil;
                HTMLParser *myParser = [[HTMLParser alloc] initWithData:[request responseData] error:&error];
                [parser parseData:myParser filterPostsQuotes:YES];
                
                self.arrData = [self.arrData arrayByAddingObjectsFromArray:parser.workingArray];
            }
        }
        iPageToLoad++;
        iNbPagesLoaded++;
        if (iNbPagesLoaded >= 20) { break; }
    }
    return YES;
}


@end
