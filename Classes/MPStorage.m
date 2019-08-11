//
//  MPStorage.m
//  HFRplus
//
//  Created by ezzz on 03/08/2019.
//
//

#import "MPStorage.h"
#import "HFRplusAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import "BlackList.h"
#import "HFRAlertView.h"
#import "MultisManager.h"

NSString* const MP_NAME = @"a2bcc09b796b8c6fab77058ff8446c34";
NSString* const MP_SENDTO = @"MultiMP";
NSString* const MP_STRUCTURE_VERSION = @"0.1";

@implementation MPStorage

@synthesize dData, sPostId, sNumRep, listInternalBlacklistPseudo, listMPBlacklistPseudo, dicMPBlacklistPseudoTimestamp;
static MPStorage *_shared = nil;    // static instance variable

// --------------------------------------------------------------------------------
// Init methods
// --------------------------------------------------------------------------------

+ (MPStorage *)shared {
    if (_shared == nil) {
        _shared = [[super allocWithZone:NULL] init];
    }
    return _shared;
}

- (id)init {
    if ( (self = [super init]) ) {
        // your custom initialization
        [self initMP];
    }
    return self;
}

- (void)initMP {
    // Find MP with title a2bcc09b796b8c6fab77058ff8446c34
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MPStorage_postid"] == nil) {
        if ([self findStorageMPFromPage:1] == NO) {
            // TODO: create empty post
        }
    }
    
    sPostId = [[NSUserDefaults standardUserDefaults] stringForKey:@"MPStorage_postid"];
}


// --------------------------------------------------------------------------------
// Load black list methods
// --------------------------------------------------------------------------------

- (void)loadBlackListAsynchronous {
    ASIHTTPRequest *request = [self GETRequest];
    [request setShouldRedirect:NO];
    [request setDelegate:self];
    [request setDidStartSelector:@selector(loadBlackListStarted:)];
    [request setDidFinishSelector:@selector(loadBlackListComplete:)];
    [request setDidFailSelector:@selector(loadBlackListFailed:)];
    [request startAsynchronous];
}

- (void)loadBlackListStarted:(ASIHTTPRequest *)request
{
}

- (void)loadBlackListFailed:(ASIHTTPRequest *)request
{
    [HFRAlertView DisplayAlertViewWithTitle:@"Oups !" andMessage:@"Failed to load MPstorage for blacklist" forDuration:(long)1];
}

- (void)loadBlackListComplete:(ASIHTTPRequest *)request
{
    [self parseBlackList:[request responseString] updateBL:YES];
}

- (BOOL)parseBlackList:(NSString *)content updateBL:(BOOL)updateBL
{
    BOOL success = NO;
    @try {
        NSError *error;
        HTMLParser *myParser = [[HTMLParser alloc] initWithString:content error:&error];
        HTMLNode * bodyNode = [myParser body]; //Find the body tag
        HTMLNode *MPNode = [bodyNode findChildOfClass:@"messagetable"]; // Get links for cat
        NSArray *temporaryMPArray = [MPNode findChildTags:@"td"];
        NSArray *temporaryDivArray = [[temporaryMPArray objectAtIndex:1] findChildTags:@"div"];
        HTMLNode *temporaryDivIdRepNode = [[temporaryMPArray objectAtIndex:1] findChildWithAttribute:@"id" matchingName:@"para" allowPartial:YES];
        sNumRep = [[temporaryDivIdRepNode getAttributeNamed:@"id"] substringFromIndex:4];
        NSString* contentJson = [[[temporaryMPArray objectAtIndex:1] findChildTag:@"p"] allContents];
        NSString *contentJson2 = [contentJson stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""]; // Remove unsecable space
        NSData *jsonData = [contentJson2 dataUsingEncoding:NSUTF8StringEncoding];
        
        dData = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &error];
        
        // Reset black list and fill it with MPStorage values
        if (updateBL) {
            [[BlackList shared].listBlackList removeAllObjects];
        }
        
        listMPBlacklistPseudo = [NSMutableArray array];
        dicMPBlacklistPseudoTimestamp = [NSMutableDictionary dictionary];
        
        NSArray* bl = dData[@"data"][0][@"blacklist"][@"list"];
        for (NSDictionary *dUser in bl) {
            NSString* pseudo = [dUser valueForKey:@"username"];
            NSNumber* timestamp = [dUser valueForKey:@"createDate"];
            [listMPBlacklistPseudo addObject:pseudo];
            [dicMPBlacklistPseudoTimestamp setValue:timestamp forKey:pseudo];

            if (updateBL) {
                [[BlackList shared] addToBlackList:pseudo andSave:NO];
                NSLog(@"User BL added: %@", pseudo);
            }
        }
        
        success = YES;
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [HFRAlertView DisplayAlertViewWithTitle:@"Oups !" andMessage:@"MPstorage Parsing error for blacklist" forDuration:(long)1];
    }
    @finally {}
    
    return success;
}
// --------------------------------------------------------------------------------
// Save black list methods
// --------------------------------------------------------------------------------

