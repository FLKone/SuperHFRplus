//
//  MPStorage.h
//  HFRplus
//
//  Created by ezzz on 03/08/2019.
//
//

#import <Foundation/Foundation.h>

@class Bookmark;

@interface MPStorage : NSObject
{
}

@property BOOL bIsActive;
@property BOOL bIsMPStorageSavedSuccessfully;
@property NSString* sLastSucessAcessDate;
@property NSDictionary* dData;
@property NSString* sPostId;
@property NSString* sNumRep;
@property NSMutableArray*  listInternalBlacklistPseudo;
@property NSMutableArray*  listMPBlacklistPseudo;
@property NSMutableArray*  listBookmarks;
@property NSDictionary*    dicMPBlacklistPseudoTimestamp;
@property NSDictionary*    dicFlags;
@property NSDictionary*    dicProcessedFlag;
@property NSNumber*        nbTopicId;
@property UIViewController*       targetViewController;
@property SEL                     didFinishReloadSelector;

+ (MPStorage *)shared;

- (BOOL)initOrResetMP:(NSString*)pseudo;
- (BOOL)initOrResetMP:(NSString*)pseudo fromView:(UIView*)view;
- (void)loadBlackListAsynchronous;
- (BOOL)addBlackListSynchronous:(NSString*)pseudo;
- (BOOL)removeBlackListSynchronous:(NSString*)pseudo;
- (void)updateMPFlagAsynchronous:(NSDictionary*)newFlag;
- (void)removeMPFlagAsynchronous:(int)topicID;
- (NSString*)getUrlFlagForTopidId:(int)topicID;
- (NSInteger)getPageFlagForTopidId:(int)topicID;
- (void)reloadMPStorageAsynchronous;
- (int)getBookmarksNumber ;
- (Bookmark*)getBookmarkAtIndex:(int)index;
- (void)parseBookmarks;

@end
