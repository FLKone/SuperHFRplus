//
//  OnlineMessagesTableViewController.m
//  HFRplus
//
//  Created by FLK on 07/07/10.
//

#import <unistd.h>

#import "OnlineMessagesTableViewController.h"
#import "MessagesSearchTableViewController.h"
#import "MessageDetailViewController.h"
#import "TopicsTableViewController.h"
#import "PollTableViewController.h"

//#import "HFR_EditorViewController.h"


#import "RegexKitLite.h"
#import "HTMLParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

#import "ASIDownloadCache.h"

#import "UIWebView+Tools.h"

#import "ShakeView.h"
//#import "UIImageView+WebCache.h"
#import "RangeOfCharacters.h"
#import "NSData+Base64.h"

#import "LinkItem.h"
#import <CommonCrypto/CommonDigest.h>

#import "ProfilViewController.h"
#import "UIMenuItem+CXAImageSupport.h"
#import "UIImpactFeedbackGenerator+UserDefaults.h"
#import "BlackList.h"

#import "ThemeManager.h"
#import "ThemeColors.h"
#import "MultisManager.h"
#import "HFRAlertView.h"
#import "MPStorage.h"

@implementation OnlineMessagesTableViewController


#pragma mark -
#pragma mark Data lifecycle



#pragma mark -
#pragma mark View lifecycle


-(void)setupScrollAndPage
{
	//NSLog(@"topicName: %@", self.topicName);
	
	//On vire le '#t09707987987'
	NSRange rangeFlagPage;
	rangeFlagPage =  [[self currentUrl] rangeOfString:@"#" options:NSBackwardsSearch];
	
    
    if (self.stringFlagTopic.length == 0) {
        if (!(rangeFlagPage.location == NSNotFound)) {
            self.stringFlagTopic = [[self currentUrl] substringFromIndex:rangeFlagPage.location];
        }
        else {
            self.stringFlagTopic = @"";
        }
    }
    
	if (!(rangeFlagPage.location == NSNotFound)) {
		self.currentUrl = [[self currentUrl] substringToIndex:rangeFlagPage.location];
    }    
	//--


    /* else */
    
    {
        //On check si y'a page=2323
        NSString *regexString  = @".*page=([^&]+).*";
        NSRange   matchedRange;// = NSMakeRange(NSNotFound, 0UL);
        NSRange   searchRange = NSMakeRange(0, self.currentUrl.length);
        NSError  *error2        = NULL;
        
        matchedRange = [self.currentUrl rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
        
        if (matchedRange.location == NSNotFound) {
            NSRange rangeNumPage =  [[self currentUrl] rangeOfCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] options:NSBackwardsSearch];
            if (rangeNumPage.location == NSNotFound) {
                //
                NSLog(@"something went wrong");
                return;
                //[self.navigationController popViewControllerAnimated:YES];
            }
            else {
                self.pageNumber = [[self.currentUrl substringWithRange:rangeNumPage] intValue];
            }
        }
        else {
            self.pageNumber = [[self.currentUrl substringWithRange:matchedRange] intValue];
            
        }
        //On check si y'a page=2323
        
        [(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber]];
        [(UILabel *)[self navigationItem].titleView adjustFontSizeToFit];
    }

    //NSLog(@"pageNumber %d", self.pageNumber);

    if (self.isSearchInstra) {
        
        [(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"Recherche | %@", self.topicName]];
        [(UILabel *)[self navigationItem].titleView adjustFontSizeToFit];
        
    }
    
	//self.title = [NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber];
    
	//[self navigationItem].titleView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
	
}

-(void)setupPageToolbar:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser;
{
    if (!self.pageNumber && !self.errorReported) {
        self.errorReported = YES;
        
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(backgroundQueue, ^{
            // Do your long running code
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        });
        
        return;
    }
	//NSLog(@"setupPageToolbar");
    //Titre
	HTMLNode *titleNode = [[bodyNode findChildWithAttribute:@"class" matchingName:@"fondForum2Title" allowPartial:YES] findChildTag:@"h3"]; //Get all the <img alt="" />
	if ([titleNode allContents] && self.topicName.length == 0) {
		//NSLog(@"setupPageToolbar titleNode %@", [titleNode allContents]);
		self.topicName = [titleNode allContents];
        
        [(UILabel *)[self navigationItem].titleView setText:[NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber]];
        [(UILabel *)[self navigationItem].titleView adjustFontSizeToFit];

        //self.title = [NSString stringWithFormat:@"%@ — %d", self.topicName, self.pageNumber];

		//[self navigationItem].titleView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
	}
    //Titre
    
    
	HTMLNode * pagesTrNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"fondForum2PagesHaut" allowPartial:YES];
	
	if(pagesTrNode)
	{
        
		HTMLNode * pagesLinkNode = [pagesTrNode findChildWithAttribute:@"class" matchingName:@"left" allowPartial:NO];
		
		if (pagesLinkNode) {
			//NSLog(@"pages %@", rawContentsOfNode([pagesLinkNode _node], [myParser _doc]));
			
			//NSArray *temporaryNumPagesArray = [[NSArray alloc] init];
			NSArray *temporaryNumPagesArray = [pagesLinkNode children];
            
			[self setFirstPageNumber:[[[temporaryNumPagesArray objectAtIndex:2] contents] intValue]];
			
            //NSLog(@"num %d = %d", [self pageNumber], [self firstPageNumber]);

            
			if ([self pageNumber] == [self firstPageNumber]) {
				NSString *newFirstPageUrl = [[NSString alloc] initWithString:[self currentUrl]];
				[self setFirstPageUrl:newFirstPageUrl];
			}
			else {
                NSLog(@"[temporaryNumPagesArray objectAtIndex:2] %@", [temporaryNumPagesArray objectAtIndex:2]);
				NSString *newFirstPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray objectAtIndex:2] getAttributeNamed:@"href"]];
				[self setFirstPageUrl:newFirstPageUrl];
			}
			

			[self setLastPageNumber:[[[temporaryNumPagesArray lastObject] contents] intValue]];

			
			if ([self pageNumber] == [self lastPageNumber]) {
				NSString *newLastPageUrl = [[NSString alloc] initWithString:[self currentUrl]];
				[self setLastPageUrl:newLastPageUrl];
			}
			else {
                //NSLog(@"lastObject %@", [[temporaryNumPagesArray lastObject] allContents]);
                
				NSString *newLastPageUrl = [[NSString alloc] initWithString:[[temporaryNumPagesArray lastObject] getAttributeNamed:@"href"]];
				[self setLastPageUrl:newLastPageUrl];
			}

			/*
			 NSLog(@"premiere %d", [self firstPageNumber]);			
			 NSLog(@"premiere url %@", [self firstPageUrl]);
			 
			 NSLog(@"premiere %d", [self lastPageNumber]);			
			 NSLog(@"premiere url %@", [self lastPageUrl]);		
			 */
			
			//TableFooter
			UIToolbar *tmptoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
			tmptoolbar.barStyle = UIBarStyleDefault;
			[tmptoolbar sizeToFit];
			
			//Add buttons
			UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
																						 target:self
																						 action:@selector(firstPage:)];
			if ([self pageNumber] == [self firstPageNumber]) {
				[systemItem1 setEnabled:NO];
			}
			
			UIBarButtonItem *systemItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
																						 target:self
																						 action:@selector(lastPage:)];

			if ([self pageNumber] == [self lastPageNumber]) {
				[systemItem2 setEnabled:NO];
			}		
			
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 230, 44)];
			[label setFont:[UIFont boldSystemFontOfSize:15.0]];
			[label setAdjustsFontSizeToFitWidth:YES];
			[label setBackgroundColor:[UIColor clearColor]];
			[label setTextAlignment:NSTextAlignmentCenter];
			[label setLineBreakMode:NSLineBreakByTruncatingMiddle];
			[label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
			
			[label setTextColor:[UIColor whiteColor]];
			[label setNumberOfLines:0];
			[label setTag:666];
			[label setText:[NSString stringWithFormat:@"%d/%d", [self pageNumber], [self lastPageNumber]]];
			
			UIBarButtonItem *systemItem3 = [[UIBarButtonItem alloc] initWithCustomView:label];
			
			
			
			
			
			//Use this to put space in between your toolbox buttons
			UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					  target:nil
																					  action:nil];

			//Add buttons to the array
			NSArray *items = [NSArray arrayWithObjects: systemItem1, flexItem, systemItem3, flexItem, systemItem2, nil];
			
			//release buttons
			
			//add array of buttons to toolbar
			[tmptoolbar setItems:items animated:NO];
			
			self.aToolbar = tmptoolbar;
			
		}
		else {
			self.aToolbar = nil;
			//NSLog(@"pas de pages");
            [self setFirstPageNumber:1];
            [self setLastPageNumber:1];
		}
		
		//--
		
		
		//NSArray *temporaryPagesArray = [[NSArray alloc] init];
		
		NSArray *temporaryPagesArray = [pagesTrNode findChildrenWithAttribute:@"class" matchingName:@"pagepresuiv" allowPartial:YES];
		
        if (self.isSearchInstra) {
            [self.view addGestureRecognizer:swipeLeftRecognizer];
        }
		else if(temporaryPagesArray.count != 3)
		{
			//NSLog(@"pas 3");
			//[self.view removeGestureRecognizer:swipeLeftRecognizer];
			//[self.view removeGestureRecognizer:swipeRightRecognizer];
		}
		else {
            HTMLNode *nextUrlNode = [[temporaryPagesArray objectAtIndex:0] findChildWithAttribute:@"class" matchingName:@"cHeader" allowPartial:NO];
            
            if (nextUrlNode) {
                //nextPageUrl = [[NSString stringWithFormat:@"%@", [topicUrl stringByReplacingCharactersInRange:rangeNumPage withString:[NSString stringWithFormat:@"%d", (pageNumber + 1)]]] retain];
                //nextPageUrl = [[NSString stringWithFormat:@"%@", [topicUrl stringByReplacingCharactersInRange:rangeNumPage withString:[NSString stringWithFormat:@"%d", (pageNumber + 1)]]] retain];
                [self.view addGestureRecognizer:swipeLeftRecognizer];
                self.nextPageUrl = [[nextUrlNode getAttributeNamed:@"href"] copy];
                //NSLog(@"nextPageUrl = %@", nextPageUrl);
                
            }
            else {
                self.nextPageUrl = @"";
                //[self.view removeGestureRecognizer:swipeLeftRecognizer];
            }
            
            HTMLNode *previousUrlNode = [[temporaryPagesArray objectAtIndex:1] findChildWithAttribute:@"class" matchingName:@"cHeader" allowPartial:NO];
            
            if (previousUrlNode) {
                //previousPageUrl = [[topicUrl stringByReplacingCharactersInRange:rangeNumPage withString:[NSString stringWithFormat:@"%d", (pageNumber - 1)]] retain];
                [self.view addGestureRecognizer:swipeRightRecognizer];
                self.previousPageUrl = [[previousUrlNode getAttributeNamed:@"href"] copy];
                //NSLog(@"previousPageUrl = %@", previousPageUrl);
                
            }
            else {
                self.previousPageUrl = @"";
                //[self.view removeGestureRecognizer:swipeRightRecognizer];
                
                
            }
		}
	}
	else {
		self.aToolbar = nil;
	}
	//NSLog(@"Fin setupPageToolbar");

	//--Pages
}

-(void)setupPoll:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser {
    self.pollNode = nil;
    self.pollParser = nil;
    self.isNewPoll = NO;
    
	HTMLNode * tmpPollNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"sondage" allowPartial:NO];
	if(tmpPollNode)
    {
        //NSLog(@"Raw Poll %@", rawContentsOfNode([tmpPollNode _node], [myParser _doc]));
        [self setPollNode:tmpPollNode];
        [self setPollParser:myParser];
        
        // Adapt action button of navigation bar
        HTMLNode * tmpPollNodeInput = [tmpPollNode findChildTag:@"input"];
        if (tmpPollNodeInput) {
            self.isNewPoll = YES;
        }
    }
}

-(void)setupIntrSearch:(HTMLNode *)bodyNode andP:(HTMLParser *)myParser {
    HTMLNode * tmpSearchNode = [bodyNode findChildWithAttribute:@"action" matchingName:@"/transsearch.php" allowPartial:NO];
    if(tmpSearchNode)
    {
        [self.searchInputData removeAllObjects];
        
        
        NSArray *wantedArr = [NSArray arrayWithObjects:@"hash_check", @"p", @"post", @"cat", @"firstnum", @"currentnum", @"word", @"spseudo", @"filter", nil];
        //NSLog(@"INTRA");
        //hidden input for URL          post | cat | currentnum
        //hidden input for URL          word | spseudo | filter
        
        NSArray *arrInput = [tmpSearchNode findChildTags:@"input"];
        for (HTMLNode *no in arrInput) {
            //NSLog(@"%@ = %@", [no getAttributeNamed:@"name"], [no getAttributeNamed:@"value"]);
            
            if ([no getAttributeNamed:@"name"] && [wantedArr indexOfObject: [no getAttributeNamed:@"name"]] != NSNotFound) {
                
                //NSLog(@"WANTED %lu", (unsigned long)[wantedArr indexOfObject: [no getAttributeNamed:@"name"]]);
                if (![[no getAttributeNamed:@"type"] isEqualToString:@"checkbox"] || ([[no getAttributeNamed:@"type"] isEqualToString:@"checkbox"] && [[no getAttributeNamed:@"checked"] isEqualToString:@"checked"])) {
                    [self.searchInputData setValue:[no getAttributeNamed:@"value"] forKey:[no getAttributeNamed:@"name"]];
                }
                
                if ([[no getAttributeNamed:@"name"] isEqualToString:@"word"]) {
                    [self.searchKeyword setText:[no getAttributeNamed:@"value"]];
                }
                else if ([[no getAttributeNamed:@"name"] isEqualToString:@"spseudo"]) {
                    [self.searchPseudo setText:[no getAttributeNamed:@"value"]];
                }
                else if ([[no getAttributeNamed:@"name"] isEqualToString:@"filter"]) {
                    //NSLog(@"name %@ = %@", [no getAttributeNamed:@"name"], [no getAttributeNamed:@"checked"]);
                    if ([[no getAttributeNamed:@"checked"] isEqualToString:@"checked"]) {
                        NSLog(@"FILTER ON");
                        [self.searchFilter setOn:YES animated:NO];
                    }
                    else {
                        NSLog(@"FILTER OFF");
                        [self.searchFilter setOn:NO animated:NO];
                    }
                }
                else if ([[no getAttributeNamed:@"name"] isEqualToString:@"currentnum"]) {
                    [self.searchInputData setValue:[no getAttributeNamed:@"value"] forKey:@"tmp_currentnum"];
                    [self.searchFromFP setOn:NO animated:NO];
                }else if ([[no getAttributeNamed:@"name"] isEqualToString:@"firstnum"]) {
                    [self.searchInputData setValue:[no getAttributeNamed:@"value"] forKey:@"tmp_firstnum"];
                    [self.searchFromFP setOn:NO animated:NO];
                }
            }
        }
        
    }
    else if (self.searchInputData.count) {
        if ([self.searchInputData valueForKey:@"word"]) {
            [self.searchKeyword setText:[self.searchInputData valueForKey:@"word"]];
        }
        
        if ([self.searchInputData valueForKey:@"spseudo"]) {
            [self.searchPseudo setText:[self.searchInputData valueForKey:@"spseudo"]];
        }
        
        if ([self.searchInputData valueForKey:@"filter"]) {
            [self.searchFilter setOn:YES animated:NO];
        }
        
        if (![self.searchInputData valueForKey:@"currentnum"] && ![self.searchInputData valueForKey:@"firstnum"]) {
            [self.searchFromFP setOn:YES animated:NO];
        }
        else {
            [self.searchFromFP setOn:NO animated:NO];
        }
    }
}