- (void)saveBlackListAsynchronous:(NSMutableArray*)listBlacklist {
    listInternalBlacklistPseudo = listBlacklist;
    
    // First get content of MPStorage
    ASIHTTPRequest *request = [self GETRequest];
    [request setShouldRedirect:NO];
    [request setDelegate:self];
    [request setDidStartSelector:@selector(loadBlackListStarted:)];
    [request setDidFinishSelector:@selector(loadBlackListCompleteAndSave:)];
    [request setDidFailSelector:@selector(loadBlackListFailed:)];
    [request startAsynchronous];
}

- (void)loadBlackListCompleteAndSave:(ASIHTTPRequest *)request
{
    // If content is not parsed, then error
    if ([self parseBlackList:[request responseString] updateBL:NO] == NO) {
        return;
    }

    dData[@"data"][0][@"blacklist"][@"list"] = [NSMutableArray array];
    NSMutableArray* bl = dData[@"data"][0][@"blacklist"][@"list"];
    for (NSMutableDictionary *dUser in listInternalBlacklistPseudo) {
        NSString *sUser = [dUser valueForKey:@"word"];
        NSNumber* timestamp = 0;
        if ([listMPBlacklistPseudo containsObject:sUser]) {
            timestamp = (NSNumber*)[dicMPBlacklistPseudoTimestamp objectForKey:sUser];
        } else {
            timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
        }
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              timestamp, @"createDate", sUser, @"username", nil];
        [bl insertObject:dict atIndex:0];
        //[dData[@"data"][0][@"blacklist"][@"list"] insertObject:dict atIndex:0];
    }

    NSError* error = nil;
    NSData* dataJson = [NSJSONSerialization dataWithJSONObject:dData options:kNilOptions error:&error];
    NSString *stringJson = [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];
    
    NSLog(@"String Json updated:\n%@\n==========================\n", stringJson);
    
    // POST request to save new content
    ASIFormDataRequest *requestPOST = [self POSTRequestWithData:stringJson];
    [requestPOST startSynchronous];
    if (requestPOST) {
        if ([requestPOST error]) {
            // Set main compte cookies
            NSLog(@"ERROR updating MPstorage");
        }
        else if ([requestPOST responseString])
        {
            NSLog(@"Success updating MPstorage :\n%@", [requestPOST responseString]);
        }
    }
}


// --------------------------------------------------------------------------------
// MPstorage general handling methods
// --------------------------------------------------------------------------------

