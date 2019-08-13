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
NSString* const MP_SOURCE_NAME = @"iOS";

#define TIMESTAMP [NSNumber numberWithInteger:(NSInteger)(round([[NSDate date] timeIntervalSince1970]*1000))]

@implementation MPStorage

@synthesize bIsActive, dData, sPostId, sNumRep, listInternalBlacklistPseudo, listMPBlacklistPseudo, dicMPBlacklistPseudoTimestamp;
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
        bIsActive = NO;
    }
    return self;
}

- (void)initOrResetMP:(NSString*)pseudo {
    if (pseudo) {
        NSMutableDictionary* dicMPStorage_postid = [[NSUserDefaults standardUserDefaults] objectForKey:@"dicMPStorage_postid"];
        
        if (dicMPStorage_postid == nil || [dicMPStorage_postid objectForKey:pseudo] == nil) {
            // Find MP with title a2bcc09b796b8c6fab77058ff8446c34
            if ([self findStorageMPFromPage:1] == NO) {
                // Create empty structure
                if ([self createEmptyMPStorage] == NO) {
                    bIsActive = NO;
                    return;
                }
                
                // Search again to find post ID
                if ([self findStorageMPFromPage:1] == NO) {
                    [HFRAlertView DisplayAlertViewWithTitle:@"Oups !" andMessage:@"Failed to find MPStorage after its creation" forDuration:(long)3];
                    bIsActive = NO;
                    return;
                }
            }
        }
        else {
            sPostId = [dicMPStorage_postid valueForKey:pseudo];
        }
        bIsActive = YES;
        
        [[MPStorage shared] loadBlackListAsynchronous];
    }
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
    [HFRAlertView DisplayAlertViewWithTitle:@"Oups !" andMessage:@"Failed to load MPstorage for blacklist" forDuration:(long)3];
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
        HTMLNode *temporaryDivIdRepNode = [[temporaryMPArray objectAtIndex:1] findChildWithAttribute:@"id" matchingName:@"para" allowPartial:YES];
        sNumRep = [[temporaryDivIdRepNode getAttributeNamed:@"id"] substringFromIndex:4];
        NSString* contentJson = [[[temporaryMPArray objectAtIndex:1] findChildTag:@"p"] allContents];
        NSString *contentJson2 = [contentJson stringByReplacingOccurrencesOfString:@"\u00a0" withString:@""]; // Remove unsecable space
        NSData *jsonData = [contentJson2 dataUsingEncoding:NSUTF8StringEncoding];
        
        dData = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &error];
        
        // Reset black list and fill it with MPStorage values
        if (updateBL) {
            [[BlackList shared] setBlackListForActiveCompte:[NSMutableArray array]];
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

- (BOOL)addBlackListSynchronous:(NSString*)newPseudoBL {
    // First get content of MPStorage
    NSInteger t1 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);

    ASIHTTPRequest *request = [self GETRequest];
    [request startSynchronous];

    NSInteger t2 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);
    NSLog(@"Time parseBlackList : %d ms", (int)(t2-t1));

    if (request) {
        if ([request error]) {
            NSLog(@"error: %@", [[request error] localizedDescription]);
            return NO;
        }
        
        if ([request responseString])
        {
            // If content is not parsed, then error
            if ([self parseBlackList:[request responseString] updateBL:NO] == NO) {
                return NO;
            }

            NSInteger t3 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);
            NSLog(@"Time parseBlackList : %d ms", (int)(t3-t2));
            
            NSUInteger index = 0;
            NSUInteger indexFound = -1;
            for (NSDictionary* dUser in dData[@"data"][0][@"blacklist"][@"list"]) {
                NSString* pseudo = [dUser valueForKey:@"username"];
                if ([[pseudo lowercaseString] isEqualToString:[newPseudoBL lowercaseString]]) {
                    indexFound = index;
                }
                index++;
            }
            if (indexFound == -1) { // Not found, so it can be added
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: TIMESTAMP, @"createDate", newPseudoBL, @"username", nil];
                
                [dData[@"data"][0][@"blacklist"][@"list"] insertObject:dict atIndex:0];
                [dData setValue:TIMESTAMP forKey:@"lastUpdate"];
                [dData setValue:MP_SOURCE_NAME forKey:@"sourceName"];
                NSError* error = nil;
                NSData* dataJson = [NSJSONSerialization dataWithJSONObject:dData options:kNilOptions error:&error];
                NSString *stringJson = [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];
                
                NSLog(@"String Json updated:\n%@\n==========================\n", stringJson);
                
                NSInteger t4 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);
                NSLog(@"Time update json : %d ms", (int)(t4-t3));

                
                // POST request to save new content
                ASIFormDataRequest *requestPOST = [self POSTRequestWithData:stringJson newMessage:NO];
                [requestPOST startSynchronous];

                NSInteger t5 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);
                NSLog(@"Time POST : %d ms", (int)(t5-t4));

                if (requestPOST) {
                    if ([requestPOST error]) {
                        // Set main compte cookies
                        NSLog(@"ERROR updating MPstorage");
                    }
                    else if ([requestPOST responseString])
                    {
                        NSLog(@"Success ? updating MPstorage :\n%@", [requestPOST responseString]);
                        if ([[requestPOST responseString] containsString:@"succès"]) {
                            NSInteger t6 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);
                            NSLog(@"Time GLOBAL : %d ms", (int)(t6-t1));
                            return YES;
                        }
                    }
                }
            }
        }
    }
    return NO;
}

