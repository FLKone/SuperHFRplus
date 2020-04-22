//
//  parseMessagesOperation.m
//  HFRplus
//
//  Created by FLK on 06/08/10.
//

#import "Constants.h"

#import "ParseMessagesOperation.h"
#import "LinkItem.h"
#import "RegexKitLite.h"
#import "HTMLParser.h"

#import "RangeOfCharacters.h"
#import <CommonCrypto/CommonDigest.h>

#import "ASIHTTPRequest.h"
#import "BlackList.h"
#import "MultisManager.h"


@interface ParseMessagesOperation ()
@property (nonatomic, weak) id <ParseMessagesOperationDelegate> delegate;
@property (nonatomic, strong) NSData *dataToParse;
//@property (nonatomic, strong) NSMutableArray *workingArray;
@property (nonatomic, strong) LinkItem *workingEntry;
@property (nonatomic, assign) BOOL reverse;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation ParseMessagesOperation

@synthesize delegate, dataToParse, workingArray, workingEntry, reverse, index, queue;

-(id)initWithData:(NSData *)data index:(int)theIndex reverse:(BOOL)isReverse delegate:(id <ParseMessagesOperationDelegate>)theDelegate
//- (id)initWithData:(NSData *)data delegate:(id <ParseMessagesOperationDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        NSString * convertedStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        convertedStr = [convertedStr stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        self.dataToParse = [convertedStr dataUsingEncoding:NSUTF8StringEncoding];
        self.delegate = theDelegate;
		self.index = theIndex;
		self.reverse = isReverse;

        self.queue = [[NSOperationQueue alloc] init];

    }
    return self;
}

// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------

// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{

	@autoreleasepool {
    
		if ([self isCancelled])
		{
			//NSLog(@"main canceled");
		}
		self.workingArray = [NSMutableArray array];

		NSError * error = nil;
		HTMLParser *myParser = [[HTMLParser alloc] initWithData:dataToParse error:&error];
		
		if (![self isCancelled])
		{
			[self.delegate didStartParsing:myParser];
        
        
        [self parseData:myParser];
        
        [self.queue waitUntilAllOperationsAreFinished];
        
        if (![self isCancelled])
        {
            [self.delegate didFinishParsing:self.workingArray];
            
        }
        
		}
    
    myParser = nil;
	
	}
	


}

- (void)parseData:(HTMLParser *)myParser {
    [self parseData:myParser filterPostsQuotes:NO startAfterThisPostId:nil topicUrl:nil topicPage:0];
}