// Method to find the MPStorage in the current MPs page
- (BOOL)findStorageMPFromPage:(NSInteger)pageId {
    NSInteger iMaxPages = 0;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://forum.hardware.fr/forum1.php?config=hfr.inc&cat=prive&page=%ld&subcat=&sondage=0&owntopic=0&trash=0&trash_post=0&moderation=0&new=0&nojs=0&subcatgroup=0", pageId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        HTMLParser *myParser = [[HTMLParser alloc] initWithString:[request responseString] error:&error];
        HTMLNode * bodyNode = [myParser body]; //Find the body tag
        HTMLNode * pagesTrNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"fondForum1PagesHaut" allowPartial:YES];
        HTMLNode * pagesLinkNode = [pagesTrNode findChildWithAttribute:@"class" matchingName:@"left" allowPartial:NO];
        NSArray *temporaryNumPagesArray = [pagesLinkNode children];
        iMaxPages = [[[temporaryNumPagesArray lastObject] contents] intValue];
        NSLog(@"Current page %ld / max page %ld", pageId, iMaxPages);
        NSArray *temporaryTopicsArray = [bodyNode findChildrenWithAttribute:@"class" matchingName:@"sujet ligne_booleen" allowPartial:YES]; //Get links for cat
        for (HTMLNode * topicNode in temporaryTopicsArray) {
            HTMLNode * topicTitleNode = [topicNode findChildWithAttribute:@"class" matchingName:@"sujetCase3" allowPartial:NO];
            NSString* sTitle = [topicTitleNode allContents];
            if ([sTitle isEqualToString:MP_NAME] || [sTitle isEqualToString:[NSString stringWithFormat:@"[non lu] %@", MP_NAME]]) {
                NSString *aTopicURL = [[NSString alloc] initWithString:[[topicTitleNode findChildTag:@"a"] getAttributeNamed:@"href"]];
                NSLog(@"Topic title FOUND : >%@<\nURL:>%@<", [topicTitleNode allContents], aTopicURL);
                for (NSString *qs in [aTopicURL componentsSeparatedByString:@"&"]) {
                    NSString *key = [[qs componentsSeparatedByString:@"="] objectAtIndex:0];
                    if ([key isEqualToString:@"post"]) {
                        sPostId = [[qs componentsSeparatedByString:@"="] objectAtIndex:1];
                        [[NSUserDefaults standardUserDefaults] setObject:sPostId forKey:@"MPStorage_postid"];
                        return YES;
                    }
                }
            }
        }
    }

    if (iMaxPages > 1 && pageId < iMaxPages) {
        return [self findStorageMPFromPage:(pageId+1)];
    }
    
    return NO;
}

// Request to get content from MP storage
- (ASIHTTPRequest*)GETRequest {
    NSString* s = [NSString stringWithFormat:@"https://forum.hardware.fr/forum2.php?config=hfr.inc&cat=prive&post=%@&numreponse=0&page=1&p=1&subcat=0&sondage=0&owntopic=0", sPostId];
    NSURL *url = [NSURL URLWithString:s];
    return [ASIHTTPRequest requestWithURL:url];
}

