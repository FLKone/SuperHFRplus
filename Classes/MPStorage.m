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

@synthesize bIsActive, bIsMPStorageSavedSuccessfully, sLastSucessAcessDate,dData, sPostId, sNumRep, listInternalBlacklistPseudo, listMPBlacklistPseudo, dicMPBlacklistPseudoTimestamp, dicFlags, dicProcessedFlag;
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
        bIsMPStorageSavedSuccessfully = YES; // A startup, every thing is fine
    }
    return self;
}

- (BOOL)initOrResetMP:(NSString*)pseudo {
    if (pseudo) {
        NSMutableDictionary* dicMPStorage_postid = [[NSUserDefaults standardUserDefaults] objectForKey:@"dicMPStorage_postid"];
        
        if (dicMPStorage_postid == nil || [dicMPStorage_postid objectForKey:pseudo] == nil) {
            // Find MP with title a2bcc09b796b8c6fab77058ff8446c34
            if ([self findStorageMPFromPage:1] == NO) {
                [HFRAlertView DisplayOKCancelAlertViewWithTitle:@"Stockage MP" andMessage:@"Le MP de stockage n'a pas été trouvé. Voulez vous qu'il soit créé ?" handlerOK:^(UIAlertAction *action) {
                    
                    // Create empty structure
                    if ([self createEmptyMPStorage] == NO) {
                        bIsActive = NO;
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"mpstorage_active"];
                        return;
                    }
                    
                    // Search again to find post ID
                    if ([self findStorageMPFromPage:1] == NO) {
                        [HFRAlertView DisplayOKAlertViewWithTitle:@"Oups !" andMessage:@"Failed to find MPStorage after its creation"];
                        bIsActive = NO;
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"mpstorage_active"];
                        return;
                    }
                    
                    bIsActive = YES;
                    [[MPStorage shared] loadBlackListAsynchronous];
                }];
            }
        }
        else {
            sPostId = [dicMPStorage_postid valueForKey:pseudo];
        }
        bIsActive = YES;
        
        [[MPStorage shared] loadBlackListAsynchronous];
        return YES;
    }
    return NO;
}

// --------------------------------------------------------------------------------
// Load MPStorage
// --------------------------------------------------------------------------------

- (void)reloadMPStorageAsynchronous {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"mpstorage_active"]) {
        if (bIsMPStorageSavedSuccessfully) {
            ASIHTTPRequest *request = [self GETRequest];
            [request setShouldRedirect:NO];
            [request setDelegate:self];
            [request setDidFinishSelector:@selector(reloadMPStorageAsynchronousComplete:)];
            [request startAsynchronous];
        }
    }
}

- (void)reloadMPStorageAsynchronousComplete:(ASIHTTPRequest *)request
{
    if ([self parseMPStorage:[request responseString]]) {
        [self updateLastSucessAcessDate];
    }
}
// --------------------------------------------------------------------------------
// Load black list methods
// --------------------------------------------------------------------------------

- (void)loadBlackListAsynchronous {
    ASIHTTPRequest *request = [self GETRequest];
    [request setShouldRedirect:NO];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(loadBlackListComplete:)];
    [request setDidFailSelector:@selector(loadBlackListFailed:)];
    [request startAsynchronous];
}

- (void)loadBlackListFailed:(ASIHTTPRequest *)request
{
    [HFRAlertView DisplayOKAlertViewWithTitle:@"Oups !" andMessage:@"Request failed to load MPstorage for blacklist"];
}

- (void)loadBlackListComplete:(ASIHTTPRequest *)request
{
    if ([self updateBlackList:[request responseString]] == NO) {
        // TODO Retry later
    }
}