-(void)loadDataInTableView:(HTMLParser *)myParser
{    
	[self setupScrollAndPage];

	//NSLog(@"name topicName %@", self.topicName);
	
	HTMLNode * bodyNode = [myParser body]; //Find the body tag

	//MP
	BOOL needToUpdateMP = NO;
	HTMLNode *MPNode = [bodyNode findChildOfClass:@"none"]; //Get links for cat	
	NSArray *temporaryMPArray = [MPNode findChildTags:@"td"];
	//NSLog(@"temporaryMPArray count %d", temporaryMPArray.count);
	
	if (temporaryMPArray.count == 3) {
		//NSLog(@"MPNode allContents %@", [[temporaryMPArray objectAtIndex:1] allContents]);
		
		NSString *regExMP = @"[^.0-9]+([0-9]{1,})[^.0-9]+";			
		NSString *myMPNumber = [[[temporaryMPArray objectAtIndex:1] allContents] stringByReplacingOccurrencesOfRegex:regExMP
																										  withString:@"$1"];
		
		[[HFRplusAppDelegate sharedAppDelegate] updateMPBadgeWithString:myMPNumber];
	}
	else {
		needToUpdateMP = YES;
	}
	
	//MP

	//Answer Topic URL
	HTMLNode * topicAnswerNode = [bodyNode findChildWithAttribute:@"id" matchingName:@"repondre_form" allowPartial:NO];
	topicAnswerUrl = [[NSString alloc] init];
	topicAnswerUrl = [[topicAnswerNode findChildTag:@"a"] getAttributeNamed:@"href"];
	//NSLog(@"new answer: %@", topicAnswerUrl);
	
	//form to fast answer
	[self setupFastAnswer:bodyNode];

    //prep' Poll view
    [self setupPoll:bodyNode andP:myParser];
    [self setupIntrSearch:bodyNode andP:myParser];

	//if(topicAnswerUrl.length > 0) 
	//-	

	//--Pages
	[self setupPageToolbar:bodyNode andP:myParser];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// Custom initialization
        //NSLog(@"init %@", theTopicUrl);
		self.currentUrl = [theTopicUrl copy];	
		self.loaded = NO;
		self.isViewed = YES;
        [self setIsSearchInstra:NO];
        self.errorReported = NO;

	}
	return self;
}

// Overidden to add a separator in the webview for some cases
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUrl:(NSString *)theTopicUrl displaySeparator:(BOOL)isSeparatorNewMessages {
    self.isSeparatorNewMessages = isSeparatorNewMessages;
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil andUrl:theTopicUrl];
}


-(void)textQuote:(id)sender {
    NSString *theSelectedText = [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString();"];

    NSString *baseElem = @"window.getSelection().anchorNode";
    int iProtection = 0;
    while ([[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]] rangeOfString:@"message"].location == NSNotFound) {
        //NSLog(@"baseElem %@", baseElem);
        //NSLog(@"%@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]]);
        iProtection++;
        if (iProtection > 100) return;
        baseElem = [baseElem stringByAppendingString:@".parentElement"];
    }
    NSLog(@"ID %@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]]);
    int curMsg = [[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]] intValue];


    NSLog(@"theSelectedText %@", theSelectedText);
    
    if (curMsg < 100) { // Id post BL sont >= 100
        [self quoteMessage:[NSString stringWithFormat:@"%@%@", [k ForumURL], [[[arrayData objectAtIndex:curMsg] urlQuote] decodeSpanUrlFromString]] andSelectedText:theSelectedText];
    }
}

-(void)textQuoteBold:(id)sender {
    NSString *theSelectedText = [self.messagesWebView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString();"];
    NSString *baseElem = @"window.getSelection().anchorNode";
    int iProtection = 0;
    while ([[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]] rangeOfString:@"message"].location == NSNotFound) {
        //NSLog(@"baseElem %@", baseElem);
        //NSLog(@"%@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.className", baseElem]]);
        iProtection++;
        if (iProtection > 100) return;
        baseElem = [baseElem stringByAppendingString:@".parentElement"];
    }
    NSLog(@"ID %@", [self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]]);
    int curMsg = [[self.messagesWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@.parentElement.id", baseElem]] intValue];

    NSLog(@"theSelectedText Bold %@", theSelectedText);
    
    if (curMsg < 100) { // Id post BL sont >= 100
        [self quoteMessage:[NSString stringWithFormat:@"%@%@", [k ForumURL], [[[arrayData objectAtIndex:curMsg] urlQuote] decodeSpanUrlFromString]] andSelectedText:theSelectedText withBold:YES];
    }
}

- (void)editMenuHidden:(id)sender {
    NSLog(@"editMenuHidden %@ NOMBRE %u", sender, [UIMenuController sharedMenuController].menuItems.count);
    
    UIImage *menuImgQuote = [UIImage imageNamed:@"ReplyArrowFilled-20"];
    UIImage *menuImgQuoteB = [UIImage imageNamed:@"BoldFilled-20"];
    
    
    UIMenuItem *textQuotinuum = [[UIMenuItem alloc] initWithTitle:@"Citerexclu" action:@selector(textQuote:) image:menuImgQuote];
    UIMenuItem *textQuotinuumBis = [[UIMenuItem alloc] initWithTitle:@"Citergras" action:@selector(textQuoteBold:) image:menuImgQuoteB];

    [self.arrayAction removeAllObjects];
    /*
    [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citerexclu", @"textQuote:", menuImgQuote, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];

    [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citergras", @"textQuoteBold:", menuImgQuoteB, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
    */
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:[NSArray arrayWithObjects:textQuotinuum, textQuotinuumBis, nil]];
    //[self.messagesWebView becomeFirstResponder];
//    [self becomeFirstResponder];

}

-(void)forceButtonMenu {
    if ([self.splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {

        [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;
 
    }
    else {
        UINavigationItem *navItem = [[[[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] viewControllers] objectAtIndex:0] navigationItem];

        [navItem setLeftBarButtonItem:((SplitViewController *)self.splitViewController).mybarButtonItem animated:YES];
        [navItem setLeftItemsSupplementBackButton:YES];
    }
    /* Evol onglet sticky (gardée au cas où)

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(removeTabBar)];*/
}

/* Evol onglet sticky (gardée au cas où)
-(void)removeTabBar {
    [HFRAlertView DisplayOKCancelAlertViewWithTitle:@"Onglet additionnel"
                                          andMessage:@"Fermer l'onglet ?"
                                          handlerOK:^(UIAlertAction * action) { [self removeTabBarConfirmed];}];
}

- (void)removeTabBarConfirmed {
    // Get viewControllers array and remove MessagesTable controller at index 2
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
    [viewControllers removeObjectAtIndex:2];
    [self.tabBarController setViewControllers:viewControllers animated:YES];
    [self.tabBarController setSelectedIndex:0];
*/


- (void)viewDidLoad {
	//NSLog(@"viewDidLoad %@", self.topicName);
    [super viewDidLoad];
	self.isAnimating = NO;

	self.title = self.topicName;  

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisibilityChanged:) name:@"VisibilityChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editMenuHidden:) name:UIMenuControllerDidHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userThemeDidChange)
                                                 name:kThemeChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(smileysSizeDidChange)
                                                 name:kSmileysSizeChangedNotification
                                               object:nil];
    
    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTextSizeDidChange) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(handleTap:)];
    [self.searchBg addGestureRecognizer:tapRecognizer];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
    
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // 
    
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setLineBreakMode:NSLineBreakByTruncatingMiddle];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [label setTextColor:[UIColor blackColor]];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [label setFont:[UIFont boldSystemFontOfSize:13.0]];
        }
        else {
            [label setFont:[UIFont boldSystemFontOfSize:17.0]];
        }
    }
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            [label setTextColor:[UIColor whiteColor]];
            label.shadowColor = [UIColor darkGrayColor];
            [label setFont:[UIFont boldSystemFontOfSize:13.0]];
            label.shadowOffset = CGSizeMake(0.0, -1.0);
            
            
        }
        else {
            [label setTextColor:[UIColor colorWithRed:113/255.f green:120/255.f blue:128/255.f alpha:1.00]];
            label.shadowColor = [UIColor whiteColor];
            [label setFont:[UIFont boldSystemFontOfSize:19.0]];
            label.shadowOffset = CGSizeMake(0.0, 0.5f);
            
        }
        
    }
    
    [label setNumberOfLines:2];
    
    [label setText:self.topicName];
    [label adjustFontSizeToFit];
    [self.navigationItem setTitleView:label];

    // fond blanc WebView
    [self.messagesWebView hideGradientBackground];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        [self.messagesWebView setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f]];
    }
    else
    {
        [self.messagesWebView setBackgroundColor:[UIColor whiteColor]];
    }
    
	//Gesture
	UIGestureRecognizer *recognizer;

	//De Gauche à droite
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToRight:)];
	self.swipeRightRecognizer = (UISwipeGestureRecognizer *)recognizer;
	
	//De Droite à gauche
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeToLeft:)];
	self.swipeLeftRecognizer = (UISwipeGestureRecognizer *)recognizer;
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.swipeLeftRecognizer = (UISwipeGestureRecognizer *)recognizer;
	//-- Gesture


	//Bouton Repondre message
    
    if (self.isSearchInstra) {
        UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchTopic)];
        optionsBarItem.enabled = NO;
        
        NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:optionsBarItem, nil];
        
        self.navigationItem.rightBarButtonItems = myButtonArray;
    }
    else {
        UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(optionsTopic:)];
        optionsBarItem.enabled = NO;
        
        NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:optionsBarItem, nil];
        
        self.navigationItem.rightBarButtonItems = myButtonArray;
    }
    

	[(ShakeView*)self.view setShakeDelegate:self];
	
	self.arrayAction = [[NSMutableArray alloc] init];
	self.arrayActionsMessages = [[NSMutableArray alloc] init];
    
	self.arrayData = [[NSMutableArray alloc] init];
	self.updatedArrayData = [[NSMutableArray alloc] init];
	self.arrayInputData = [[NSMutableDictionary alloc] init];
	self.editFlagTopic = [[NSString	alloc] init];
	self.stringFlagTopic = [[NSString	alloc] init];
	self.lastStringFlagTopic = [[NSString	alloc] init];

	self.isFavoritesOrRead = [[NSString	alloc] init];
	self.isUnreadable = NO;
	self.curPostID = -1;
	
    if (!self.searchInputData) {
        NSLog(@"NO searchInputData");
        self.searchInputData = [[NSMutableDictionary alloc] init];
    }

    
	[self setEditFlagTopic:nil];
	[self setStringFlagTopic:@""];

	[self fetchContent];
    [self editMenuHidden:nil];
    [self forceButtonMenu];
    //self.messagesWebView.controll = self;
}

-(void)fullScreen {
    [self fullScreen:nil];
}

-(void)fullScreen:(id)sender {
    
    if ([(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController respondsToSelector:@selector(MoveRightToLeft)]) {
        [(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController MoveRightToLeft];
    }
    
}
-(void)optionsTopic:(id)sender
{
    
    [self.arrayActionsMessages removeAllObjects];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if(self.topicAnswerUrl.length > 0)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Répondre", @"answerTopic", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_firstpage   = [defaults boolForKey:@"actionsmesages_firstpage"];
    if(actionsmesages_firstpage) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Première page", @"firstPage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_lastpage    = [defaults boolForKey:@"actionsmesages_lastpage"];
    if(actionsmesages_lastpage) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Dernière page", @"lastPage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_lastanswer  = [defaults boolForKey:@"actionsmesages_lastanswer"];
    if(actionsmesages_lastanswer) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Dernière réponse", @"lastAnswer", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_pagenumber  = [defaults boolForKey:@"actionsmesages_pagenumber"];
    if(actionsmesages_pagenumber && ([self lastPageNumber] > [self firstPageNumber])) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Page numéro...", @"choosePage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_toppage     = [defaults boolForKey:@"actionsmesages_toppage"];
    if(actionsmesages_toppage) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Haut de la page", @"goToPagePositionTop", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_bottompage  = [defaults boolForKey:@"actionsmesages_bottompage"];
    if(actionsmesages_bottompage) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Bas de la page", @"goToPagePositionBottom", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_poll  = [defaults boolForKey:@"actionsmesages_poll"];
    if(actionsmesages_poll && self.pollNode)
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Sondage", @"showPoll", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    BOOL actionsmesages_unread      = [defaults boolForKey:@"actionsmesages_unread"];
    if(actionsmesages_unread && self.isUnreadable) 
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Marquer comme non lu", @"markUnread", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    if (self.arrayActionsMessages.count == 0) {
        return;
    }
    
    [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Rechercher", @"searchTopic", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![self.parentViewController isMemberOfClass:[UINavigationController class]]) {
        
        [self.arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Navigateur✚", @"fullScreen", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
        
    }

    
    styleAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    
    for( NSDictionary *dico in arrayActionsMessages) {
        NSString* sActionTitle = [dico valueForKey:@"title"];
        UIAlertActionStyle styleAction = UIAlertActionStyleDefault;
        if (self.isNewPoll && [sActionTitle isEqualToString:@"Sondage"]) {
            styleAction = UIAlertActionStyleDestructive;
        }
        
        [styleAlert addAction:[UIAlertAction actionWithTitle:sActionTitle style:styleAction handler:^(UIAlertAction *action) {
            if ([self respondsToSelector:NSSelectorFromString([dico valueForKey:@"code"])])
            {
                //[self performSelector:];
                [self performSelectorOnMainThread:NSSelectorFromString([dico valueForKey:@"code"]) withObject:nil waitUntilDone:NO];
            }
            else {
                NSLog(@"CRASH not respondsToSelector %@", [dico valueForKey:@"code"]);
                
                [self performSelectorOnMainThread:NSSelectorFromString([dico valueForKey:@"code"]) withObject:nil waitUntilDone:NO];
            }
        }]];
    }

    // cancelButtonStyle not needed on iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Can't use UIAlertActionStyleCancel in dark theme : https://stackoverflow.com/a/44606994/1853603
        UIAlertActionStyle cancelButtonStyle = [[ThemeManager sharedManager] theme] == ThemeDark ? UIAlertActionStyleDefault : UIAlertActionStyleCancel;
        [styleAlert addAction:[UIAlertAction actionWithTitle:@"Annuler" style:cancelButtonStyle handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
    } else {
        // Required for UIUserInterfaceIdiomPad
        UIPopoverPresentationController *popPresenter = [styleAlert popoverPresentationController];
        popPresenter.barButtonItem = sender;
        popPresenter.backgroundColor = [ThemeColors alertBackgroundColor:[[ThemeManager sharedManager] theme]];
    }
    // Apply theme to UIAlertController
    [self presentViewController:styleAlert animated:YES completion:nil];    
    [[ThemeManager sharedManager] applyThemeToAlertController:styleAlert];
}

-(void)showPoll:(id)sender {
    [self showPoll];
}

-(void)showPoll {
    
    PollTableViewController *pollVC = [[PollTableViewController alloc] initWithPollNode:self.pollNode andParser:self.pollParser];
    pollVC.delegate = self;
    
    // Set options
    pollVC.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)

    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:pollVC];
    //nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    nc.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentModalViewController:nc animated:YES];
    
    
    //[self.navigationController pushViewController:browser animated:YES];
    
    
}

-(void)markUnread {
    ASIHTTPRequest  *delrequest =  
    [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [k ForumURL], self.isFavoritesOrRead]]];
    //delete
    
    [delrequest startSynchronous];
    
    //NSLog(@"arequest: %@", [arequest url]);
    
    if (delrequest) {
        if ([delrequest error]) {
            //NSLog(@"error: %@", [[arequest error] localizedDescription]);
        }
        else if ([delrequest responseString])
        {
            //NSLog(@"responseString: %@", [arequest responseString]);
            
            //[self reload];
            [[[HFRplusAppDelegate sharedAppDelegate] messagesNavController] popViewControllerAnimated:YES];
            [(TopicsTableViewController *)[[[HFRplusAppDelegate sharedAppDelegate] messagesNavController] visibleViewController] fetchContent];
        }
    }
    //NSLog(@"nonlu %@", self.isFavoritesOrRead);
}

