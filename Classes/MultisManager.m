//
//  MultisManager.m
//  HFRplus
//
//  Created by Aynolor on 29/09/18.
//
//

#import "MultisManager.h"
#import "Constants.h"
#import "ThemeManager.h"
#import "ThemeColors.h"
#import "HFRplusAppDelegate.h"
#import <SimpleKeychain/SimpleKeychain.h>
#import "ASIFormDataRequest.h"




@implementation MultisManager

@synthesize comptes;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static MultisManager *sharedMultisManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMultisManager = [[self alloc] init];
    });
    return sharedMultisManager;
}

- (id)init {
    if (self = [super init]) {
       // Uncomment to reset keychain 
       // [[A0SimpleKeychain keychain] setData:[NSKeyedArchiver archivedDataWithRootObject:[NSArray array]] forKey:HFR_COMPTES_KEY];
    }
    return self;
}


- (NSArray *)getComtpes{
    NSData *comptesData = [[A0SimpleKeychain keychain] dataForKey:HFR_COMPTES_KEY];
    NSArray *comptesArray = (NSArray*) [NSKeyedUnarchiver unarchiveObjectWithData:comptesData];
    return comptesArray ? comptesArray : [NSArray array];
}

- (void)addCompteWithPseudo:(NSString *)pseudo andCookies:(NSArray *)cookies andAvatar:(nullable NSString *)avatar andHash:(nullable NSString *)hash{
    NSData *comptesData = [[A0SimpleKeychain keychain] dataForKey:HFR_COMPTES_KEY];
    NSMutableArray *comptesArray = comptesData ? [(NSArray*) [NSKeyedUnarchiver unarchiveObjectWithData:comptesData] mutableCopy] : [NSMutableArray array];
    NSMutableDictionary *newCompte = [NSMutableDictionary dictionary];
    [newCompte setValue:pseudo forKey:PSEUDO_KEY];
    [newCompte setValue:cookies forKey:COOKIES_KEY];
    if(hash){
        [newCompte setValue:hash forKey:HASH_KEY];
    }
    if(avatar){
        [newCompte setValue:avatar forKey:AVATAR_KEY];
    }
    
    // TODO : check if compte already exist
    if([comptesArray count]== 0){
         [newCompte setObject:[NSNumber numberWithBool:YES] forKey:MAIN_KEY];
    }
    [comptesArray addObject:newCompte];
    [[A0SimpleKeychain keychain] setData:[NSKeyedArchiver archivedDataWithRootObject:comptesArray] forKey:HFR_COMPTES_KEY];
    [self setCookiesForMain];

}

- (void)setPseudoAsMain:(NSString *)pseudo{
    NSArray *comptesArray = [self getComtpes];
    BOOL alreadyMain = NO;
    for (NSMutableDictionary* compte in comptesArray) {
        if([pseudo isEqualToString:[compte objectForKey:PSEUDO_KEY]]){
            alreadyMain = [[compte objectForKey:MAIN_KEY] boolValue];
            [compte setObject:[NSNumber numberWithBool:YES] forKey:MAIN_KEY];
        }else{
            [compte setObject:[NSNumber numberWithBool:NO] forKey:MAIN_KEY];
        }
    }
    if(!alreadyMain){
        [[A0SimpleKeychain keychain] setData:[NSKeyedArchiver archivedDataWithRootObject:comptesArray] forKey:HFR_COMPTES_KEY];
        [self setCookiesForMain];
    }
}

- (void)setCookiesForMain {
    NSArray *comptesArray = [self getComtpes];
    NSArray *mainCookies;
    for (NSMutableDictionary* compte in comptesArray) {
        if([[compte objectForKey:MAIN_KEY] boolValue]){
            mainCookies = [compte objectForKey:COOKIES_KEY];
        }
    }
    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [self lougout];
    
    for (NSHTTPCookie *bCookie in mainCookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:bCookie];
    }
    [[HFRplusAppDelegate sharedAppDelegate] login];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginChangedNotification object:nil];
}

