//
//  MPStorage.h
//  HFRplus
//
//  Created by ezzz on 03/08/2019.
//
//

#import <Foundation/Foundation.h>



@interface MPStorage : NSObject
{
}

@property NSDictionary* dData;
@property NSString* sPostId;
@property NSString* sNumRep;
@property NSMutableArray*  listInternalBlacklistPseudo;
@property NSMutableArray*  listMPBlacklistPseudo;
@property NSDictionary*    dicMPBlacklistPseudoTimestamp;

+ (MPStorage *)shared;

- (void)loadBlackListAsynchronous;
- (void)saveBlackListAsynchronous:(NSMutableArray*)listBlacklist;

@end
