//
//  BlackList.h
//  HFRplus
//
//  Created by FLK on 28/08/2015.
//
//

#import <Foundation/Foundation.h>

@interface BlackList : NSObject
{
    NSMutableArray *list;
}

@property (nonatomic, strong) NSMutableDictionary *dicBlackList;
@property (nonatomic, strong) NSMutableArray *listWhiteList;

+ (BlackList *)shared;
- (NSInteger)addToBlackList:(NSString *)pseudo andSave:(BOOL)bSave;
- (void)addToWhiteList:(NSString *)pseudo;
- (BOOL)removeFromBlackList:(NSString*)pseudo andSave:(BOOL)bSave;
- (bool)removeFromWhiteList:(NSString*)pseudo;
- (bool)isBL:(NSString*)pseudo;
- (bool)isWL:(NSString*)pseudo;
- (NSMutableArray *)getBlackListForActiveCompte;
- (void) setBlackListForActiveCompte:(NSMutableArray*)listBlackListUpdated;
- (NSArray *)getAllWhiteList;
@end
