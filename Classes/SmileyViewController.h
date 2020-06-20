//
//  SmileyViewController.h
//  SuperHFRplus
//
//  Created by ezzz on 09/06/2020.
//

#import <UIKit/UIKit.h>
#import "SmileyCache.h"

@class AddMessageViewController, ASIHTTPRequest;

typedef enum {
    DisplayModeEnumSmileysDefault           = 0,
    DisplayModeEnumSmileysSearch            = 1,
    DisplayModeEnumTableSearch              = 2,
} DisplayModeEnum;

@interface SmileyViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource> {
    
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionSmileys;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSmileys;
@property (strong, nonatomic) IBOutlet UIButton *btnSmileySearch;
@property (strong, nonatomic) IBOutlet UIButton *btnSmileyDefault;
@property (strong, nonatomic) IBOutlet UIButton *btnReduce;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinnerSmileySearch;
@property (strong, nonatomic) IBOutlet UITableView *tableViewSearch;

@property (strong, nonatomic) SmileyCache *smileyCache;
@property (nonatomic, strong) NSMutableDictionary *usedSearchDict;
@property (nonatomic, strong) NSMutableArray *usedSearchSortedArray;
@property (strong, nonatomic) NSMutableArray *smileyArray;

@property ASIHTTPRequest *request;
@property ASIHTTPRequest *requestSmile;

@property AddMessageViewController* addMessageVC;
@property BOOL bModeFullScreen;
@property DisplayModeEnum displayMode;

- (void)actionReduce:(id)sender;
- (void)fetchSmileys;

@end
