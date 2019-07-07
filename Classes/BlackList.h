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

@property (nonatomic, strong) NSMutableArray *listBlackList;
@property (nonatomic, strong) NSMutableArray *listWhiteList;

+ (BlackList *)shared;
- (void)addToBlackList:(NSString *)pseudo;
- (void)addToWhiteList:(NSString *)pseudo;
/*- (void)addDictionnary:(NSDictionary *)dico;
- (bool)removeAt:(int)index;*/
- (bool)removeFromBlackList:(NSString*)pseudo;
- (bool)removeFromWhiteList:(NSString*)pseudo;
- (bool)isBL:(NSString*)pseudo;
- (bool)isWL:(NSString*)pseudo;
- (NSArray *)getAllBlackList;
- (NSArray *)getAllWhiteList;
@end