- (BOOL)removeBlackListSynchronous:(NSString*)pseudoBLtoRemove {
    // First get content of MPStorage
    ASIHTTPRequest *request = [self GETRequest];
    [request startSynchronous];
    
    if (request) {
        if ([request error]) {
            NSLog(@"error: %@", [[request error] localizedDescription]);
            return NO;
        }
        
        if ([request responseString])
        {
            // If content is not parsed, then error
            if ([self parseBlackList:[request responseString] updateBL:NO] == NO) {
                return NO;
            }
            

            NSUInteger index = 0;
            NSUInteger indexFound = -1;
            for (NSDictionary* dUser in dData[@"data"][0][@"blacklist"][@"list"]) {
                NSString* pseudo = [dUser valueForKey:@"username"];
                if ([[pseudo lowercaseString] isEqualToString:[pseudoBLtoRemove lowercaseString]]) {
                    indexFound = index;
                }
                index++;
            }
            if (indexFound >= 0) {
                [dData[@"data"][0][@"blacklist"][@"list"] removeObjectAtIndex: indexFound];
                                           
                NSError* error = nil;
                NSData* dataJson = [NSJSONSerialization dataWithJSONObject:dData options:kNilOptions error:&error];
                NSString *stringJson = [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];
                
                NSLog(@"String Json updated:\n%@\n==========================\n", stringJson);
                
                // POST request to save new content
                ASIFormDataRequest *requestPOST = [self POSTRequestWithData:stringJson newMessage:NO];
                [requestPOST startSynchronous];
                if (requestPOST) {
                    if ([requestPOST error]) {
                        // Set main compte cookies
                        NSLog(@"ERROR updating MPstorage");
                    }
                    else if ([requestPOST responseString])
                    {
                        NSLog(@"Success ? updating MPstorage :\n%@", [requestPOST responseString]);
                        if ([[requestPOST responseString] containsString:@"succès"]) {
                            return YES;
                        }
                    }
                }
            }
        }
    }
    return NO;
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
                        
                        NSMutableDictionary* dicMPStorage_postid = [[NSUserDefaults standardUserDefaults] objectForKey:@"dicMPStorage_postid"];
                        if (dicMPStorage_postid == nil) dicMPStorage_postid = [NSMutableDictionary dictionary];
                        NSString* pseudo = [[[MultisManager sharedManager] getMainCompte] objectForKey:PSEUDO_DISPLAY_KEY];
                        [dicMPStorage_postid setValue:sPostId forKey:pseudo];
                        [[NSUserDefaults standardUserDefaults] setObject:dicMPStorage_postid forKey:@"dicMPStorage_postid"];
                        
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

- (BOOL)createEmptyMPStorage {
    // POST request to save new content
    NSString* stringJson = [NSString stringWithFormat: @"{\"lastUpdate\":%@,\"data\":[{\"lastUpdate\":%@,\"blacklist\":{\"lastUpdate\":%@,\"sourceName\":\"%@\",\"list\":[]},\"sourceName\":\"%@\",\"mpFlags\":{\"lastUpdate\":%@,\"sourceName\":\"%@\",\"list\":[],\"sourceName\":\"%@\"}", TIMESTAMP, TIMESTAMP, TIMESTAMP, MP_SOURCE_NAME, MP_SOURCE_NAME, TIMESTAMP, MP_SOURCE_NAME, MP_SOURCE_NAME ];
    ASIFormDataRequest *requestPOST = [self POSTRequestWithData:stringJson newMessage:YES];

    [requestPOST startSynchronous];
    if (requestPOST) {
        if ([requestPOST error]) {
            // Set main compte cookies
            NSLog(@"ERROR creating MPstorage");
        }
        else if ([requestPOST responseString])
        {
            NSLog(@"Response string for creating MPstorage \n%@\n-----------------------------\n", [requestPOST responseString]);
            if ([[requestPOST responseString] containsString:@"succès"]) {
                NSLog(@"SUCCESS creating MPstorage");
                return YES;
            } else {
                NSError* error;
                HTMLParser *myParser = [[HTMLParser alloc] initWithString:[requestPOST responseString] error:&error];
                HTMLNode * bodyNode = [myParser body]; //Find the body tag
                HTMLNode * messagesNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO]; //Get all the <img alt="" />
                [HFRAlertView DisplayAlertViewWithTitle:@"Oups !" andMessage:[NSString stringWithFormat:@"Failed to create MPStorage : %@", [messagesNode contents]] forDuration:(long)3];
            }
        }
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
- (ASIFormDataRequest*)POSTRequestWithData:(NSString*)data newMessage:(BOOL)bNew {
    NSString* s = @"https://forum.hardware.fr/bdd.php?config=hfr.inc";
    if (bNew) s = @"https://forum.hardware.fr/bddpost.php?config=hfr.inc";
    
    NSURL *url = [NSURL URLWithString:s];
    ASIFormDataRequest* arequest = [[ASIFormDataRequest  alloc] initWithURL:url];
    NSDictionary *mainCompte = [[MultisManager sharedManager] getMainCompte];
    [arequest setPostValue:@"1" forKey:@"p"];
    [arequest setPostValue:[mainCompte objectForKey:PSEUDO_DISPLAY_KEY] forKey:@"pseudo"];
    [arequest setPostValue:@"" forKey:@"ColorUsedMem"];
    [arequest setPostValue:@"Valider votre message" forKey:@"submit"];
    [arequest setPostValue:@"" forKey:@"parents"];
    [arequest setPostValue:@"1" forKey:@"MsgIcon"];
    [arequest setPostValue:@"1100" forKey:@"verifrequet"];
    [arequest setPostValue:@"0" forKey:@"new"];
    [arequest setPostValue:@"" forKey:@"search_smilies"];
    [arequest setPostValue:@"" forKey:@"stickold"];
    [arequest setPostValue:@"0" forKey:@"sond"];
    [arequest setPostValue:@"1" forKey:@"signature"];
    [arequest setPostValue:@"0" forKey:@"sondage"];
    [arequest setPostValue:@"0" forKey:@"smiley"];
    [arequest setPostValue:@"0" forKey:@"owntopic"];
    [arequest setPostValue:@"" forKey:@"numrep"];
    [arequest setPostValue:[mainCompte objectForKey:HASH_KEY] forKey:@"hash_check"];
    [arequest setPostValue:@"prive" forKey:@"cat"];
    [arequest setPostValue:@"0" forKey:@"wysiwyg"];
    [arequest setPostValue:@"1" forKey:@"page"];
    [arequest setPostValue:@"" forKey:@"password"];
    [arequest setPostValue:@"0" forKey:@"emaill"];
    [arequest setPostValue:@"hfr.inc" forKey:@"config"];
    [arequest setPostValue:@"" forKey:@"cache"];
    [arequest setPostValue:data forKey:@"content_form"];
    [arequest setPostValue:MP_NAME forKey:@"sujet"];
    if (bNew) {
        [arequest setPostValue:MP_SENDTO forKey:@"dest"];
        [arequest setPostValue:@"" forKey:@"numreponse"];
        [arequest setPostValue:@"" forKey:@"post"];
    } else {
        [arequest setPostValue:sNumRep forKey:@"numreponse"];
        [arequest setPostValue:sPostId forKey:@"post"];
    }
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