-(void)goToPagePosition:(NSString *)position{
    NSString *script;
    
    if ([position isEqualToString:@"top"])
        script = @"$('html, body').animate({scrollTop:0}, 'slow');";
    else if ([position isEqualToString:@"bottom"])
        script = @"$('html, body').animate({scrollTop:$(document).height()}, 'slow');";
    else {
        script = @"";
    }

    [self.messagesWebView stringByEvaluatingJavaScriptFromString:script];
}
    
-(void)goToPagePositionTop{
    [self goToPagePosition:@"top"];
}
-(void)goToPagePositionBottom{
    [self goToPagePosition:@"bottom"];    
}


-(void)answerTopic
{
	
	while (self.isAnimating) {
        //NSLog(@"isAnimating");
		//return;
	}
    NSLog(@"answerTopic isOK");

    HFRNavigationController *navigationController;
    
     {
        NewMessageViewController *addMessageViewController = [[NewMessageViewController alloc]
                                                              initWithNibName:@"AddMessageViewController" bundle:nil];
         
         NSLog(@"answerTopic isOK 2");

         
        addMessageViewController.delegate = self;
        [addMessageViewController setUrlQuote:[NSString stringWithFormat:@"%@%@", [k ForumURL], topicAnswerUrl]];
        addMessageViewController.title = @"Nouv. Réponse";

        navigationController = [[HFRNavigationController alloc]
                                                         initWithRootViewController:addMessageViewController];
         
         NSLog(@"answerTopic isOK 3");

    }
		
	
	// Create the navigation controller and present it modally.

    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    NSLog(@"answerTopic isOK 4");

	[self presentModalViewController:navigationController animated:YES];
    

	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.

	//[[HFR_AppDelegate sharedAppDelegate] openURL:[NSString stringWithFormat:@"http://forum.hardware.fr%@", topicAnswerUrl]];

	//[[UIApplication sharedApplication] open-URL:[NSURL URLWithString:[NSString stringWithFormat:@"http://forum.hardware.fr/%@", topicAnswerUrl]]];
	
/*
	HFR_AppDelegate *mainDelegate = (HFR_AppDelegate *)[[UIApplication sharedApplication] delegate];
	[[mainDelegate rootController] setSelectedIndex:3];		
	[[(BrowserViewController *)[[mainDelegate rootController] selectedViewController] webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://forum.hardware.fr/%@", topicAnswerUrl]]]];		
 */
    
    NSLog(@"answerTopic isOK END");

}



-(void)searchTopic {

    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    

    [self toggleSearch];

}

-(void)quoteMessage:(NSString *)quoteUrl andSelectedText:(NSString *)selected withBold:(BOOL)boldSelection {
    if (self.isAnimating) {
        return;
    }
    
    QuoteMessageViewController *quoteMessageViewController = [[QuoteMessageViewController alloc]
                                                              initWithNibName:@"AddMessageViewController" bundle:nil];
    quoteMessageViewController.delegate = self;
    [quoteMessageViewController setUrlQuote:quoteUrl];
    [quoteMessageViewController setTextQuote:selected];
    [quoteMessageViewController setBoldQuote:boldSelection];
    
    // Create the navigation controller and present it modally.
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:quoteMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];
    
    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.
}

-(void)quoteMessage:(NSString *)quoteUrl andSelectedText:(NSString *)selected {
    [self quoteMessage:quoteUrl andSelectedText:selected withBold:NO];
}

-(void)quoteMessage:(NSString *)quoteUrl
{
    [self quoteMessage:quoteUrl andSelectedText:@""];
}

-(void)editMessage:(NSString *)editUrl
{
	if (self.isAnimating) {
		return;
	}
	
	EditMessageViewController *editMessageViewController = [[EditMessageViewController alloc]
															  initWithNibName:@"AddMessageViewController" bundle:nil];
	editMessageViewController.delegate = self;
	[editMessageViewController setUrlQuote:editUrl];
	
	// Create the navigation controller and present it modally.
	HFRNavigationController *navigationController = [[HFRNavigationController alloc]
													initWithRootViewController:editMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if(self.detailViewController) self.detailViewController = nil;
	if(self.messagesTableViewController) self.messagesTableViewController = nil;
    
    Theme theme = [[ThemeManager sharedManager] theme];
    self.view.backgroundColor = self.messagesTableViewController.view.backgroundColor = self.messagesWebView.backgroundColor = self.loadingView.backgroundColor = self.loadingViewLabel.backgroundColor = self.loadingViewIndicator.backgroundColor = self.searchBox.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.loadingViewIndicator.activityIndicatorViewStyle = [ThemeColors activityIndicatorViewStyle];
    self.loadingViewLabel.textColor = [ThemeColors cellTextColor:theme];
    self.loadingViewLabel.shadowColor = nil;
    [[ThemeManager sharedManager] applyThemeToTextField:self.searchPseudo];
    [[ThemeManager sharedManager] applyThemeToTextField:self.searchKeyword];
    self.searchPseudo.textColor = self.searchKeyword.textColor = [ThemeColors textColor:theme];
    self.searchPseudo.keyboardAppearance = [ThemeColors keyboardAppearance];
    self.searchKeyword.keyboardAppearance = [ThemeColors keyboardAppearance];
    if ([self.searchToolbar respondsToSelector:@selector(setBarTintColor:)]) {
        self.searchToolbar.barTintColor = [ThemeColors toolbarColor:theme];
    }
    
    self.searchBtnItem.tintColor = self.searchFilterBtnItem.tintColor = [ThemeColors tintColor:theme];
    self.searchBg.backgroundColor = [ThemeColors overlayColor:theme];
    self.searchLabel.textColor = [ThemeColors textColor:theme];
    
    self.messagesWebView.allowsLinkPreview = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	//NSLog(@"viewDidDisappear");

    [super viewDidDisappear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	// Get user preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
    
	if ([enabled isEqualToString:@"all"]) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}

}

- (void)didSelectMessage:(int)index
{
	{
		// Navigation logic may go here. Create and push another view controller.

		 if (self.detailViewController == nil) {
			 MessageDetailViewController *aView = [[MessageDetailViewController alloc] initWithNibName:@"MessageDetailViewControllerv2" bundle:nil];
			 self.detailViewController = aView;
		 }
		 
        // Pass the selected object to the new view controller.
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
            style: UIBarButtonItemStylePlain
            target:nil
            action:nil];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        
        label.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height - 4);
        
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // 
        
        [label setAdjustsFontSizeToFitWidth:YES];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setLineBreakMode:NSLineBreakByTruncatingMiddle];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [label setFont:[UIFont boldSystemFontOfSize:13.0]];
            }
            else {
                [label setFont:[UIFont boldSystemFontOfSize:17.0]];
            }
            [label setTextColor:[ThemeColors textColor:[[ThemeManager sharedManager] theme]]];
        }
        else
        {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [label setTextColor:[UIColor whiteColor]];
                label.shadowColor = [UIColor darkGrayColor];
                [label setFont:[UIFont boldSystemFontOfSize:13.0]];
                label.shadowOffset = CGSizeMake(0.0, -1.0);
                
                
            }
            else {
                [label setTextColor:[UIColor colorWithRed:113/255.f green:120/255.f blue:128/255.f alpha:1.00]];
                label.shadowColor = [UIColor whiteColor];
                [label setFont:[UIFont boldSystemFontOfSize:19.0]];
                label.shadowOffset = CGSizeMake(0.0, 0.5f);
                
            }
        }
        
        

        
        
        [label setNumberOfLines:0];
        
		[label setText:[NSString stringWithFormat:@"Page: %d — %d/%d", self.pageNumber, index + 1, arrayData.count]];
        
		[self.detailViewController.navigationItem setTitleView:label];
		///===
		
		 //setup the URL
		 //detailViewController.topicName = [[arrayData objectAtIndex:indexPath.row] name];	
		 
		 //NSLog(@"push message details");
		 // andContent:[arrayData objectAtIndex:indexPath.section]
		 
		 self.detailViewController.arrayData = arrayData;	
		 self.detailViewController.curMsg = index;	
		 self.detailViewController.pageNumber = self.pageNumber;	
		 self.detailViewController.parent = self;	
		 self.detailViewController.messageTitleString = self.topicName;	
		 
		 [self.navigationController pushViewController:detailViewController animated:YES];

	}
}

- (void) didSelectImage:(int)index withUrl:(NSString *)selectedURL {
	if (self.isAnimating) {
		return;
	}
	
	//On récupe les images du message:
	//NSLog(@"%@", [[arrayData objectAtIndex:index] toHTML:index]);
	//NSLog(@"selectedURL %@", selectedURL);
    // Ego quote not applyed on MP
    BOOL bIsMP = YES;
    if ([self.arrayInputData[@"cat"] isEqualToString: @"prive"]) {
        bIsMP = NO;
    }

	HTMLParser * myParser = [[HTMLParser alloc] initWithString:[[arrayData objectAtIndex:index] toHTML:index isMP:bIsMP] error:NULL];
	HTMLNode * msgNode = [myParser doc]; //Find the body tag

	NSArray * tmpImageArray =  [msgNode findChildrenWithAttribute:@"class" matchingName:@"hfrplusimg" allowPartial:NO];
	//NSLog(@"%d", [tmpImageArray count]);
	
	NSMutableArray * imageArray = [[NSMutableArray alloc] init];
	int selectedIndex = 0;
    
	for (HTMLNode * imgNode in tmpImageArray) { //Loop through all the tags
		//NSLog(@"======\nalt %@", [imgNode getAttributeNamed:@"alt"]);
        //NSLog(@"longdesc %@", [imgNode getAttributeNamed:@"longdesc"]);
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [imageArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[[imgNode getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@"reho.st/thumb/" withString:@"reho.st/"]]]];
        else
            [imageArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[[imgNode getAttributeNamed:@"alt"] stringByReplacingOccurrencesOfString:@"reho.st/thumb/" withString:@"reho.st/preview/"]]]];
            
            
        if ([selectedURL isEqualToString:[imgNode getAttributeNamed:@"alt"]]) {
            selectedIndex = [imageArray count] - 1;
        }
        
        /*
        
		[imageArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[imgNode getAttributeNamed:@"alt"], [imgNode getAttributeNamed:@"longdesc"], nil]  forKeys:[NSArray arrayWithObjects:@"alt", @"longdesc", nil]]];
        if ([selectedURL isEqualToString:[imgNode getAttributeNamed:@"alt"]]) {
            selectedIndex = [imageArray count] - 1;
        }
         */
        
	}
	
	//NSLog(@"selectedIndex %d", selectedIndex);
	// Create the root view controller for the navigation controller
	// The new view controller configures a Cancel and Done button for the
	// navigation bar.
	
    
    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:imageArray];
    // Set options
    browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
    [browser setInitialPageIndex:selectedIndex]; // Example: allows second image to be presented first
    // Present

    
    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    
    
    //[self.navigationController pushViewController:browser animated:YES];
    
}

#pragma mark -
#pragma mark searchNewMessages

-(void)searchNewMessages:(int)from {
    
	if (![self.messagesWebView isLoading]) {
        NSLog(@"SVPullToRefreshStateTriggeredSVPullToRefreshStateTriggeredSVPullToRefreshStateTriggeredSVPullToRefreshStateTriggered");
        UIImpactFeedbackGenerator *myGen = [[UIImpactFeedbackGenerator alloc] initWithStyle:(UIImpactFeedbackStyleLight)];
        [myGen impactOccurredWithDefaults];
        myGen = NULL;

		[self.messagesWebView stringByEvaluatingJavaScriptFromString:@"$('#actualiserbtn').addClass('loading');"];
        [self fetchContentinBackground:[NSNumber numberWithInt:from]];
		//[self performSelectorInBackground:@selector(fetchContentinBackground:) withObject:];
	}    
}

-(void)searchNewMessages {
	[self searchNewMessages:kNewMessageFromUnkwn];
}

