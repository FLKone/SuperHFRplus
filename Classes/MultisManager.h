//
//  MultisManager.h
//  HFRplus
//
//  Created by Aynolor on 29/09/18.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface MultisManager : NSObject 

@property NSArray* comptes;

+ (id)sharedManager;
- (NSArray *)getComtpes;
- (void)addCompteWithPseudo:(NSString *)pseudo andCookies:(NSArray *)cookies andAvatar:(nullable NSString *)avatar andHash:(NSString *)hash;
- (void)setPseudoAsMain:(NSString *)pseudo;
- (NSDictionary *)getMainCompte;
- (NSString *)getCurrentPseudo;
- (void)deletePseudoAtIndex:(NSInteger *)index;
- (UIImage *)getAvatarForCompte:(NSDictionary *)compte;
- (void)forceCookiesForCompte:(NSDictionary *)compte;
- (void)setHashForCompte:(NSDictionary *)compteToUpdate andHash:(NSString *)hash;
- (void)updateCookies:(NSArray *)cookies;
- (void)updateAllAccounts;
@end