- (BOOL)updateBlackList:(NSString *)content
{
    BOOL success = NO;
    @try {
        if (![self parseMPStorage:content]) return NO;

        // Reset black list and fill it with MPStorage values
        [[BlackList shared] setBlackListForActiveCompte:[NSMutableArray array]];
        
        for (NSDictionary *dUser in dData[@"data"][0][@"blacklist"][@"list"]) {
            [[BlackList shared] addToBlackList:[dUser valueForKey:@"username"] andSave:NO];
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
    ASIHTTPRequest *request = [self GETRequest];
    [request startSynchronous];
    if (request) {
        if ([request error]) {
            NSLog(@"error: %@", [[request error] localizedDescription]);
            return NO;
        }
        
        if ([request responseString])
        {
            if (![self parseMPStorage:[request responseString]]) return NO;
            
            // Check if pseudo already exists in list
            NSUInteger index = 0;
            NSUInteger indexFound = -1;
            for (NSDictionary* dUser in dData[@"data"][0][@"blacklist"][@"list"]) {
                NSString* pseudo = [dUser valueForKey:@"username"];
                if ([[pseudo lowercaseString] isEqualToString:[newPseudoBL lowercaseString]]) {
                    indexFound = index;
                }
                index++;
            }
            
             // Not found, so it can be added
            if (indexFound == -1) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: TIMESTAMP, @"createDate", newPseudoBL, @"username", nil];
                [dData[@"data"][0][@"blacklist"][@"list"] insertObject:dict atIndex:0];
                [dData setValue:TIMESTAMP forKey:@"lastUpdate"];
                [dData setValue:MP_SOURCE_NAME forKey:@"sourceName"];

                return [self saveMPStorageSynchronous];
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
            if (![self parseMPStorage:[request responseString]]) return NO;

            // Check if pseudo already exists in list
            NSUInteger index = 0;
            NSUInteger indexFound = -1;
            for (NSDictionary* dUser in dData[@"data"][0][@"blacklist"][@"list"]) {
                NSString* pseudo = [dUser valueForKey:@"username"];
                if ([[pseudo lowercaseString] isEqualToString:[pseudoBLtoRemove lowercaseString]]) {
                    indexFound = index;
                }
                index++;
            }
            
            // Found, so it can be removed
            if (indexFound >= 0) {
                [dData[@"data"][0][@"blacklist"][@"list"] removeObjectAtIndex: indexFound];
                
                return [self saveMPStorageSynchronous];
            }
        }
    }
    return NO;
}

// --------------------------------------------------------------------------------
// Save MP flags methods
// --------------------------------------------------------------------------------

- (BOOL)updateMPFlagAsynchronous:(NSDictionary*)newFlag {
    dicProcessedFlag = newFlag;
    // Only reload MPStorage when it has been saved successfuly last time
    if (bIsMPStorageSavedSuccessfully) {
        ASIHTTPRequest *request = [self GETRequest];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(updateFlag:)];
        [request setDidFailSelector:@selector(updateMPFlagAsynchronousFailed:)];
        [request startAsynchronous];
    }
    else { // Else, only update internally and try again to save data to MPStorage
        [self updateFlagInternally];
        [self saveMPStorageAsynchronous];
    }
}

- (void)updateMPFlagAsynchronousFailed:(ASIHTTPRequest *)request {
    bIsMPStorageSavedSuccessfully = NO;
    
    // TODO Add Timer to do a retry after like
}

- (void)updateFlag:(ASIHTTPRequest *)request
{
    BOOL success = NO;

    // If content is not parsed, then error
    if ([self parseMPStorage:[request responseString]]) {
        
        if ([self updateFlagInternally]) {
            success = [self saveMPStorageAsynchronous];
        }
    }
}

- (BOOL)updateFlagInternally {
    @try {
        // Check if post (topic) already exists in list and remove it
        NSUInteger index = 0;
        NSUInteger indexFound = -1;
        for (NSDictionary* dFlag in dData[@"data"][0][@"mpFlags"][@"list"]) {
            NSNumber* post = [dFlag valueForKey:@"post"];
            NSNumber* addedPost = [dicProcessedFlag valueForKey:@"post"];
            if ([post isEqualToNumber:addedPost]) {
                indexFound = index;
            }
            index++;
        }
        
        // Remove the found flag
        if (indexFound >= 0) {
            [dData[@"data"][0][@"mpFlags"][@"list"] removeObjectAtIndex: indexFound];
        }
        
        // Add the new flag
        [dData[@"data"][0][@"mpFlags"][@"list"] insertObject:dicProcessedFlag atIndex:0];
        [dData setValue:TIMESTAMP forKey:@"lastUpdate"];
        [dData setValue:MP_SOURCE_NAME forKey:@"sourceName"];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [HFRAlertView DisplayOKAlertViewWithTitle:@"MPStorage error !" andMessage:@"Error parsing data while updating MP flags."];
        return NO;
    }
    @finally {}
    return YES;
}