- (void)fetchContentinBackground:(id)from {
        int intfrom = [from intValue];
        
        switch (intfrom) {
            case kNewMessageFromShake:
                [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
                break;
            case kNewMessageFromUpdate:
                [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
                break;
            case kNewMessageFromEditor:
                // le flag est mis à jour depuis l'editeur.
                break;
            default:
                [self setStringFlagTopic:[[self.arrayData lastObject] postID]]; // on flag sur le dernier message pour bien positionner après le rechargement.
                break;
        }
        
        [self fetchContent:intfrom];
}

#pragma mark -
#pragma mark Gestures

-(void) shakeHappened:(ShakeView*)view
{
    //NSLog(@"shake");
	if (![request inProgress] && !self.isLoading) {
        //NSLog(@"shake OK");
		[self searchNewMessages:kNewMessageFromShake];
	}
    else {
        //NSLog(@"shake KO");
    }
}

- (void)handleSwipeToLeft:(UISwipeGestureRecognizer *)recognizer {
    
    if (self.isSearchInstra) {
        NSLog(@"isSearchInstra");

        [self searchSubmit:nil];
    }
    else {
        NSLog(@"NEXT");

        [self nextPage:recognizer];
    }
}
- (void)handleSwipeToRight:(UISwipeGestureRecognizer *)recognizer {
    if (!self.isSearchInstra && (self.searchBg.alpha == 0.0 || self.searchBg.hidden == YES)) {
        [self previousPage:recognizer];
    }
}

#pragma mark -
#pragma mark AlerteModo Delegate

- (void)alertModoViewControllerDidFinish:(AlerteModoViewController *)controller {
    NSLog(@"alertModoViewControllerDidFinish");
    [self dismissModalViewControllerAnimated:YES];
}
- (void)alertModoViewControllerDidFinishOK:(AlerteModoViewController *)controller {
    NSLog(@"alertModoViewControllerDidFinishOK");
    [self dismissModalViewControllerAnimated:YES];

}

#pragma mark -
#pragma mark AddMessage Delegate
-(BOOL) canBeFavorite{
	if ([self isUnreadable]) {
		return NO;
	}
	
	
	return YES;
}

-(void)setupFastAnswer:(HTMLNode*)bodyNode
{
	HTMLNode * fastAnswerNode = [bodyNode findChildWithAttribute:@"name" matchingName:@"hop" allowPartial:NO];
	NSArray *temporaryInputArray = [fastAnswerNode findChildrenWithAttribute:@"type" matchingName:@"hidden" allowPartial:YES];
	
	//HTMLNode * inputNode;
	for (HTMLNode * inputNode in temporaryInputArray) { //Loop through all the tags
		//NSLog(@"inputNode: %@ - value: %@", [inputNode getAttributeNamed:@"name"], [inputNode getAttributeNamed:@"value"]);
		[self.arrayInputData setObject:[inputNode getAttributeNamed:@"value"] forKey:[inputNode getAttributeNamed:@"name"]];
		
	}
	
	self.isRedFlagged = NO;
	
	//Fav/Unread
	HTMLNode * FlagNode = [bodyNode findChildWithAttribute:@"href" matchingName:@"delflag" allowPartial:YES];
	self.isFavoritesOrRead =  @"";

	if (FlagNode) {
		self.isFavoritesOrRead = [FlagNode getAttributeNamed:@"href"];
		if ([FlagNode findChildWithAttribute:@"src" matchingName:@"flagn0.gif" allowPartial:YES]) {
			self.isRedFlagged = YES;
		}
        
        //NSLog(@"FlagNode %d", self.isRedFlagged);
	}
	else {
		HTMLNode * ReadNode = [bodyNode findChildWithAttribute:@"href" matchingName:@"nonlu" allowPartial:YES];
		if (ReadNode) {
			self.isFavoritesOrRead = [ReadNode getAttributeNamed:@"href"];
			self.isUnreadable = YES;			
		}
		else {
			self.isFavoritesOrRead =  @"";	
		}
        
        //NSLog(@"!FlagNode %@", self.isFavoritesOrRead);
        //NSLog(@"!FlagNode %d", self.isUnreadable);
	}
}
//--form to fast answer	

- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller {
    //NSLog(@"addMessageViewControllerDidFinish %@", self.editFlagTopic);

	[self setEditFlagTopic:nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller {
	NSLog(@"addMessageViewControllerDidFinishOK");
    
    [self.navigationController popToViewController:self animated:NO];

    [self dismissViewControllerAnimated:NO completion:^{
        if (self.arrayData.count > 0) {
            //NSLog(@"curid %d", self.curPostID);
            NSString *components = [[[self.arrayData objectAtIndex:0] quoteJS] substringFromIndex:7];
            components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
            components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];
            NSArray *quoteComponents = [components componentsSeparatedByString:@","];
            NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
            [self EffaceCookie:nameCookie];
        }
        
        self.curPostID = -1;
        [self setStringFlagTopic:[[controller refreshAnchor] copy]];
        NSLog(@"addMessageViewControllerDidFinishOK stringFlagTopic %@", self.stringFlagTopic);
        [self searchNewMessages:kNewMessageFromEditor];
    }];

    // Check if user is teletubbiesed
    NSLog(@"TT test? response is :%@", controller.statusMessage);
    if (controller.statusMessage != nil && [controller.statusMessage rangeOfString:@"télétubbies"].location != NSNotFound) {
        [HFRAlertView DisplayAlertViewWithTitle:@"Tu es TT !" andMessage:controller.statusMessage forDuration:2 completion:^{
                [[HFRplusAppDelegate sharedAppDelegate] openURL:kTTURL];}];
    } else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Hooray !"
                                                                       message:controller.statusMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:^{
            dispatch_after(250000, dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        [[ThemeManager sharedManager] applyThemeToAlertController:alert];

    }
}

#pragma mark -
#pragma mark Parse Operation Delegate

// -------------------------------------------------------------------------------
//	handleLoadedApps:notif
// -------------------------------------------------------------------------------

- (void)handleLoadedApps:(NSArray *)loadedItems
{
    
	[self.arrayData removeAllObjects];
	[self.arrayData addObjectsFromArray:loadedItems];


	NSString *tmpHTML = @"";
    
    NSLog(@"COUNT = %lu", (unsigned long)[self.arrayData count]);
    
    if (!self.isSearchInstra && self.arrayData.count == 0 && !self.errorReported) {
        self.errorReported = YES;
    }

    if (self.isSearchInstra && self.arrayData.count == 0) {
        NSLog(@"BZAAAAA %@", self.currentUrl);
        [self.loadingView setHidden:YES];
        [self.messagesWebView setHidden:YES];
        [self.errorLabelView setText:@"Désolé aucune réponse n'a été trouvée"];
        [self.errorLabelView setHidden:NO];
        [self toggleSearch:YES];
    }
    else {
        int i;
        NSLog(@"OLD %@", self.stringFlagTopic);

        NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        int currentFlagValue = [[self.stringFlagTopic stringByTrimmingCharactersInSet:nonDigits] intValue];
        bool ifCurrentFlag = NO;
        int closePostID = 0;
        
        if(!currentFlagValue) { //si pas de value on cherche soit le premier message (pas de flag) soit le dernier (#bas)
            NSLog(@"!currentFlagValue");
            
            ifCurrentFlag = YES;
        }

        NSLog(@"Looking for %d", currentFlagValue);
        //NSLog(@"==============");
        
        // Ego quote not applyed on MP
        BOOL bIsMP = YES;
        if ([self.arrayInputData[@"cat"] isEqualToString: @"prive"]) {
            bIsMP = NO;
        }
        
        for (i = 0; i < [self.arrayData count]; i++) { //Loop through all the tags
            NSString* sNewMessage = [[self.arrayData objectAtIndex:i] toHTML:i isMP:bIsMP];
            tmpHTML = [tmpHTML stringByAppendingString:sNewMessage];

            if (!ifCurrentFlag) {
                int tmpFlagValue = [[[[self.arrayData objectAtIndex:i] postID] stringByTrimmingCharactersInSet:nonDigits] intValue];

                if (tmpFlagValue == currentFlagValue) {
                    if (self.isSeparatorNewMessages == YES) {
                        // Add separator  (but not after last post of page)
                        if (i < [self.arrayData count] - 1) {
                            tmpHTML = [tmpHTML stringByAppendingString:@"<div class=\"separator1\"></div>"];
                        }
                    }
                    ifCurrentFlag = YES;
                    closePostID = tmpFlagValue;
                }

                //NSLog(@"pas encore trouvé");
                
                if (closePostID && currentFlagValue && tmpFlagValue >= currentFlagValue) {
                    //NSLog(@"On a trouvé plus grand, on set");
                    closePostID = tmpFlagValue;
                    ifCurrentFlag = YES;
                }
                else {
                    //NSLog(@"0, on set le premier");
                    closePostID = tmpFlagValue;
                }
                
            }
        }
        
        if (closePostID) {
            //NSLog(@"On remplace au plus proche");
            self.stringFlagTopic = [NSString stringWithFormat:@"#t%d", closePostID];
        }
        
        NSLog(@"NEW %@", self.stringFlagTopic);

        // On ajoute le bouton de notif de sondage
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"notify_poll_not_answered"] && self.isNewPoll) {
            UIBarButtonItem* optionsBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icone_action"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsTopic:)];
            UIBarButtonItem* pollBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icone_sondage"] style:UIBarButtonItemStylePlain target:self action:@selector(showPoll:)];
            self.navigationItem.rightBarButtonItems = [[NSMutableArray alloc] initWithObjects:optionsBarItem, pollBarItem, nil];
        } else {
            UIBarButtonItem* optionsBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icone_action"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsTopic:)];
            self.navigationItem.rightBarButtonItems = [[NSMutableArray alloc] initWithObjects:optionsBarItem, nil];
        }
        
        NSString *refreshBtn = @"";
        //on ajoute le bouton actualiser si besoin
        if (([self pageNumber] == [self lastPageNumber]) || ([self lastPageNumber] == 0)) {
            //NSLog(@"premiere et unique ou dernier");
            //'before'
            refreshBtn = @"<div id=\"actualiserbtn\" onClick=\"window.location = 'oijlkajsdoihjlkjasdorefresh://data'; return false;\">Actualiser</div>";

        }
        else {
            //NSLog(@"autre");
        }
        
        NSString *tooBar = @"";
        
        //Toolbar;
        if (self.aToolbar && !self.isSearchInstra) {
            NSString *buttonBegin, *buttonEnd;
            NSString *buttonPrevious, *buttonNext;
            
            if ([(UIBarButtonItem *)[self.aToolbar.items objectAtIndex:0] isEnabled]) {
                buttonBegin = @"<div class=\"button begin active\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://begin\">begin</a></div>";
                buttonPrevious = @"<div class=\"button2 begin active\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://previous\">previous</a></div>";
            }
            else {
                buttonBegin = @"<div class=\"button begin\"></div>";
                buttonPrevious = @"<div class=\"button2 begin\"></div>";
            }
            
            if ([(UIBarButtonItem *)[self.aToolbar.items objectAtIndex:4] isEnabled]) {
                buttonEnd = @"<div class=\"button end active\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://end\">end</a></div>";
                buttonNext = @"<div class=\"button2 end active\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://next\">next</a></div>";
            }
            else {
                buttonEnd = @"<div class=\"button end\"></div>";
                buttonNext = @"<div class=\"button2 end\"></div>";
            }
            
            
            //[NSString stringWithString:@"<div class=\"button end\" ontouchstart=\"$(this).addClass(\\'hover\\')\" ontouchend=\"$(this).removeClass(\\'hover\\')\" ><a href=\"oijlkajsdoihjlkjasdoauto://end\">end</a></div>"];
            
            tooBar =  [NSString stringWithFormat:@"<div id=\"toolbarpage\">\
                       %@\
                       %@\
                       <a href=\"oijlkajsdoihjlkjasdoauto://choose\">%d/%d</a>\
                       %@\
                       %@\
                       </div>", buttonBegin, buttonPrevious, [self pageNumber], [self lastPageNumber], buttonNext, buttonEnd];
        }
        else if (self.isSearchInstra) {
            tooBar = [NSString stringWithFormat:@"<a href=\"oijlkajsdoihjlkjasdoauto://submitsearch\" id=\"searchintra_nextbutton\">Résultats suivants &raquo;</a>"];
        }
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *display_sig = [defaults stringForKey:@"display_sig"];
        
        NSString *display_sig_css = @"nosig";
        
        if ([display_sig isEqualToString:@"yes"]) {
            display_sig_css = @"";
        }
        
        NSString *doubleSmileysCSS = @"";
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_smileys"] isEqualToString:@"double"]) {
            doubleSmileysCSS = @".smileycustom {max-height:45px;}";
        }

        
        
        NSString *customFontSize = [self userTextSizeDidChange];
        Theme theme = [[ThemeManager sharedManager] theme];

        /*<link type='text/css' rel='stylesheet %@' href='style-liste-retina.css' id='light-styles-retina' media='all and (-webkit-min-device-pixel-ratio: 2)'/>\
        <link type='text/css' rel='stylesheet %@' href='style-liste-dark.css' id='dark-styles'/>\
        <link type='text/css' rel='stylesheet %@' href='style-liste-retina-dark.css' id='dark-styles-retina' media='all and (-webkit-min-device-pixel-ratio: 2)'/>\
        <link type='text/css' rel='stylesheet %@' href='style-liste-oled.css' id='oled-styles'/>\
        <link type='text/css' rel='stylesheet %@' href='style-liste-retina-oled.css' id='oled-styles-retina' media='all and (-webkit-min-device-pixel-ratio: 2)'/>\ */

        
        NSString* sCssStyle = @"style-liste.css";
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"theme_style"] == 1) {
            sCssStyle = @"style-liste-light.css";
        }

        // Default value for light theme
        NSString *sAvatarImageFile = @"url(avatar_male_gray_on_light_48x48.png)";
        NSString *sLoadInfoImageFile = @"url(loadinfo.gif)";
        NSString* sBorderHeader = @"none";
        
        // Modified in theme Dark or OLED
        if (theme == ThemeDark) {
            sAvatarImageFile = @"url(avatar_male_gray_on_dark_48x48.png)";
            sLoadInfoImageFile = @"url(loadinfo-white@2x.gif)";
        }
        
        
        NSString *HTMLString = [NSString
                                stringWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\
                                <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" lang=\"fr\">\
                                <head>\
                                <script type='text/javascript' src='jquery-2.1.1.min.js'></script>\
                                <script type='text/javascript' src='jquery.doubletap.js'></script>\
                                <script type='text/javascript' src='jquery.base64.js'></script>\
                                <meta name='viewport' content='initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no' />\
                                <link type='text/css' rel='stylesheet' href='%@' id='light-styles'/>\
                                <style type='text/css'>\
                                %@\
                                </style>\
                                <style id='smileys_double' type='text/css'>\
                                %@\
                                </style>\
                                </head><body class='iosversion'><a name='top' id='top'></a>\
                                <div class='bunselected %@' id='qsdoiqjsdkjhqkjhqsdqdilkjqsd2'>\
                                %@\
                                </div>\
                                %@\
                                %@\
                                <div id='endofpage'></div>\
                                <div id='endofpagetoolbar'></div>\
                                <a name='bas'></a>\
                                <script type='text/javascript'>\
                                document.addEventListener('DOMContentLoaded', loadedML);\
                                document.addEventListener('touchstart', touchstart);\
                                function loadedML() { setTimeout(function() {document.location.href = 'oijlkajsdoihjlkjasdoloaded://loaded';},700); };\
                                function toggleDiv(id) { $(id).slideToggle('slow'); };\
                                function HLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bselected'; }\
                                function UHLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bunselected'; }\
                                function swap_spoiler_states(obj){var div=obj.getElementsByTagName('div');if(div[0]){if(div[0].style.visibility==\"visible\"){div[0].style.visibility='hidden';}else if(div[0].style.visibility==\"hidden\"||!div[0].style.visibility){div[0].style.visibility='visible';}}}\
                                $('img').error(function(){ $(this).attr('src', 'photoDefaultfailmini.png');});\
                                function touchstart() { document.location.href = 'oijlkajsdoihjlkjasdotouch://touchstart'};\
                                document.documentElement.style.setProperty('--color-action', '%@');\
                                document.documentElement.style.setProperty('--color-action-disabled', '%@');\
                                document.documentElement.style.setProperty('--color-message-background', '%@');\
                                document.documentElement.style.setProperty('--color-message-modo-background', '%@');\
                                document.documentElement.style.setProperty('--color-message-header-me-background', '%@');\
                                document.documentElement.style.setProperty('--color-message-mequoted-background', '%@');\
                                document.documentElement.style.setProperty('--color-message-mequoted-borderleft', '%@');\
                                document.documentElement.style.setProperty('--color-message-mequoted-borderother', '%@');\
                                document.documentElement.style.setProperty('--color-message-header-love-background', '%@');\
                                document.documentElement.style.setProperty('--color-message-quoted-love-background', '%@');\
                                document.documentElement.style.setProperty('--color-message-quoted-love-borderleft', '%@');\
                                document.documentElement.style.setProperty('--color-message-quoted-love-borderother', '%@');\
                                document.documentElement.style.setProperty('--color-message-quoted-bl-background', '%@');\
                                document.documentElement.style.setProperty('--color-message-header-bl-background', '%@');\
                                document.documentElement.style.setProperty('--color-separator-new-message', '%@');\
                                document.documentElement.style.setProperty('--color-text', '%@');\
                                document.documentElement.style.setProperty('--color-text2', '%@');\
                                document.documentElement.style.setProperty('--color-background-bars', '%@');\
                                document.documentElement.style.setProperty('--color-searchintra-nextresults', '%@');\
                                document.documentElement.style.setProperty('--imagefile-avatar', '%@');\
                                document.documentElement.style.setProperty('--imagefile-loadinfo', '%@');\
                                document.documentElement.style.setProperty('--color-border-quotation', '%@');\
                                document.documentElement.style.setProperty('--color-border-avatar', '%@');\
                                document.documentElement.style.setProperty('--color-text-pseudo', '%@');\
                                document.documentElement.style.setProperty('--color-text-pseudo-bl', '%@');\
                                document.documentElement.style.setProperty('--border-header', '%@');\
                                </script>\
                                </body></html>",
                                sCssStyle, customFontSize,doubleSmileysCSS, display_sig_css, tmpHTML, refreshBtn, tooBar,
                                [ThemeColors hexFromUIColor:[ThemeColors tintColor:theme]], //--color-action
                                [ThemeColors hexFromUIColor:[ThemeColors tintColorDisabled:theme]], //--color-action-disabled
                                [ThemeColors hexFromUIColor:[ThemeColors messageBackgroundColor:theme]], //--color-message-background
                                [ThemeColors hexFromUIColor:[ThemeColors messageModoBackgroundColor:theme]], //--color-message-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.1], // -color-message-header-me-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.03], // color-message-mequoted-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:1],  //--color-message-mequoted-borderleft
                                [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.1],  //--color-message-mequoted-borderother
                                /*[ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.7], //--color-message-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.8], // --color-message-header-me-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0 addSaturation:0.6],  //--color-message-mequoted-borderleft
                                [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0],  //--color-message-mequoted-borderother*/
                                [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.4], //--color-message-header-love-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.3], // --color-message-header-me-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0 addSaturation:1 addBrightness:1],  //--color-message-mequoted-borderleft
                                [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.1 addSaturation:1], //--color-message-mequoted-borderother
                                [ThemeColors rgbaFromUIColor:[ThemeColors textColor:theme] withAlpha:0.05],  //--color-message-quoted-bl-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors textFieldBackgroundColor:theme] withAlpha:0.7],  //--color-message-header-bl-background
                                [ThemeColors rgbaFromUIColor:[ThemeColors textColorPseudo:theme] withAlpha:0.5],  //--color-separator-new-message
                                [ThemeColors hexFromUIColor:[ThemeColors textColor:theme]], //--color-text
                                [ThemeColors hexFromUIColor:[ThemeColors textColor2:theme]], //--color-text2
                                [ThemeColors hexFromUIColor:[ThemeColors textFieldBackgroundColor:theme]], //--color-background-bars
                                [ThemeColors rgbaFromUIColor:[ThemeColors textFieldBackgroundColor:theme] withAlpha:0.9], //--color-searchintra-nextresults
                                sAvatarImageFile,
                                sLoadInfoImageFile,
                                [ThemeColors getColorBorderQuotation:theme],
                                [ThemeColors hexFromUIColor:[ThemeColors getColorBorderAvatar:theme]],
                                [ThemeColors hexFromUIColor:[ThemeColors textColorPseudo:theme]],
                                [ThemeColors rgbaFromUIColor:[ThemeColors textColorPseudo:theme] withAlpha:0.5],
                                sBorderHeader
                                ];
        
        
        if (self.isSearchInstra) {
            HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7 searchintra"];
        }
        else {
            HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7"];
        }
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];

        /*
        NSLog(@"======================================================================================================");
        NSLog(@"HTMLString %@", HTMLString);
        NSLog(@"======================================================================================================");
        NSLog(@"baseURL %@", baseURL);
        NSLog(@"======================================================================================================");
        */
        self.loaded = NO;
        [self.messagesWebView loadHTMLString:HTMLString baseURL:baseURL];
        
        [self.messagesWebView setUserInteractionEnabled:YES];
    }
}