- (void)parseData:(HTMLParser *)myParser filterPostsQuotes:(BOOL)bFilterPostsQuotes startAfterThisPostId:(NSString*)sStartAfterPostId topicUrl:(NSString*)sTopicUrl topicPage:(int)iPage{
    self.workingArray = [NSMutableArray array];
    if ([self isCancelled]) {
		return;
	}
	
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutAvatar];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
	
	if (![fileManager fileExistsAtPath:diskCachePath])	{
		[[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
    
    BOOL bPostIdSeen = NO;
    
	HTMLNode * bodyNode = [myParser body]; //Find the body tag
	NSArray * messagesNodes = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"messagetable" allowPartial:NO]; //Get all the <img alt="" />
    
    int indexNode = 0;
	for (HTMLNode * messageNodeParent in messagesNodes) { //Loop through all the tags
        if (bFilterPostsQuotes && indexNode == 0) { // Filter 1st post of the page: "Reprise de la page précédente"
            indexNode++;
            continue;
        }
        HTMLNode * messageNode = [messageNodeParent firstChild];
		
		if (![self isCancelled]) {
            BOOL bFilterCurrentPost = YES;
            
			HTMLNode * authorNode = [messageNode findChildWithAttribute:@"class" matchingName:@"s2" allowPartial:NO];
        
			LinkItem *linkItem = [[LinkItem alloc] init];
            
			if ([[[[messageNode parent] parent] getAttributeNamed:@"class"] isEqualToString:@"messagetabledel"]) {
				linkItem.isDel = YES;
			}
			else {
				linkItem.isDel = NO;
			}
			
            linkItem.postID = [[[messageNode firstChild] firstChild] getAttributeNamed:@"name"];
            if (sStartAfterPostId && !bPostIdSeen) {
                if ([linkItem.postID isEqualToString:sStartAfterPostId]) {
                    bPostIdSeen = YES;
                }
                continue;
            }

            linkItem.name = [authorNode allContents];
			linkItem.name = [linkItem.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            
            if ([linkItem.name isEqualToString:@"Publicité"]) {
				continue;
			}
            
			HTMLNode * avatarNode = [messageNode findChildWithAttribute:@"class" matchingName:@"avatar_center" allowPartial:NO];
			HTMLNode * contentNode = [messageNode findChildWithAttribute:@"id" matchingName:@"para" allowPartial:YES];

            // Find "Citations"
            // Get current own pseudo
            MultisManager *manager = [MultisManager sharedManager];
            NSDictionary *mainCompte = [manager getMainCompte];
            NSString *currentPseudoLowercase = [[mainCompte objectForKey:PSEUDO_DISPLAY_KEY] lowercaseString];
            if ([[linkItem.name lowercaseString] isEqualToString:currentPseudoLowercase]) {
                bFilterCurrentPost = NO;
            }
            else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"filter_posts_quotes"] containsString:@"wl"] && [[BlackList shared] isWL:[linkItem.name lowercaseString]]) {
                bFilterCurrentPost = NO;
            }
            // For class oldcitation to citation
            NSArray *oldquoteArray = [messageNode findChildrenWithAttribute:@"class" matchingName:@"oldcitation" allowPartial:NO];
            for (HTMLNode * quoteNode in oldquoteArray) {
                [quoteNode setAttributeNamed:@"class" withValue:@"citation"];
            }
            
            NSArray *quoteArray = [messageNode findChildrenWithAttribute:@"class" matchingName:@"citation" allowPartial:NO];
            
            int quoteIndex = 1;
            for (HTMLNode * quoteNode in quoteArray) {
                HTMLNode *subQuoteNode = [quoteNode findChildWithAttribute:@"class" matchingName:@"Topic" allowPartial:NO];
                NSString* sFullTextAuthor = [subQuoteNode allContents];
                if ([sFullTextAuthor length] > 10) {
                    NSString* sQuoteAuthor = [sFullTextAuthor substringToIndex:[sFullTextAuthor length]-10];
                    
                    // Check for own post
                    if ([[sQuoteAuthor lowercaseString] isEqualToString:currentPseudoLowercase]) {
                        [quoteNode setAttributeNamed:@"class" withValue:@"citation_me_quoted"];
                        bFilterCurrentPost = NO;
                    } else if ([[BlackList shared] isWL:[sQuoteAuthor lowercaseString]]) {
                        [quoteNode setAttributeNamed:@"class" withValue:@"citation_whitelist"];
                    } else if ([[BlackList shared] isBL:[sQuoteAuthor lowercaseString]]) {
                        [quoteNode setAttributeNamed:@"class" withValue:@"citation_blacklist"];
                        NSString* sPostId = [linkItem.postID substringFromIndex:1];
                        [quoteNode addAttributeNamed:@"id" withValue:[NSString stringWithFormat: @"2%02d%@", quoteIndex, sPostId]];
                        [quoteNode addAttributeNamed:@"auteur" withValue:sQuoteAuthor];
                        [quoteNode addAttributeNamed:@"style" withValue:@"display:none;"];
                        
                        HTMLNode *pNode = [quoteNode findChildTag:@"p"];
                        [pNode addAttributeNamed:@"class" withValue:@"pbl"];
                        [pNode addAttributeNamed:@"id" withValue:[NSString stringWithFormat: @"2%02d%@", quoteIndex, sPostId]];
                    }
                    quoteIndex++;
                } 
            }
            
            if (bFilterPostsQuotes) {
                if (sTopicUrl) {
                    linkItem.url = [NSString stringWithFormat:@"https://forum.hardware.fr%@", sTopicUrl];
                    if (iPage > 0) {
                        linkItem.iPage = iPage;
                        linkItem.url = [linkItem.url stringByReplacingOccurrencesOfRegex:@"&page=[0-9]+" withString:[NSString stringWithFormat:@"&page=%d", iPage]];
                    }
                    linkItem.url = [linkItem.url stringByReplacingOccurrencesOfRegex:@"#t[0-9]+" withString:[NSString stringWithFormat:@"#%@", linkItem.postID]];
                }
            }
            
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"embedded_videos"] isEqualToString:@"yes"]) {
                NSArray *arr = [NSArray arrayWithObjects: \
                @"^http(?:s)?://(?:www.|m.|gaming.)?(youtu)be.com/.+v=([\\w-]+)/?",\
                @"^http(?:s)?://(youtu).be/([\\w-]+)/?", \
                @"^http(?:s)?://(vimeo).com/(?:[a-zA-Z]+/)*([0-9]+)", \
                @"^https://(streamable).com/([\\w]+)/?", \
                nil];
                
                // Coub and Dailymotion not working => currently not embedded
                // @"^https://(coub).com/view/([\\w]+)/?", \
                // @"^http(?:s)?://(?:www.)?(dai)lymotion.com/video/([\\w-]+)/?", \
                // @"^http(?:s)?://(dai).ly/([\\w-]+)", \
                
                // Issue with Twitch: blocking button Actualiser
                // @"^https://www.(twitch).tv/([\\w]+)/?$", \
                // @"^https://www.twitch.tv/(video)s/([0-9]+)(?:?.*)?/?", \
                // @"^https://www.twitch.tv/[^/]+/(video)/([0-9]+)(?:?.*)?/?", \
                // @"^https://www.twitch.tv/[^/]+/(clip)/([\\w]+)/?", \
                // @"^https://(clip)s.twitch.tv/([\\w]+)/?$", \
                
                // Parse for video
                NSArray *hrefNodeArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"cLink" allowPartial:NO]; //Get links for cat
                for (HTMLNode * hrefNode in hrefNodeArray) {
                    HTMLNode * hrefNodeParent3 = [[[hrefNode parent] parent] parent];
                    NSString* sHref = [hrefNode getAttributeNamed:@"href"];
                    if ([[hrefNodeParent3 getAttributeNamed:@"class"] isEqualToString:@"messCase2"]) {
                        //NSLog(@"Checking URL :%@", sHref);
                        for (NSString* regexp in arr) {
                            NSArray  *capturesArray = [sHref arrayOfCaptureComponentsMatchedByRegex:regexp];
                            //NSLog(@"regexp:%@", regexp);
                            //NSLog(@"capturesArray: %@", capturesArray);
                            if (capturesArray.count > 0) {
                                NSString* sEmbUrl = @"";
                                if ([capturesArray[0][1] isEqualToString:@"youtu"]) {
                                    sEmbUrl = [NSString stringWithFormat:@"https://www.youtube.com/embed/%@", capturesArray[0][2]];
                                    NSString* sRegExpTime = @"(?:\\?|&)t=(?:([0-9]+)h)?(?:([0-9]+)m)?([0-9]+)s$";
                                    //NSLog(@"sRegExpTime:%@", sRegExpTime);
                                    NSArray  *timeArray= [sHref arrayOfCaptureComponentsMatchedByRegex:sRegExpTime];
                                    //NSLog(@"timeArray: %@", timeArray);
                                    if (timeArray.count > 0) {
                                        int iStart = 0;
                                        iStart = [timeArray[0][3] intValue] + [timeArray[0][2] intValue]*60 + [timeArray[0][2] intValue]*3600;
                                        sEmbUrl = [NSString stringWithFormat:@"%@?start=%d", sEmbUrl, iStart];
                                    }
                                } else if ([capturesArray[0][1] isEqualToString:@"dai"]) {
                                    sEmbUrl = [NSString stringWithFormat:@"//www.dailymotion.com/embed/video/%@", capturesArray[0][2]];
                                } else if ([capturesArray[0][1] isEqualToString:@"vimeo"]) {
                                    sEmbUrl = [NSString stringWithFormat:@"https://player.vimeo.com/video/%@", capturesArray[0][2]];
                                } else if ([capturesArray[0][1] isEqualToString:@"video"]) {
                                    sEmbUrl = [NSString stringWithFormat:@"https://player.twitch.tv/?autoplay=false&video=v%@", capturesArray[0][2]];
                                } else if ([capturesArray[0][1] isEqualToString:@"twitch"]) {
                                    sEmbUrl = [NSString stringWithFormat:@"https://player.twitch.tv/?autoplay=false&channel=%@", capturesArray[0][2]];
                                } else if ([capturesArray[0][1] isEqualToString:@"clip"]) {
                                    sEmbUrl = [NSString stringWithFormat:@"https://clips.twitch.tv/embed?autoplay=false&clip=%@", capturesArray[0][2]];
                                } else if ([capturesArray[0][1] isEqualToString:@"coub"]) {
                                    sEmbUrl = [NSString stringWithFormat:@"//coub.com/embed/%@", capturesArray[0][2]];
                                } else if ([capturesArray[0][1] isEqualToString:@"streamable"]) {
                                    sEmbUrl = [NSString stringWithFormat:@"https://streamable.com/s/%@", capturesArray[0][2]];
                                }

                                
                                [hrefNode setAttributeNamed:@"class" withValue:@"embedvideo"];
                                [hrefNode addAttributeNamed:@"hrefemb" withValue:sEmbUrl];
                                NSString* sUrlText = rawContentsOfNode([[hrefNode firstChild] _node], [myParser _doc]);
                                [hrefNode addAttributeNamed:@"hreftxt" withValue:sUrlText];
                                /*
                                NSString* value = @"embeddedvideo";
                                const char * valueStr = [value UTF8String];
                                char * newVal = (char *)malloc(strlen(valueStr)+1);
                                memcpy (newVal, valueStr, strlen(valueStr)+1);
                                free([hrefNode firstChild]->_node->content);
                                [hrefNode firstChild]->_node->content = (xmlChar*)newVal;*/
                                break;
                            }
                        }
                    }
                }
            }

            // When activated, filter to remove posts from other people or where you are not quoted
            if (bFilterPostsQuotes && bFilterCurrentPost && ![[[NSUserDefaults standardUserDefaults] stringForKey:@"filter_posts_quotes"] containsString:@"pseudo"]) {
                continue;
            }

            linkItem.dicoHTML = rawContentsOfNode([contentNode _node], [myParser _doc]);
            //NSLog(@"################################################# dicoHTML:\nd%@\n##################################################", linkItem.dicoHTML);
            
            if (bFilterPostsQuotes && bFilterCurrentPost && [[[NSUserDefaults standardUserDefaults] stringForKey:@"filter_posts_quotes"] containsString:@"pseudo"]) {
                if ([[linkItem.dicoHTML lowercaseString] containsString:currentPseudoLowercase]) {
                    bFilterCurrentPost = NO;
                }
            }

            // When activated, filter to remove posts from other people or where you are not quoted
            if (bFilterPostsQuotes && bFilterCurrentPost) {
                continue;
            }


            //recherche
            NSArray * nodesInMsg = [[messageNode findChildOfClass:@"messCase2"] children];
            if (nodesInMsg.count >= 2 && [[[nodesInMsg objectAtIndex:1] tagName] isEqualToString:@"a"]) {
                linkItem.dicoHTML = [rawContentsOfNode([[nodesInMsg objectAtIndex:1] _node], [myParser _doc]) stringByAppendingString:linkItem.dicoHTML];
            }
            
			// NEW FAST
			HTMLNode * quoteNode = [[messageNode findChildWithAttribute:@"alt" matchingName:@"answer" allowPartial:NO] parent];
			linkItem.urlQuote = [quoteNode className];
			
			HTMLNode * editNode = [[messageNode findChildWithAttribute:@"alt" matchingName:@"edit" allowPartial:NO] parent];
			linkItem.urlEdit = [editNode className];

            HTMLNode * alertNode = [messageNode findChildWithAttribute:@"href" matchingName:@"/user/modo.php" allowPartial:YES];
            linkItem.urlAlert = [alertNode getAttributeNamed:@"href"];
                        
			HTMLNode * profilNode = [[messageNode findChildWithAttribute:@"alt" matchingName:@"profil" allowPartial:NO] parent];
			linkItem.urlProfil = [profilNode getAttributeNamed:@"href"];
			
			HTMLNode * addFlagNode = [messageNode findChildWithAttribute:@"href" matchingName:@"addflag" allowPartial:YES];
			linkItem.addFlagUrl = [addFlagNode getAttributeNamed:@"href"];

			HTMLNode * quoteJSNode = [messageNode findChildWithAttribute:@"onclick" matchingName:@"quoter('hardwarefr'" allowPartial:YES];
			linkItem.quoteJS = [quoteJSNode getAttributeNamed:@"onclick"];

			HTMLNode * MPNode = [messageNode findChildWithAttribute:@"href" matchingName:@"/message.php?config=hfr.inc&cat=prive&sond=&p=1&subcat=&dest=" allowPartial:YES];
			linkItem.MPUrl = [MPNode getAttributeNamed:@"href"];
			
			//NSDate *then2 = [NSDate date]; // Create a current date

            //NSString* sPostUrl = [NSString stringWithFormat:@"http://forum.hardware.fr/forum2.php?config=hfr.inc&cat=_CATID_&subcat=_SUBCATID_&post=__TOPIC_ID&page=1&p=1&sondage=&owntopic=&trash=&trash_post=&print=&numreponse=_POSTID_&quote_only=0&new=0&nojs=0#t_POSTID_"];
            // http://forum.hardware.fr/forum2.php?config=hfr.inc&cat=_CATID_&subcat=_SUBCATID_&post=__TOPIC_ID&page=1&p=1&sondage=&owntopic=&trash=&trash_post=&print=
            //          &numreponse=_POSTID_&quote_only=0&new=0&nojs=0#t_POSTID_

			HTMLNode * dateNode = [messageNode findChildWithAttribute:@"class" matchingName:@"toolbar" allowPartial:NO];
			if ([dateNode allContents]) {
				NSString *regularExpressionString = @".*([0-9]{2})-([0-9]{2})-([0-9]{4}).*([0-9]{2}):([0-9]{2}):([0-9]{2}).*";
				linkItem.messageDate = [[dateNode allContents] stringByReplacingOccurrencesOfRegex:regularExpressionString withString:@"$1-$2-$3 $4:$5:$6"];
			}
			else {
				linkItem.messageDate = @"";
			}
			
            //edit citation
			HTMLNode * editedNode = [messageNode findChildWithAttribute:@"class" matchingName:@"edited" allowPartial:NO];
            if ([editedNode allContents]) {
                NSString *regularExpressionString = @".*Message cité ([^<]+) fois.*";
                linkItem.quotedNB = [[[[editedNode allContents] stringByMatching:regularExpressionString capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByDecodingXMLEntities];
                if (linkItem.quotedNB) {
                    linkItem.quotedLINK = [[editedNode findChildTag:@"a"] getAttributeNamed:@"href"];
                }
                
                NSString *regularExpressionString2 = @".*Message édité par ([^<]+).*";
                linkItem.editedTime = [[[[editedNode allContents] stringByMatching:regularExpressionString2 capture:1L] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByDecodingXMLEntities];
                
                //NSLog(@"editedTime = %@", linkItem.editedTime);
                //NSLog(@"quotedLINK = %@", linkItem.quotedLINK);
            }

            
			/*NSString *regularExpressionString = @"oijlkajsdoihjlkjasdoimbrows://[^/]+/(.*)";
			stringByMatching:regularExpressionString capture:1L]
			NSPredicate *regExErrorPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regExError];
			BOOL isRegExError = [regExErrorPredicate evaluateWithObject:[request responseString]];*/
			
			linkItem.imageUI = nil;

			//NSDate *then4 = [NSDate date]; // Create a current date

            //NSLog(@"%f BEFORE AVAT", [thenT timeIntervalSinceNow] * -1000.0);

            //AVATAR BY NAME v2
            
            //Key for pseudo
            const char *str = [linkItem.name UTF8String];
            unsigned char r[CC_MD5_DIGEST_LENGTH];
            CC_MD5(str, strlen(str), r);
            NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                  r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
            
            NSString *key = [diskCachePath stringByAppendingPathComponent:filename];
            
            if ([fileManager fileExistsAtPath:key]) // on check si on a deja l'avatar pour cette key
            {
                linkItem.imageUI = key;
            }
            else { 
                NSString *tmpURL = [[avatarNode firstChild] getAttributeNamed:@"src"];
                
                if (tmpURL.length > 0) { // si on a pas, on check si on a une URL
                    ASIHTTPRequest *operation = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:tmpURL]];
                    __weak ASIHTTPRequest *operation_ = operation;
                    [operation setCompletionBlock:^{
                        [fileManager createFileAtPath:key contents:[operation_ responseData] attributes:nil];
                        linkItem.imageUI = key;
                    }];
                    [operation setFailedBlock:^{
                        NSLog(@"setFailedBlock");
                        linkItem.imageUI = nil;
                    }];
                                        
                    [self.queue addOperation:operation];
                    //async dl                    
                    
                }
            }
            
			if ([self isCancelled]) {
				break;
			}
			
			[self.workingArray addObject:linkItem];
			
			//NSLog(@"TOPICS Time elapsed then0		: %f", [then0 timeIntervalSinceDate:then]);
			//NSLog(@"TOPICS Time elapsed then1		: %f", [then1 timeIntervalSinceDate:then0]);
			//NSLog(@"TOPICS Time elapsed then2		: %f", [then2 timeIntervalSinceDate:then1]);
			//NSLog(@"TOPICS Time elapsed then3		: %f", [then3 timeIntervalSinceDate:then2]);
			//NSLog(@"TOPICS Time elapsed then4		: %f", [then4 timeIntervalSinceDate:then3]);
			//NSLog(@"TOPICS Time elapsed now		: %f", [now timeIntervalSinceDate:then4]);
			//NSLog(@"TOPICS Time elapsed Total		: %f", [now timeIntervalSinceDate:then]);
			
		}
		else {
			//canceled
			break;
		}

        indexNode++;
	}

	//NSDate *nowT = [NSDate date]; // Create a current date
	//NSLog(@"TOPICS Parse Time elapsed Total		: %f", [nowT timeIntervalSinceDate:thenT]);
}

@end