- (void)deletePseudoAtIndex:(NSInteger *)index{
    NSMutableArray *comptesArray = [NSMutableArray arrayWithArray:[self getComtpes]];
    [comptesArray removeObjectAtIndex:index];
    [[A0SimpleKeychain keychain] setData:[NSKeyedArchiver archivedDataWithRootObject:comptesArray] forKey:HFR_COMPTES_KEY];
    if([comptesArray count] == 1){
        [self setPseudoAsMain:[[comptesArray objectAtIndex:0] objectForKey:PSEUDO_KEY]];
    }else if([comptesArray count] == 0){
        [self lougout];
    }
}

- (void)lougout {
    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookShared cookies];
    
    for (NSHTTPCookie *aCookie in cookies) {
        [cookShared deleteCookie:aCookie];
    }
    
    [[HFRplusAppDelegate sharedAppDelegate] logout];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginChangedNotification object:nil];
}


-(NSDictionary *)getMainCompte {
    NSArray *comptesArray = [self getComtpes];
    NSDictionary *main;
    for (NSMutableDictionary* compte in comptesArray) {
        if([[compte objectForKey:MAIN_KEY] boolValue]){
            main = compte;
        }
    }
    return main;
}

-(UIImage *)getAvatarForCompte:(NSDictionary *)compte{
    NSData* avatar = [compte objectForKey:AVATAR_KEY];
    if(!avatar ){
        Theme theme = [[ThemeManager sharedManager] theme];
        return[ThemeColors avatar:theme];
    }else{
        return [UIImage imageWithData:avatar];
    }
}

- (void)forceCookiesForCompte:(NSDictionary *)compte {
    NSArray *mainCookies = [compte objectForKey:COOKIES_KEY];
    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookShared cookies];

    for (NSHTTPCookie *aCookie in cookies) {
        [cookShared deleteCookie:aCookie];
    }

    for (NSHTTPCookie *bCookie in mainCookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:bCookie];
    }
}

- (void)setHashForCompte:(NSDictionary *)compteToUpdate andHash:(NSString *)hash {
    NSArray *comptesArray = [self getComtpes];
    for (NSMutableDictionary* compte in comptesArray) {
        if([[compte objectForKey:PSEUDO_KEY] isEqualToString:[compteToUpdate objectForKey:PSEUDO_KEY]]){
            [compte setValue:hash forKey:HASH_KEY];
        }
    }
}

- (void)updateCookies:(NSArray *)cookies {
    NSArray *comptesArray = [self getComtpes];
    for (NSHTTPCookie *aCookie in cookies) {
        if([aCookie.name isEqualToString:@"md_user"] && ![aCookie.value isEqualToString:@"deleted"] ){
            for (NSMutableDictionary* compte in comptesArray) {
                if([[compte objectForKey:PSEUDO_KEY] isEqualToString:aCookie.value] ||  [[self sanitizePseudo:[compte objectForKey:PSEUDO_KEY]] isEqualToString:aCookie.value]){
                    [compte setValue:cookies forKey:COOKIES_KEY];
                }
            }
        }
    }
    [[A0SimpleKeychain keychain] setData:[NSKeyedArchiver archivedDataWithRootObject:comptesArray] forKey:HFR_COMPTES_KEY];
}

- (void)updateAllAccounts{
    NSArray *comptesArray = [self getComtpes];
     // Migrate check
    if(comptesArray.count == 0){
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *aCookie in cookies) {
            if([aCookie.name isEqualToString:@"md_user"] && ![aCookie.value isEqualToString:@"deleted"]){
                // There is an account
                [self createAccountFromCachedCookies:cookies andPseudo:aCookie.value];
            }
        }
        return;
    }
    for (NSMutableDictionary* compte in comptesArray) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/editprofil.php?config=hfr.inc&page=1", [k ForumURL]]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[compte objectForKey:COOKIES_KEY]];
        [request startAsynchronous];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self updateCookies:request.responseCookies];
}

-(void)createAccountFromCachedCookies:(NSArray *)cookies andPseudo:(NSString *)pseudo {
    [self addCompteWithPseudo:pseudo andCookies:cookies andAvatar:nil andHash:nil];
}

-(NSString *)sanitizePseudo:(NSString *)pseudo  {
    NSCharacterSet *allowedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[] "] invertedSet];
    return [pseudo stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
}


@end