- (void)handleLoadedParser:(HTMLParser *)myParser
{
	[self loadDataInTableView:myParser];
}	

// -------------------------------------------------------------------------------
//	didFinishParsing:appList
// -------------------------------------------------------------------------------
- (void)didStartParsing:(HTMLParser *)myParser
{
    [self performSelectorOnMainThread:@selector(handleLoadedParser:) withObject:myParser waitUntilDone:NO];
}

- (void)didFinishParsing:(NSArray *)appList
{
    [self performSelectorOnMainThread:@selector(handleLoadedApps:) withObject:appList waitUntilDone:NO];
    self.queue = nil;
}

#pragma mark -
#pragma mark WebView Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
	NSLog(@"== webViewDidStartLoad");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Update flag
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"mpstorage_active"] && [self.arrayInputData[@"cat"] isEqualToString: @"prive"] && self.isSearchInstra == NO) {
        NSNumber* nPage = [NSNumber numberWithInt: self.pageNumber];
        NSNumber* nPost = [NSNumber numberWithInt: [self.arrayInputData[@"post"] intValue]];

        NSInteger nPageCurrentFlag = [[MPStorage shared] getPageFlagForTopidId:[nPost intValue]];
        // Only update flag if page is more recent
        if (self.pageNumber >= nPageCurrentFlag ) {
            NSString* sTPostID = [[self.arrayData lastObject] postID];
            NSString* sP = self.arrayInputData[@"p"];
            NSString* sURI = [NSString stringWithFormat:@"https://forum.hardware.fr/forum2.php?config=hfr.inc&cat=prive&post=%@&page=%@&p=%@&sondage=0&owntopic=0&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#%@", self.arrayInputData[@"post"], self.arrayInputData[@"page"], sP, sTPostID];
            //NSLog(@"====================================================================");
            //NSLog(@"UPDATE FLAG: nPage %@, nPageCurrentFlag %d", nPage, nPageCurrentFlag);
            //NSLog(@"====================================================================");
            NSDictionary* newFlag = [NSDictionary dictionaryWithObjectsAndKeys: nPost, @"post", sP, @"p", sTPostID, @"href", nPage, @"page", sURI, @"uri", nil];
            [[MPStorage shared] updateMPFlagAsynchronous:newFlag];
        }
    }
}

- (void)webViewDidFinishPreLoadDOM {
    NSLog(@"== webViewDidFinishPreLoadDOM");

    //[self userTextSizeDidChange];
}

- (void)webViewDidFinishLoadDOM
{
    NSLog(@"== webViewDidFinishLoadDOM");
    
    if (!self.pageNumber) {
        return;
    }
    
    if (!self.loaded) {
        NSLog(@"== First DOM");
        self.loaded = YES;

        NSString* jsString2 = @"";
        NSString* jsString3 = @"";

        if (SYSTEM_VERSION_LESS_THAN(@"11")) {
            jsString2 = @"window.location.hash='#bas';";
            jsString3 = [NSString stringWithFormat:@"window.location.hash='%@';", ![self.stringFlagTopic isEqualToString:@""] ? self.stringFlagTopic : @"#top"];
        
        }
        else {
            jsString2 = @"window.scrollTo(0,document.getElementById('endofpagetoolbar').offsetTop);";
            jsString3 = [NSString stringWithFormat:@"window.scrollTo(0,document.getElementById('%@').offsetTop);", ![self.stringFlagTopic isEqualToString:@""] ? [self.stringFlagTopic stringByReplacingOccurrencesOfString:@"#" withString:@""] : @"top"];

        }
        //Position du Flag
        
        NSString* result = [self.messagesWebView stringByEvaluatingJavaScriptFromString:[jsString2 stringByAppendingString:jsString3]];


        NSLog(@"jsString2 %@", jsString2);
        NSLog(@"jsString3 %@", jsString3);
        NSLog(@"result %@", result);
        
        self.lastStringFlagTopic = self.stringFlagTopic;
        self.stringFlagTopic = @"";
        
        [self.loadingView setHidden:YES];
        [self.messagesWebView setHidden:NO];
        [self.messagesWebView becomeFirstResponder];

        NSString *jsString = @"";

        jsString = [jsString stringByAppendingString:@"$('.message').addSwipeEvents().bind('doubletap', function(evt, touch) { window.location = 'oijlkajsdoihjlkjasdodetails://'+this.id; });"];
        [self.messagesWebView stringByEvaluatingJavaScriptFromString:jsString];
        return;
    }
        
    NSLog(@"== DOMed");
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"== webViewDidFinishLoad");
    
    //if (!self.loaded) {
    //    [self webViewDidFinishPreLoadDOM];
    //}
    
    [self webViewDidFinishLoadDOM];
    
//    [webView.scrollView setContentSize: CGSizeMake(300, webView.scrollView.contentSize.height)];
    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
/*
https://forum.hardware.fr/forum2.php?config=hfr.inc&cat=13&subcat=430&post=61179&page=57043&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t57321037
 */

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSLog(@"MTV %@ nbS=%lu", NSStringFromSelector(action), [UIMenuController sharedMenuController].menuItems.count);
    
    BOOL returnA;
    
    if ((action == @selector(textQuote:) || action == @selector(textQuoteBold:)) && ([self.searchKeyword isFirstResponder] || [self.searchPseudo isFirstResponder]) ) {
        returnA = NO;
    } else {
        returnA = [super canPerformAction:action withSender:sender];
    }

    NSLog(@"MTV returnA %d", returnA);
    return returnA;
}