- (NSString*)getUrlFlagForTopidId:(int)iTopicId {
    NSString* retUrl = nil;
    // Check if topic  exists in list
    for (NSDictionary* dFlag in dData[@"data"][0][@"mpFlags"][@"list"]) {
        NSInteger post = [[dFlag valueForKey:@"post"] integerValue];
        if (post == iTopicId) {
            retUrl = [dFlag valueForKey:@"uri"];
            break;
        }
    }
    return retUrl;
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
                        
                        NSMutableDictionary* dicMPStorage_postid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"dicMPStorage_postid"] mutableCopy];
                        if (dicMPStorage_postid == nil) dicMPStorage_postid = [NSMutableDictionary dictionary];
                        [dicMPStorage_postid setValue:sPostId forKey:[[MultisManager sharedManager] getCurrentPseudo]];
                        [[NSUserDefaults standardUserDefaults] setObject:dicMPStorage_postid forKey:@"dicMPStorage_postid"];
                        
                        return YES;
                    }
                }
            }
        }
    }

    // If not find on current page, search it on next page
    if (iMaxPages > 1 && pageId < iMaxPages) {
        return [self findStorageMPFromPage:(pageId+1)];
    }
    
    return NO;
}

- (BOOL)createEmptyMPStorage {
    // POST request to save new content
    NSString* stringJson = [NSString stringWithFormat: @"{\"data\":[{\"version\":\"0.1\",\"blacklist\":{\"list\":[],\"sourceName\":\"%@\",\"lastUpdate\":%@},\"mpFlags\":{\"list\":[],\"sourceName\":\"%@\",\"lastUpdate\":%@}, ,\"sourceName\":\"%@\",\"lastUpdate\":%@],\"sourceName\":\"%@\",\"lastUpdate\":%@}", MP_SOURCE_NAME, TIMESTAMP, MP_SOURCE_NAME, TIMESTAMP, MP_SOURCE_NAME, TIMESTAMP, MP_SOURCE_NAME, TIMESTAMP ];
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

- (BOOL)parseMPStorage:(NSString *)content
{
    if ([content containsString:@"destiné"]) {
        [HFRAlertView DisplayOKAlertViewWithTitle:@"Oups !" andMessage:@"Le MP de stockage semble avoir été supprimé. La fonctionalité va être desactivée"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"mpstorage_active"];
        bIsActive = NO;
        return NO;
    }

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

        if (error) {
            [HFRAlertView DisplayOKAlertViewWithTitle:@"Oups !" andMessage:@"MPstorage JSON parsing error"];
            return NO;
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [HFRAlertView DisplayOKAlertViewWithTitle:@"Oups !" andMessage:@"MPstorage global parsing error"];
        return NO;
    }
    @finally {}
    
    [self updateLastSucessAcessDate];
    return YES;
}

- (BOOL)saveMPStorageSynchronous {
    bIsMPStorageSavedSuccessfully = NO;
    NSError* error = nil;
    NSData* dataJson = [NSJSONSerialization dataWithJSONObject:dData options:kNilOptions error:&error];
    NSString *stringJson = [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];

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
                [self updateLastSucessAcessDate];
                bIsMPStorageSavedSuccessfully = YES;
                return YES;
            }
        }
    }
}

- (BOOL)saveMPStorageAsynchronous {
    // Serialize JSON to be saved
    NSError* error = nil;
    NSData* dataJson = [NSJSONSerialization dataWithJSONObject:dData options:kNilOptions error:&error];
    NSString *stringJson = [[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];

    // POST request to save new content
    ASIFormDataRequest *requestPOST = [self POSTRequestWithData:stringJson newMessage:NO];
    [requestPOST startSynchronous];

    ASIHTTPRequest *request = [self GETRequest];
    [request setShouldRedirect:NO];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(saveMPStorageAsynchronousComplete:)];
    [request setDidFailSelector:@selector(saveMPStorageAsynchronousFailed:)];
    [request startAsynchronous];
}
    
- (void)saveMPStorageAsynchronousFailed:(ASIHTTPRequest *)request {
    bIsMPStorageSavedSuccessfully = NO;
    NSLog(@"ERROR updating MPstorage");
}

- (void)saveMPStorageAsynchronousComplete:(ASIHTTPRequest *)request
{
    bIsMPStorageSavedSuccessfully = NO;
    if ([request responseString])
    {
        if ([[request responseString] containsString:@"succès"]) {
            [self updateLastSucessAcessDate];
            bIsMPStorageSavedSuccessfully = YES;
        }
    }
}

- (void)updateLastSucessAcessDate {
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
    sLastSucessAcessDate = [objDateformat stringFromDate:[NSDate date]];
    
    // Update value into settings
    NSDictionary *dic =  [NSDictionary dictionaryWithObjectsAndKeys: sLastSucessAcessDate, @"mpstorage_last_rw", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dic];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
    
@end