// Request to modify (POST) content from MP storage
- (ASIFormDataRequest*)POSTRequestWithData:(NSString*)data {
    NSString* s = [NSString stringWithFormat:@"https://forum.hardware.fr/bdd.php?config=hfr.inc"];
    NSURL *url = [NSURL URLWithString:s];
    ASIFormDataRequest* arequest = [[ASIFormDataRequest  alloc] initWithURL:url];
    [arequest setRequestMethod:@"GET"];
    NSDictionary *mainCompte = [[MultisManager sharedManager] getMainCompte];
    [arequest setPostValue:@"1" forKey:@"p"];
    [arequest setPostValue:[mainCompte objectForKey:PSEUDO_DISPLAY_KEY] forKey:@"pseudo"];
    [arequest setPostValue:@"" forKey:@"ColorUsedMem"];
    [arequest setPostValue:@"Valider votre message" forKey:@"submit"];
    [arequest setPostValue:@"" forKey:@"parents"];
    [arequest setPostValue:@"1" forKey:@"MsgIcon"];
    [arequest setPostValue:sPostId forKey:@"post"];
    [arequest setPostValue:@"1100" forKey:@"verifrequet"];
    [arequest setPostValue:@"0" forKey:@"new"];
    [arequest setPostValue:@"" forKey:@"search_smilies"];
    [arequest setPostValue:@"" forKey:@"stickold"];
    [arequest setPostValue:@"0" forKey:@"sond"];
    [arequest setPostValue:@"1" forKey:@"signature"];
    [arequest setPostValue:@"0" forKey:@"sondage"];
    [arequest setPostValue:sNumRep forKey:@"numreponse"];
    [arequest setPostValue:@"0" forKey:@"smiley"];
    [arequest setPostValue:@"0" forKey:@"owntopic"];
    [arequest setPostValue:@"" forKey:@"numrep"];
    [arequest setPostValue:[mainCompte objectForKey:HASH_KEY] forKey:@"hash_check"]; // "3e64a94aabae7c490aff10da4da92036"
    [arequest setPostValue:@"prive" forKey:@"cat"];
    [arequest setPostValue:@"0" forKey:@"wysiwyg"];
    [arequest setPostValue:@"1" forKey:@"page"];
    [arequest setPostValue:@"" forKey:@"password"];
    [arequest setPostValue:@"0" forKey:@"emaill"];
    [arequest setPostValue:@"hfr.inc" forKey:@"config"];
    [arequest setPostValue:@"" forKey:@"cache"];
    [arequest setPostValue:data forKey:@"content_form"];
    [arequest setPostValue:MP_NAME forKey:@"sujet"];

    /*
    [arequest setPostValue:MP_SENDTO forKey:@"dest"];
    [arequest setPostValue:@"0" forKey:@"delete"];*/
    /*
    [arequest setPostValue:@"0" forKey:@"new"];
    [arequest setPostValue:sPostId forKey:@"post"];
    [arequest setPostValue:sNumRep forKey:@"numrep"];
    [arequest setPostValue:@"prive" forKey:@"cat"];
    [arequest setPostValue:@"0" forKey:@"subcat"];
    [arequest setPostValue:@"1" forKey:@"page"];
    [arequest setPostValue:@"1100" forKey:@"verifrequet"];
    [arequest setPostValue:@"1" forKey:@"p"];
    [arequest setPostValue:@"0" forKey:@"sondage"];
    [arequest setPostValue:@"" forKey:@"cache"];
    [arequest setPostValue:@"0" forKey:@"owntopic"];
    [arequest setPostValue:@"" forKey:@"emaill"];
    [arequest setPostValue:[mainCompte objectForKey:PSEUDO_DISPLAY_KEY] forKey:@"pseudo"];
    [arequest setPostValue:@"sujet" forKey:MP_NAME];
    [arequest setPostValue:@"1" forKey:@"signature"];

    /* Debug from
    <input type="submit" accesskey="s" value="Valider votre message" name="submit" id="submitreprap"/>
    <input type="hidden" name="new" value="0" />
    <input type="hidden" name="post" value="2806579" />
    <input type="hidden" name="numrep" value="1975531506" />
    <input type="hidden" name="cat" value="prive" />
    <input type="hidden" name="subcat" value="0" />
    <input type="hidden" name="page" value="1" />
    <input type="hidden" name="verifrequet" value="1100" />
    <input type="hidden" name="p" value="1" />
    <input type="hidden" name="sondage" value="0" />
    <input type="hidden" name="cache" value="" />
    <input type="hidden" name="owntopic" value="0" />
    <input type="hidden" name="config" value="hfr.inc" />
    <input type="hidden" name="emaill" value="" />
    <input type="hidden" name="pseudo" value="ezzz" />
    <input type="hidden" name="sujet" value="a2bcc09b796b8c6fab77058ff8446c34" />
    <input type="hidden" value="1" name="signature" /> */
    
    [arequest setUseCookiePersistence:NO];
    [arequest setRequestCookies:[mainCompte objectForKey:COOKIES_KEY]];
    
    return arequest;
}


- (void)loadMP {
    ASIHTTPRequest *request = [self GETRequest];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        HTMLParser *myParser = [[HTMLParser alloc] initWithString:[request responseString] error:&error];
        HTMLNode * bodyNode = [myParser body]; //Find the body tag
        HTMLNode *MPNode = [bodyNode findChildOfClass:@"messagetable"]; // Get links for cat
        NSArray *temporaryMPArray = [MPNode findChildTags:@"td"];
        NSString* content = [[[temporaryMPArray objectAtIndex:1] findChildTag:@"p"] allContents];
        //NSLog(@"MPStorage content: \n======================================\n%@\n======================================\n", content);
        // Remove unsecable space
        NSString *content2 = [content stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""];
        NSData *jsonData = [content2 dataUsingEncoding:NSUTF8StringEncoding];
        
        dData = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &error];
    }
}

@end