- (BOOL) canBecomeFirstResponder {
	NSLog(@"===== canBecomeFirstResponder");
	
    return NO;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	//NSLog(@"expected:%ld, got:%ld | url:%@", (long)UIWebViewNavigationTypeLinkClicked, (long)navigationType, aRequest.URL);

	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString* sRegExUrlProfil = @"profil-[0-9]+.htm";
        NSPredicate *testProfilUrl = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", sRegExUrlProfil];

		if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoauto"]) {
			[self goToPage:[[aRequest.URL absoluteString] lastPathComponent]];
			return NO;
		}
		else if ([[aRequest.URL scheme] isEqualToString:@"file"]) {
            
            if ([[[aRequest.URL pathComponents] objectAtIndex:0] isEqualToString:@"/"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {

                OnlineMessagesTableViewController *aView = [[OnlineMessagesTableViewController alloc] initWithNibName:@"OnlineMessagesTableViewController" bundle:nil andUrl:[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
                self.messagesTableViewController = aView;
                
                //setup the URL
                self.messagesTableViewController.topicName = @"";
                self.messagesTableViewController.isViewed = YES;	

                self.navigationItem.backBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:[self backBarButtonTitle]
                                                 style: UIBarButtonItemStylePlain
                                                target:nil
                                                action:nil];
                
                [self.navigationController pushViewController:messagesTableViewController animated:YES];
            }
            

            
           // NSLog(@"clicked [[aRequest.URL absoluteString] %@", [aRequest.URL absoluteString]);
          //  NSLog(@"clicked [[aRequest.URL pathComponents] %@", [aRequest.URL pathComponents]);
          //  NSLog(@"clicked [[aRequest.URL path] %@", [aRequest.URL path]);
          //  NSLog(@"clicked [[aRequest.URL lastPathComponent] %@", [aRequest.URL lastPathComponent]);
            
			return NO;
		}
        else if ([[aRequest.URL host] isEqualToString:@"forum.hardware.fr"] && [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"] && [testProfilUrl evaluateWithObject: [[aRequest.URL pathComponents] objectAtIndex:2]]) {
            ProfilViewController *profilVC = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil andUrl:[aRequest.URL path]];
            
            // Set options
            profilVC.wantsFullScreenLayout = YES;
            
            HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:profilVC];
            nc.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self presentModalViewController:nc animated:YES];
            return NO;
        }
        else if ([[aRequest.URL host] isEqualToString:@"forum.hardware.fr"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {
                
            NSLog(@"%@", aRequest.URL);
            NSString *sUrl = [[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", [k ForumURL]] withString:@""] stringByReplacingOccurrencesOfString:@"http://forum.hardware.fr" withString:@""];
            NSLog(@"%@", sUrl);

            
            OnlineMessagesTableViewController *aView = [[OnlineMessagesTableViewController alloc] initWithNibName:@"OnlineMessagesTableViewController" bundle:nil andUrl:[[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", [k ForumURL]] withString:@""] stringByReplacingOccurrencesOfString:@"http://forum.hardware.fr" withString:@""]];
            self.messagesTableViewController = aView;
            
            //setup the URL
            self.messagesTableViewController.topicName = @"";
            self.messagesTableViewController.isViewed = YES;

            self.navigationItem.backBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:[self backBarButtonTitle]
                                             style: UIBarButtonItemStylePlain
                                            target:nil
                                            action:nil];
            
            [self.navigationController pushViewController:messagesTableViewController animated:YES];

            return NO;
        }
		else {
			NSURL *url = aRequest.URL;
			NSString *urlString = url.absoluteString;
			
			[[HFRplusAppDelegate sharedAppDelegate] openURL:urlString];
			return NO;
		}

	}
	else if (navigationType == UIWebViewNavigationTypeOther) {
		if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdodetails"]) {
            int iPostId = [[[aRequest.URL absoluteString] lastPathComponent] intValue];
            if (iPostId < 100) {
                [self didSelectMessage:iPostId];
            }
			return NO;
		}
		else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdotouch"]) {
			// cache le menu controller dès que l'utilisateur touche la WebView
            if ([[[aRequest.URL absoluteString] lastPathComponent] isEqualToString:@"touchstart"]) {
                if ([UIMenuController sharedMenuController].isMenuVisible) {
                    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
                }
            }
			return NO;
		}
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdopreloaded"]) {
            [self webViewDidFinishPreLoadDOM];
            return NO;
        }
		else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoloaded"]) {
			[self webViewDidFinishLoadDOM];
			return NO;
		}
		else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdorefresh"]) {
			[self searchNewMessages:kNewMessageFromUpdate];
			return NO;
		}
		else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdopopup"]) {
			//NSLog(@"oijlkajsdoihjlkjasdopopup");
            NSArray<NSString *> *pathComponents = [[aRequest.URL absoluteString] pathComponents];
            int xpos = [[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:0] intValue];
            int ypos = [[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:1] intValue];
			int curMsg = [[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:2] intValue];
			NSLog(@"%d %d %d", xpos, ypos, curMsg);

			[self performSelector:@selector(showMenuCon:andPos:) withObject:[NSNumber numberWithInt:curMsg]  withObject:[NSNumber numberWithInt:ypos]];
			return NO;
		}
        else if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoimbrows"]) {
            NSString *regularExpressionString = @"oijlkajsdoihjlkjasdoimbrows://[^/]+/(.*)";
            
            NSString *imgUrl = [[[[aRequest.URL absoluteString] stringByMatching:regularExpressionString capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [self didSelectImage:[[[[aRequest.URL absoluteString] pathComponents] objectAtIndex:1] intValue] withUrl:imgUrl];

            return NO;
        }
        else {
            
            NSLog(@"OTHHHHERRRREEE %@ %@", [aRequest.URL scheme], [aRequest.URL fragment]);
            if ([[aRequest.URL fragment] isEqualToString:@"bas"]) {
                //return NO;
            }

        }
        
        
	}
    else {
        NSLog(@"VRAIMENT OTHHHHERRRREEE %@ %@", [aRequest.URL scheme], [aRequest.URL fragment]);

    }
    
	return YES;
}

-(NSString*) backBarButtonTitle {
    int iCount = 0;
    // Compte le nombre de controllers OnlineMessagesTableViewController en partant de la fin
    for (UIViewController* vc in [[self.navigationController viewControllers] reverseObjectEnumerator])
    {
        if ([vc isKindOfClass:[OnlineMessagesTableViewController class]]) {
            iCount++;
        } else {
            // Stop counting when different controller
            break;
        }
    }
    return [NSString stringWithFormat: @"%d", iCount];
}

-(void) showMenuCon:(NSNumber *)curMsgN andPos:(NSNumber *)posN {
	
	[self.arrayAction removeAllObjects];
	
	int curMsg = [curMsgN intValue];
	int ypos = [posN intValue];
	
    
    NSString *answString = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        answString = @"Répondre";
    }
    else
    {
        answString = @"Rép.";
    }
    
    UIImage *menuImgBan = [UIImage imageNamed:@"ThorHammer-20"];
    if ([[BlackList shared] isBL:[[arrayData objectAtIndex:curMsg] name]]) {
        menuImgBan = [UIImage imageNamed:@"ThorHammerFilled-20"];
    }
    UIImage *menuImgWL = [UIImage imageNamed:@"Heart-20"];

    UIImage *menuImgEdit = [UIImage imageNamed:@"EditColumnFilled-20"];
    UIImage *menuImgProfil = [UIImage imageNamed:@"ContactCardFilled-20"];
    UIImage *menuImgQuote = [UIImage imageNamed:@"ReplyArrowFilled-20"];
    UIImage *menuImgMP = [UIImage imageNamed:@"MessageFilled-20"];
    UIImage *menuImgFav = [UIImage imageNamed:@"StarFilled-20"];

    //UIImage *menuImgMultiQuoteChecked = [UIImage imageNamed:@"QuoteFilled-20"];
    //UIImage *menuImgMultiQuoteUnchecked = [UIImage imageNamed:@"Quote-20"];

    UIImage *menuImgMultiQuoteChecked = [UIImage imageNamed:@"ReplyAllArrowFilled-20"];
    UIImage *menuImgMultiQuoteUnchecked = [UIImage imageNamed:@"ReplyAllArrow-20"];

    UIImage *menuImgDelete = [UIImage imageNamed:@"DeleteColumnFilled-20"];
    UIImage *menuImgAlerte = [UIImage imageNamed:@"HighPriorityFilled-20"];
    UIImage *menuImgAQ = [UIImage imageNamed:@"08-chat-20"];

	if([[arrayData objectAtIndex:curMsg] urlEdit]){
		//NSLog(@"urlEdit");
		[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Editer", @"EditMessage", menuImgEdit, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        
        if (curMsg) { //Pas de suppression du premier message d'un topic (curMsg = 0);
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Supprimer", @"actionSupprimer", menuImgDelete, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }

		if (self.navigationItem.rightBarButtonItem.enabled) {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:answString, @"QuoteMessage", menuImgQuote, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
		}
	}
	else {
		//NSLog(@"profil");
		if (self.navigationItem.rightBarButtonItem.enabled) {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:answString, @"QuoteMessage", menuImgQuote, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
		}
	}

	//"Citer ☑"@"Citer ☒"@"Citer ☐"
	if([[arrayData objectAtIndex:curMsg] quoteJS] && self.navigationItem.rightBarButtonItem.enabled) {
		NSString *components = [[[arrayData objectAtIndex:curMsg] quoteJS] substringFromIndex:7];
		components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
		components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];
		
		NSArray *quoteComponents = [components componentsSeparatedByString:@","];
		
		NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
		NSString *quotes = [self LireCookie:nameCookie];
		
		if ([quotes rangeOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]].location == NSNotFound) {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☐", @"actionCiter", menuImgMultiQuoteUnchecked, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
			
		}
		else {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☑", @"actionCiter", menuImgMultiQuoteChecked, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
		}
	}

    if ([self canBeFavorite]) {
        //NSLog(@"isRedFlagged ★");
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Favoris", @"actionFavoris", menuImgFav, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
    }
    
    if(![[arrayData objectAtIndex:curMsg] urlEdit]){
        if([[arrayData objectAtIndex:curMsg] urlAlert]){
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Alerter", @"actionAlerter", menuImgAlerte, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }
    }

    [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Profil", @"actionProfil", menuImgProfil, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];

    if(![[arrayData objectAtIndex:curMsg] urlEdit]){
        if([[arrayData objectAtIndex:curMsg] MPUrl]){
            [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"MP", @"actionMessage", menuImgMP, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        }
        
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Blacklist", @"actionBL", menuImgBan, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Whitelist", @"actionWL", menuImgWL, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
    }
    
    // AQ (sauf dans les MPs)
    if (![self.arrayInputData[@"cat"] isEqualToString: @"prive"]) {
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"AQ", @"actionAQ", menuImgAQ, nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", @"image", nil]]];
    }
    
	self.curPostID = curMsg;
	
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	NSMutableArray *menuAction = [[NSMutableArray alloc] init];
    
	for (id tmpAction in self.arrayAction) {
		NSLog(@"%@", [tmpAction objectForKey:@"code"]);
		
        if ([tmpAction objectForKey:@"image"] != nil) {
            UIMenuItem *tmpMenuItem2 = [[UIMenuItem alloc] initWithTitle:[tmpAction valueForKey:@"title"] action:NSSelectorFromString([tmpAction objectForKey:@"code"]) image:(UIImage *)[tmpAction objectForKey:@"image"]];
            [menuAction addObject:tmpMenuItem2];
        }
        else {
            UIMenuItem *tmpMenuItem = [[UIMenuItem alloc] initWithTitle:[tmpAction valueForKey:@"title"] action:NSSelectorFromString([tmpAction objectForKey:@"code"])];
            [menuAction addObject:tmpMenuItem];
        }

	}	
	[menuController setMenuItems:menuAction];

    if (ypos < 40) {
		ypos +=34;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7,0")) {
            ypos +=10;
        }
		[menuController setArrowDirection:UIMenuControllerArrowUp];
	}
	else {
		[menuController setArrowDirection:UIMenuControllerArrowDown];
	}
    
	CGRect selectionRect = CGRectMake(38, ypos, 0, 0);
	
	[self.view setNeedsDisplayInRect:selectionRect];
	[menuController setTargetRect:selectionRect inView:self.view];
	[menuController setMenuVisible:YES animated:YES];
}

#pragma mark -
#pragma mark sharedMenuController management


-(void)actionFavoris:(NSNumber *)curMsgN {
	int curMsg = [curMsgN intValue];
    
	ASIHTTPRequest  *aRequest =  
	[[ASIHTTPRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [k ForumURL], [[arrayData objectAtIndex:curMsg] addFlagUrl]]]];
    
    
    [aRequest setStartedBlock:^{
        // Ajout d'un favori en cours
    }];
    
    __weak ASIHTTPRequest*aRequest_ = aRequest;

    [aRequest setCompletionBlock:^{
        NSString *responseString = [aRequest_ responseString];
        responseString = [responseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        NSString *regExMsg = @".*<div class=\"hop\">([^<]+)</div>.*";
        NSPredicate *regExErrorPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExMsg];
        BOOL isRegExMsg = [regExErrorPredicate evaluateWithObject:responseString];
        
        if (isRegExMsg) {
            /*
            //KO
            //NSLog(@"%@", [responseString stringByMatching:regExMsg capture:1L]);
  //          usleep(1000000);
//            [alert dismissWithClickedButtonIndex:0 animated:NO];
//            [alert dismissWithClickedButtonIndex:0 animated:NO];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[responseString stringByMatching:regExMsg capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                           delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            alert.tag = 6666;

            
            [alert show];
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            // Adjust the indicator so it is up a few pixels from the bottom of the alert
            indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
            [indicator startAnimating];
            [alert addSubview:indicator];
            NSLog(@"Show Alerte");*/
            [HFRAlertView DisplayAlertViewWithTitle:[[responseString stringByMatching:regExMsg capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forDuration:1];
        }
    }];
    
    [aRequest setFailedBlock:^{
        //[alert dismissWithClickedButtonIndex:0 animated:0];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Hmmm" message:[[aRequest_ error] localizedDescription]
                                                       delegate:self cancelButtonTitle:@":(" otherButtonTitles: nil];
        alert.tag = 666;
    
        [alert show];
    }];
    
    [aRequest startSynchronous];
	
}
-(void)actionProfil:(NSNumber *)curMsgN {
    int curMsg = [curMsgN intValue];

    ProfilViewController *profilVC = [[ProfilViewController alloc] initWithNibName:@"ProfilViewController" bundle:nil andUrl:[[arrayData objectAtIndex:curMsg] urlProfil]];
    
    // Set options
    profilVC.wantsFullScreenLayout = YES;
    
    HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:profilVC];
    nc.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:nc animated:YES];
}

- (void)actionAQ:(NSNumber *)curMsgN {
    NSString* sTPostID = [[arrayData objectAtIndex:[curMsgN intValue]] postID];
    NSString *sPostId = [sTPostID substringWithRange:NSMakeRange(1, [sTPostID length]-1)];
    NSString* sTopicId = self.arrayInputData[@"post"];
    NSString *sRequest = [NSString stringWithFormat:@"http://alerte-qualitay.toyonos.info/api/getAlertesByTopic.php5?topic_id=%@", sTopicId];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sRequest]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:2];

    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * dataReq = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error != nil) {
        [HFRAlertView DisplayAlertViewWithTitle:@"Erreur réseau" andMessage:@"Création d'AQ impossible" forDuration:1];
        return;
    }
    
    // Parse data
    //TODO
    //http://alerte-qualitay.toyonos.info/api/getAlertesByTopic.php5?topic_id=25135
    /*
     <alertes>
     <alerte id="13331" nom="Test" pseudoInitiateur="ezzz" date="05-03-2019" postsIds="5934515"/>
     <alerte id="13330" nom="Best of photos 2018" pseudoInitiateur="ezzz" date="04-03-2019" postsIds="5934515"/>
     </alertes>
     */
    NSString* sData = [[NSString alloc] initWithData:dataReq encoding:NSUTF8StringEncoding];
    if ([sData containsString:sPostId]) {
        [HFRAlertView DisplayAlertViewWithTitle:@"Post déjà signalé" andMessage:nil forDuration:1];
        return;
    }
    
    int curMsg = [curMsgN intValue];
    NSLog("AQ link URL = %@%@#%@", [k ForumURL], self.currentUrl, [[arrayData objectAtIndex:curMsg] postID]);
    
    NSString* sAuthor = [[arrayData objectAtIndex:curMsg] name];
    NSString* sMessage = [NSString stringWithFormat:@"Créer une Alerte Qualitay sur le post de %@", sAuthor];
    // Popup retry
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Alerte Qualitay ?" message:sMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Ajoutez un titre";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
        [[ThemeManager sharedManager] applyThemeToTextField:textField];
        textField.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
        //ftextField.borderStyle = UITextBorderStyleNone;
    }];


    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) { }];
    self.actionCreateAQ = [UIAlertAction actionWithTitle:@"Créer" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     NSString* sTitle = alert.textFields.firstObject.text;
                                                     [self createAQ:curMsgN withTitle:sTitle]; }];
    [alert addAction:actionCancel];
    [alert addAction:self.actionCreateAQ];
    [self.actionCreateAQ setEnabled:false];

    [self presentViewController:alert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
    for (UIView* textfield in alert.textFields) {
        UIView *container = textfield.superview;
        UIView *effectView = container.superview.subviews[0];
        
        if (effectView && [effectView class] == [UIVisualEffectView class]){
            container.backgroundColor = [UIColor clearColor];
            [effectView removeFromSuperview];
        }
    }
}

-(void)textDidChange:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self.actionCreateAQ setEnabled:YES];
    } else {
        [self.actionCreateAQ setEnabled:NO];
    }
}

-(void)createAQ:(NSNumber *)curMsgN withTitle:(NSString*) sTitle {
    NSString* sAuthor = [[arrayData objectAtIndex:[curMsgN intValue]] name];
    NSString* sComment = [NSString stringWithFormat:@"post de %@", sAuthor];
    NSString* sTPostID = [[arrayData objectAtIndex:[curMsgN intValue]] postID];
    NSString* sURL = [NSString stringWithFormat:@"%@%@#%@", [k ForumURL], self.currentUrl, sTPostID];
    MultisManager *manager = [MultisManager sharedManager];
    NSDictionary *mainCompte = [manager getMainCompte];
    NSString *sCurrentPseudo = [[mainCompte objectForKey:PSEUDO_DISPLAY_KEY] lowercaseString];
    NSString *sPostId = [sTPostID substringWithRange:NSMakeRange(1, [sTPostID length]-1)];

    NSLog("====================================== AQ =======================================");
    NSLog("nom (titre AQ): %@", sTitle);
    NSLog("topic_id: %@", self.arrayInputData[@"post"]);
    NSLog("topic_titre: %@", self.topicName);
    NSLog("pseudo: %@", sCurrentPseudo);
    NSLog("post_id: %@", sPostId);
    NSLog("post_url: %@", sURL);
    NSLog("commentaire: %@", sComment);

    NSString *sParametersCreateAQ = [NSString stringWithFormat:@"alerte_qualitay_id=-1&nom=%@&topic_id=%@&topic_titre=%@&pseudo=%@&post_id=%@&post_url=%@&commentaire=%@",
                             [self addPercentEncodingURL:sTitle],
                             [self addPercentEncodingURL:self.arrayInputData[@"post"]],
                             [self addPercentEncodingURL:self.topicName],
                             [self addPercentEncodingURL:sCurrentPseudo],
                             [self addPercentEncodingURL:sPostId],
                             [self addPercentEncodingURL:sURL],
                             [self addPercentEncodingURL:sComment]];

    

    NSLog("====================================== Req AQ ===================================");
    NSLog("parameters: %@", sParametersCreateAQ);
    NSLog("====================================== Post AQ ==================================");

    /*alerte_qualitay_id: -1 <- l'id d'une aq existante (pour signaler plusieurs fois le même message) ou -1 pour une nouvelle aq (le premier champ de la popup de création dans le script)
     nom: test1 <- le titre de l'aq à créer (le deuxième champ de la popup de création) texte libre
     topic_id: 61999 <- le numero du topic (dans sa cat)
     topic_titre: BashHFr <- le titre du topic (il recup le titre dans le h3 de la case sujet de la table des messages)
     pseudo: roger21 <- il recup le pseudal mais rien n'est sécurisé, n'importe qui peut faire une aq au nom de n'importe qui ...
     post_id: 55767559 <- le numéro du message à aq
     post_url: https%3A%2F%2Fforum.hardware.fr%2Fforum2.php%3Fconfig%3Dhfr.inc%26cat%3D13%26subcat%3D432%26post%3D61999%26page%3D2681%26p%3D1%26sondage%3D0%26owntopic%3D1%26trash%3D0%26trash_post%3D0%26print%3D0%26numreponse%3D0%26quote_only%3D0%26new%3D0%26nojs%3D0%23t55767559 <- l'url complète du message à aq (tout bien encodée là)
     commentaire: test2 <- le commentaire (le 3eme champ de la popup de création) texte libre aussi*/
    /*
     URL:http://alerte-qualitay.toyonos.info/api/addAlerte.php5?
    
     Parameters example:
        alerte_qualitay_id=-1&
        nom=Best%20of%20photos%202018&
        topic_id=25135&
        topic_titre=%5BTU%5D%20Best%20of%202018&
        pseudo=kapitain&
        post_id=5934515&
        post_url=https%3A%2F%2Fforum.hardware.fr%2Fhfr%2FPhotonumerique%2FPhotos%2Funique-best-2018-sujet_25135_1.htm%23t5934515&
        commentaire=post%20de%20deniks
    */
    
    NSData *postData = [sParametersCreateAQ dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%ld",[postData length]];
    NSURL *url = [NSURL URLWithString:@"http://alerte-qualitay.toyonos.info/api/addAlerte.php5"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                          timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSError *error;
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
    NSLog("response: %@ (1=OK)", responseString);
    NSLog("====================================== /AQ ======================================");

    if ([responseString isEqualToString:@"1"]) {
        [HFRAlertView DisplayAlertViewWithTitle:@"Hooray !" andMessage:@"Alerte Qualitay créée." forDuration:(long)1];
    } else {
        NSString* sMessage = [NSString stringWithFormat:@"Code erreur %@", responseString];
        [HFRAlertView DisplayAlertViewWithTitle:@"Oups !" andMessage:sMessage forDuration:(long)1];
    }
}

 - (NSString*)addPercentEncodingURL:(NSString*) sURL {
     return [sURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._-"]];
 }

-(void)actionLink:(NSNumber *)curMsgN {
    int curMsg = [curMsgN intValue];
    
    //NSLog("actionLink ID = %@", [[arrayData objectAtIndex:curMsg] postID]);
    NSLog("actionLink URL = %@%@#%@", [k ForumURL], self.currentUrl, [[arrayData objectAtIndex:curMsg] postID]);
    
    
    //Topic *tmpTopic = [[[self.arrayData objectAtIndex:[indexPath section]] topics] objectAtIndex:[indexPath row]];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%@%@#%@", [k RealForumURL], self.currentUrl, [[arrayData objectAtIndex:curMsg] postID]];
        
    [HFRAlertView DisplayAlertViewWithTitle:@"Lien copié dans le presse-papiers" forDuration:(long)1];
}

-(void) actionAlerter:(NSNumber *)curMsgN {
    NSLog(@"actionAlerter %@", curMsgN);
    if (self.isAnimating) {
        return;
    }
    
    int curMsg = [curMsgN intValue];
    
    NSString *alertUrl = [NSString stringWithFormat:@"%@%@", [k ForumURL], [[arrayData objectAtIndex:curMsg] urlAlert]];
    
    AlerteModoViewController *alerteMessageViewController = [[AlerteModoViewController alloc]
                                                             initWithNibName:@"AlerteModoViewController" bundle:nil];
    alerteMessageViewController.delegate = self;
    [alerteMessageViewController setUrl:alertUrl];
    
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:alerteMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];

    
    
}
-(void) actionSupprimer:(NSNumber *)curMsgN {
    NSLog(@"actionSupprimer %@", curMsgN);
    if (self.isAnimating) {
        return;
    }

    int curMsg = [curMsgN intValue];
    
    NSString *editUrl = [NSString stringWithFormat:@"%@%@", [k ForumURL], [[[arrayData objectAtIndex:curMsg] urlEdit] decodeSpanUrlFromString]];
    NSLog(@"DEL editUrl = %@", editUrl);
    
    DeleteMessageViewController *delMessageViewController = [[DeleteMessageViewController alloc]
                                                              initWithNibName:@"AddMessageViewController" bundle:nil];
    delMessageViewController.delegate = self;
    [delMessageViewController setUrlQuote:editUrl];
    
    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                     initWithRootViewController:delMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navigationController animated:YES];

}

-(void) actionBL:(NSNumber *)curMsgN {
    int curMsg = [curMsgN intValue];
    NSString *pseudo = [[arrayData objectAtIndex:curMsg] name];
    NSString *promptMsg = @"";
    
    if ([[BlackList shared] isBL:pseudo]) {
        BOOL ret = [[BlackList shared] removeFromBlackList:pseudo andSave:YES];
        if (ret) {
            promptMsg = [NSString stringWithFormat:@"%@ a été supprimé de la liste noire", pseudo];
        } else {
            promptMsg = [NSString stringWithFormat:@"Erreur! %@ n'a pas pu être supprimé de la liste noire", pseudo];
        }
    }
    else {
        BOOL ret = [[BlackList shared] addToBlackList:pseudo andSave:YES];
        if (ret > 0) {
            promptMsg = [NSString stringWithFormat:@"BIM! %@ ajouté à la liste noire", pseudo];
        }
        else {
            promptMsg = [NSString stringWithFormat:@"Erreur! %@ n'a pas pu être ajouté à la liste noire", pseudo];
        }
    }
    
    [HFRAlertView DisplayAlertViewWithTitle:promptMsg forDuration:(long)1];
}

-(void) actionWL:(NSNumber *)curMsgN {
    int curMsg = [curMsgN intValue];
    NSString *pseudo = [[arrayData objectAtIndex:curMsg] name];
    NSString *promptMsg = @"";
    
    if ([[BlackList shared] isWL:pseudo]) {
        [[BlackList shared] removeFromWhiteList:pseudo];
        promptMsg = [NSString stringWithFormat:@"OH NOES ! %@ a été supprimé de la love list", pseudo];
    }
    else {
        [[BlackList shared] addToWhiteList:pseudo];
        promptMsg = [NSString stringWithFormat:@"BOUM BOUM ! %@ ajouté à la love list \u2665", pseudo];
    }

    
    [HFRAlertView DisplayAlertViewWithTitle:promptMsg forDuration:(long)1];
}


-(void)actionMessage:(NSNumber *)curMsgN {
	if (self.isAnimating) {
		return;
	}
	
	int curMsg = [curMsgN intValue];
	
	//NSLog(@"actionMessage %d = %@", curMsg, curMsgN);
	//[[HFRplusAppDelegate sharedAppDelegate] openURL:[NSString stringWithFormat:@"http://forum.hardware.fr%@", forumNewTopicUrl]];
	
	NewMessageViewController *editMessageViewController = [[NewMessageViewController alloc]
														   initWithNibName:@"AddMessageViewController" bundle:nil];
	editMessageViewController.delegate = self;
	[editMessageViewController setUrlQuote:[NSString stringWithFormat:@"%@%@", [k ForumURL], [[arrayData objectAtIndex:curMsg] MPUrl]]];
	editMessageViewController.title = @"Nouv. Message";
	// Create the navigation controller and present it modally.
	HFRNavigationController *navigationController = [[HFRNavigationController alloc]
													initWithRootViewController:editMessageViewController];
    
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
    
	// The navigation controller is now owned by the current view controller
	// and the root view controller is owned by the navigation controller,
	// so both objects should be released to prevent over-retention.
}

-(void) EcrireCookie:(NSString *)nom withVal:(NSString *)valeur {
	//NSLog(@"EcrireCookie");
	
	NSMutableDictionary *	outDict = [NSMutableDictionary dictionaryWithCapacity:5];
	[outDict setObject:nom forKey:NSHTTPCookieName];
	[outDict setObject:valeur forKey:NSHTTPCookieValue];
	[outDict setObject:[[NSDate date] dateByAddingTimeInterval:(60*60)] forKey:NSHTTPCookieExpires];
	[outDict setObject:@".hardware.fr" forKey:NSHTTPCookieDomain];
	[outDict setObject:@"/" forKey:@"Path"];		// This does work.
	
	NSHTTPCookie	*	cookie = [NSHTTPCookie cookieWithProperties:outDict];
	
	NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	[cookShared setCookie:cookie];
}

-(NSString *)LireCookie:(NSString *)nom {
	//NSLog(@"LireCookie");
	
	
	NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookShared cookies];
	
	for (NSHTTPCookie *aCookie in cookies) {
		if ([[aCookie name] isEqualToString:nom]) {
			
			if ([[NSDate date] timeIntervalSinceDate:[aCookie expiresDate]] <= 0) {
				return [aCookie value];
			}
			
		}
		
	}
	
	return @"";
	
}
-(void)  EffaceCookie:(NSString *)nom {
	//NSLog(@"EffaceCookie");
	
	NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	NSArray *cookies = [cookShared cookies];
	
	for (NSHTTPCookie *aCookie in cookies) {
		if ([[aCookie name] isEqualToString:nom]) {
			[cookShared deleteCookie:aCookie];
		}
		
	}
	
	return;
}


-(void)actionCiter:(NSNumber *)curMsgN {
	//NSLog(@"actionCiter %@", curMsgN);
	
	int curMsg = [curMsgN intValue];
	NSString *components = [[[arrayData objectAtIndex:curMsg] quoteJS] substringFromIndex:7];
	components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
	components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];
	
	NSArray *quoteComponents = [components componentsSeparatedByString:@","];
	
	NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
	NSString *quotes = [self LireCookie:nameCookie];
	
	//NSLog(@"quotes APRES LECTURE %@", quotes);
	
	if ([quotes rangeOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]].location == NSNotFound) {
		quotes = [quotes stringByAppendingString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]];
	}
	else {
		quotes = [quotes stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]] withString:@""];
	}
	
	
	if (quotes.length == 0) {
		//
		//NSLog(@"quote vide");
		[self EffaceCookie:nameCookie];
	}
	else
	{
		//NSLog(@"nameCookie %@", nameCookie);
		//NSLog(@"quotes %@", quotes);
		[self EcrireCookie:nameCookie withVal:quotes];
	}
	
	//[self.messageView stringByEvaluatingJavaScriptFromString:@"quoter('hardwarefr','prive',1556872,1962548600);"];
	//NSLog(@"actionCiter %@", [NSDate date]);
	
	//NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	//NSArray *cookies = [cookShared cookies];
	
	//for (NSHTTPCookie *aCookie in cookies) {
	//	NSLog(@"%@", aCookie);
	//}
	
	
}

-(void)EditMessage:(NSNumber *)curMsgN {
	int curMsg = [curMsgN intValue];
	
	[self setEditFlagTopic:[[arrayData objectAtIndex:curMsg] postID]];
	[self editMessage:[NSString stringWithFormat:@"%@%@", [k ForumURL], [[[arrayData objectAtIndex:curMsg] urlEdit] decodeSpanUrlFromString]]];
	
}

-(void)QuoteMessage:(NSNumber *)curMsgN {
	int curMsg = [curMsgN intValue];
	
	[self quoteMessage:[NSString stringWithFormat:@"%@%@", [k ForumURL], [[[arrayData objectAtIndex:curMsg] urlQuote] decodeSpanUrlFromString]]];
}

-(void)actionFavoris {
	[self actionFavoris:[NSNumber numberWithInt:curPostID]];
	
}
-(void)actionProfil {
    [self actionProfil:[NSNumber numberWithInt:curPostID]];
    
}
-(void)actionAQ {
    [self actionAQ:[NSNumber numberWithInt:curPostID]];
    
}
-(void)actionMessage {
	[self actionMessage:[NSNumber numberWithInt:curPostID]];
	
}
-(void)actionBL {
    [self actionBL:[NSNumber numberWithInt:curPostID]];
    
}
-(void)actionWL {
    [self actionWL:[NSNumber numberWithInt:curPostID]];
    
}
-(void)actionAlerter {
    [self actionAlerter:[NSNumber numberWithInt:curPostID]];
    
}
-(void)actionSupprimer {
    [self actionSupprimer:[NSNumber numberWithInt:curPostID]];
    
}

-(void)actionCiter {
	[self actionCiter:[NSNumber numberWithInt:curPostID]];
}

-(void)actionLink {
    [self actionLink:[NSNumber numberWithInt:curPostID]];
}

-(void)EditMessage {
	[self EditMessage:[NSNumber numberWithInt:curPostID]];	
}

-(void)QuoteMessage
{
	[self QuoteMessage:[NSNumber numberWithInt:curPostID]];
}

- (NSString *) userTextSizeDidChange {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_text"] isEqualToString:@"sys"]) {
        if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
            CGFloat userFontSize = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody].pointSize;
            userFontSize = floorf(userFontSize*0.90);
            NSString *script = [NSString stringWithFormat:@"$('.message .content .right').css('cssText', 'font-size:%fpx !important');", userFontSize];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right table.code *').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right p.editedhfrlink').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            
            [self.messagesWebView stringByEvaluatingJavaScriptFromString:script];
            
            return [NSString stringWithFormat:@".message .content .right { font-size:%fpx !important; }", userFontSize];
            
            //NSLog(@"userFontSize %@", script);
        }
    }
    
    return @"";
    
}

- (NSString *) userThemeDidChange {
    Theme theme = [[ThemeManager sharedManager] theme];

    NSString *sAvatarImageFile = @"url(avatar_male_gray_on_light_48x48.png)";
    NSString *sLoadInfoImageFile = @"url(loadinfo.gif)";
    NSString* sBorderHeader = @"none";
    
    // Modified in theme Dark or OLED
    if (theme == ThemeDark) {
        sAvatarImageFile = @"url(avatar_male_gray_on_dark_48x48.png)";
        sLoadInfoImageFile = @"url(loadinfo-white@2x.gif)";
    }
    
    NSString *script = [NSString stringWithFormat:@"\
                    document.documentElement.style.setProperty('--color-action', '%@');\
                    document.documentElement.style.setProperty('--color-action-disabled', '%@');\
                    document.documentElement.style.setProperty('--color-message-background', '%@');\
                    document.documentElement.style.setProperty('--color-message-modo-background', '%@');\
                    document.documentElement.style.setProperty('--color-message-header-me-background', '%@');\
                    document.documentElement.style.setProperty('--color-message-mequoted-background', '%@');\
                    document.documentElement.style.setProperty('--color-message-mequoted-borderleft', '%@');\
                    document.documentElement.style.setProperty('--color-message-mequoted-borderother', '%@');\
                    document.documentElement.style.setProperty('--color-message-header-love-background', '%@');\
                    document.documentElement.style.setProperty('--color-message-quoted-love-background', '%@');\
                    document.documentElement.style.setProperty('--color-message-quoted-love-borderleft', '%@');\
                    document.documentElement.style.setProperty('--color-message-quoted-love-borderother', '%@');\
                    document.documentElement.style.setProperty('--color-message-quoted-bl-background', '%@');\
                    document.documentElement.style.setProperty('--color-message-header-bl-background', '%@');\
                    document.documentElement.style.setProperty('--color-separator-new-message', '%@');\
                        document.documentElement.style.setProperty('--color-text', '%@');\
                        document.documentElement.style.setProperty('--color-text2', '%@');\
                        document.documentElement.style.setProperty('--color-background-bars', '%@');\
                        document.documentElement.style.setProperty('--color-searchintra-nextresults', '%@');\
                        document.documentElement.style.setProperty('--imagefile-avatar', '%@');\
                        document.documentElement.style.setProperty('--imagefile-loadinfo', '%@');\
                        document.documentElement.style.setProperty('--color-border-quotation', '%@');\
                        document.documentElement.style.setProperty('--color-border-avatar', '%@');\
                        document.documentElement.style.setProperty('--color-text-pseudo', '%@');\
                        document.documentElement.style.setProperty('--color-text-pseudo-bl', '%@');\
                        document.documentElement.style.setProperty('--border-header', '%@');",
                        [ThemeColors hexFromUIColor:[ThemeColors tintColor:theme]], //--color-action
                        [ThemeColors hexFromUIColor:[ThemeColors tintColorDisabled:theme]], //--color-action-disabled
                        [ThemeColors hexFromUIColor:[ThemeColors messageBackgroundColor:theme]], //--color-message-background
                        [ThemeColors hexFromUIColor:[ThemeColors messageModoBackgroundColor:theme]], //--color-message-modo-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.1], //--color-message-header-me-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.03], //--color-message-mequoted-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:1],  //--color-message-mequoted-borderleft
                        [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.1],  //--color-message-mequoted-borderother
                        /*[ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.7], //--color-message-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.8], // --color-message-header-me-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0 addSaturation:0.6],  //--color-message-mequoted-borderleft
                        [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0],  //--color-message-mequoted-borderother*/
                        [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.4], //--color-message-header-love-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.3], // --color-message-header-me-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0 addSaturation:1 addBrightness:1],  //--color-message-lovecolor-borderleft
                        [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.1 addSaturation:1], //--color-message-mequoted-borderother
                        [ThemeColors rgbaFromUIColor:[ThemeColors textColor:theme] withAlpha:0.05],  //--color-message-quoted-bl-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors textFieldBackgroundColor:theme] withAlpha:0.7],  //--color-message-header-bl-background
                        [ThemeColors rgbaFromUIColor:[ThemeColors textColorPseudo:theme] withAlpha:0.5],  //--color-separator-new-message
                        [ThemeColors hexFromUIColor:[ThemeColors textColor:theme]], //--color-text
                        [ThemeColors hexFromUIColor:[ThemeColors textColor2:theme]], //--color-text2
                        [ThemeColors hexFromUIColor:[ThemeColors textFieldBackgroundColor:theme]], //--color-background-bars
                        [ThemeColors rgbaFromUIColor:[ThemeColors textFieldBackgroundColor:theme] withAlpha:0.9], //--color-searchintra-nextresults
                        sAvatarImageFile,
                        sLoadInfoImageFile,
                        [ThemeColors getColorBorderQuotation:theme],
                        [ThemeColors hexFromUIColor:[ThemeColors getColorBorderAvatar:theme]],
                        [ThemeColors hexFromUIColor:[ThemeColors textColorPseudo:theme]],
                        [ThemeColors rgbaFromUIColor:[ThemeColors textColorPseudo:theme] withAlpha:0.5],
                        sBorderHeader];

    [self.messagesWebView stringByEvaluatingJavaScriptFromString:script];
    
    return @"";
}


- (void)smileysSizeDidChange {
    NSString *script = @"document.getElementById('smileys_double').disabled = true;";
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_smileys"] isEqualToString:@"double"]) {
        script = @"document.getElementById('smileys_double').disabled = false;";
    }
    [self.messagesWebView stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	NSLog(@"viewDidUnload Messages Table View");
	
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	
	self.loadingView = nil;
    self.errorLabelView = nil;
    
	[self.messagesWebView stopLoading];
	self.messagesWebView.delegate = nil;
	self.messagesWebView = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	

    [self setSearchFromFP:nil];
    [self setSearchFilter:nil];
	[super viewDidUnload];
	
	
}

- (void)dealloc {
	NSLog(@"dealloc Messages Table View");
	
	[self viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VisibilityChanged" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSmileysSizeChangedNotification object:nil];

    
    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    }


	[self.queue cancelAllOperations];
	
	[request cancel];
	[request setDelegate:nil];
	
	self.topicName = nil;
	
    
	//[self.arrayData removeAllObjects];
	self.arrayData = nil;
	self.updatedArrayData = nil;

	
	
    
    
		
	
    
    
	
}

#pragma mark -
#pragma mark Search Lifecycle

-(void)handleTap:(id)sender{
    [self toggleSearch:NO];
}

- (void)toggleSearch {
    
    if (self.searchBg.alpha && !self.searchBg.hidden)
        [self toggleSearch:NO];
    else
        [self toggleSearch:YES];
    
}

- (void)toggleSearch:(BOOL) active {
    //NSLog(@"toggleSearchtoggleSearchtoggleSearchtoggleSearch");
    if (!active) {
        //NSLog(@"RESIGN");
        CGRect oldframe = self.searchBox.frame;
        //NSLog(@"oldframe %@", NSStringFromCGRect(oldframe));
        
        CGRect newframe = oldframe;
        newframe.origin.y = 0 - oldframe.size.height;
        
        [self.searchKeyword resignFirstResponder];
        [self.searchPseudo resignFirstResponder];
        
        [UIView beginAnimations:@"FadeOut" context:nil];
        [UIView setAnimationDuration:0.2];
        [self.searchBg setAlpha:0];
        self.searchBox.frame = newframe;
        
        [UIView commitAnimations];

    } else {
        //NSLog(@"BECOME");
        CGRect oldframe = self.searchBox.frame;
        //NSLog(@"oldframe %@", NSStringFromCGRect(oldframe));
        
        CGRect newframe = oldframe;
        newframe.origin.y = 0 - oldframe.size.height;
        oldframe.origin.y = 0;
        self.searchBox.frame = newframe;
        [self.searchBox setHidden:NO];
        [self.searchBg setAlpha:0];
        [self.searchBg setHidden:NO];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.searchBg setAlpha:0.7];
            self.searchBox.frame = oldframe;
        } completion:^(BOOL finished){
            [self.searchKeyword becomeFirstResponder];
        }];

    }
}

- (IBAction)searchNext:(UITextField *)sender {
    //NSLog(@"searchNext %@", sender);
        if ([sender isEqual:self.searchKeyword]) {
            //NSLog(@"searchKeyword");
            [self.searchKeyword resignFirstResponder];
            [self.searchPseudo becomeFirstResponder];
        }
        else if ([sender isEqual:self.searchPseudo] && (self.searchPseudo.text.length > 0 || self.searchKeyword.text.length > 0)) {
            //NSLog(@"searchPseudo");
            [self.searchPseudo resignFirstResponder];
            
            [self searchSubmit:nil];
        }
}

- (IBAction)searchFilterChanged:(UISwitch *)sender {
    //NSLog(@"Filter %lu", (unsigned long)sender.isOn);
    
    if (sender.isOn) {
      [self.searchInputData setValue:[NSString stringWithFormat:@"%d", sender.isOn] forKey:@"filter"];
    }
    else {
        [self.searchInputData removeObjectForKey:@"filter"];
    }
}

- (IBAction)searchFromFPChanged:(UISwitch *)sender {
    //NSLog(@"searchFromFPChanged %lu", (unsigned long)sender.isOn);
    
    if (sender.isOn) {
        [self.searchInputData removeObjectForKey:@"currentnum"];
        [self.searchInputData removeObjectForKey:@"firstnum"];
    }else{
        if([self.searchInputData valueForKey:@"tmp_currentnum"]){
            [self.searchInputData setValue:[self.searchInputData valueForKey:@"tmp_currentnum"] forKey:@"currentnum"];
        }
        if([self.searchInputData valueForKey:@"tmp_firstnum"]){
            [self.searchInputData setValue:[self.searchInputData valueForKey:@"tmp_firstnum"] forKey:@"firstnum"];
        }
    }
}

- (IBAction)searchPseudoChanged:(UITextField *)sender {
    //NSLog(@"searchPseudoChanged %@", sender.text);
    if ([sender.text length]) {
        [self.searchInputData setValue:[NSString stringWithFormat:@"%@", sender.text] forKey:@"spseudo"];
    }
    else {
        [self.searchInputData setValue:@"" forKey:@"spseudo"];
    }
    
}

- (IBAction)searchKeywordChanged:(UITextField *)sender {
    //NSLog(@"searchKeywordChanged %@", sender.text);
    if ([sender.text length]) {
        [self.searchInputData setValue:[NSString stringWithFormat:@"%@", sender.text] forKey:@"word"];
    }
    else {
        [self.searchInputData setValue:@"" forKey:@"word"];
    }

}

- (IBAction)searchSubmit:(UIBarButtonItem *)sender {
    NSLog(@"searchSubmit");
    
    //NSString *baseURL = [NSString stringWithFormat:@"/forum2.php?%@", [self serializeParams:self.searchInputData]];

    ASIFormDataRequest  *arequest = [[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/transsearch.php", [k ForumURL]]]];
    
    for (NSString *key in self.searchInputData) {
        [arequest setPostValue:[self.searchInputData objectForKey:key] forKey:key];
        //NSLog(@"POST: %@ : %@", key, [self.searchInputData objectForKey:key]);
    }
    
    [arequest setShouldRedirect:NO];
    [arequest startSynchronous];
    
    NSString *baseURL = @"";
    
    if (arequest) {
        NSString *Location = [[arequest responseHeaders] objectForKey:@"Location"];
        NSLog(@"responseHeaders: %@", [arequest responseHeaders]);
        NSLog(@"requestHeaders: %@", [arequest requestHeaders]);

        if ([arequest error]) {
            NSLog(@"error: %@", [[arequest error] localizedDescription]);
        }
        else if ([arequest responseString])
        {
            baseURL = Location;
            //NSLog(@"responseString %@", [arequest responseString]);
        }
    }
    
    if (!baseURL) {
        [HFRAlertView DisplayAlertViewWithTitle:@"Aucune réponse n'a été trouvée" forDuration:1];
        return;
    }
    
    [self toggleSearch:NO];

    if (self.isSearchInstra) {
        self.currentUrl = baseURL;
        [self fetchContent:kNewMessageFromUnkwn];
    }
    else {
        OnlineMessagesTableViewController *aView = [[OnlineMessagesTableViewController alloc] initWithNibName:@"OnlineMessagesTableViewController" bundle:nil andUrl:baseURL];
        self.messagesTableViewController = aView;
        
        //setup the URL
        [self.messagesTableViewController setTopicName:[NSString stringWithString:self.topicName]];
        self.messagesTableViewController.isViewed = YES;
        self.messagesTableViewController.isSearchInstra = YES;
        [self.messagesTableViewController setSearchInputData:[NSMutableDictionary dictionaryWithDictionary:self.searchInputData]];
        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:[self backBarButtonTitle]
                                         style: UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        
        [self.navigationController pushViewController:messagesTableViewController animated:YES];
    }

}


-(NSString *)serializeParams:(NSDictionary *)params {
    /*
     
     Convert an NSDictionary to a query string
     
     */
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            for (NSString *subKey in value) {
                NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)[value objectForKey:subKey],
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, escaped_value]];
            }
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (NSString *subValue in value) {
                NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                              (CFStringRef)subValue,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8));
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, escaped_value]];
            }
        } else {
            NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (CFStringRef)[params objectForKey:key],
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
    }
    return [pairs componentsJoinedByString:@"&"];
}
@end
