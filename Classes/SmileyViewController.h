//
//  SmileyViewController.h
//  SuperHFRplus
//
//  Created by ezzz on 09/06/2020.
//

#import <UIKit/UIKit.h>
#import "SmileyCache.h"
@class AddMessageViewController;

@interface SmileyViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {

}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionSmileys;
@property (strong, nonatomic) IBOutlet UITextField *textFieldSmileys;
@property (strong, nonatomic) IBOutlet UIButton *btnSmileySearch;
@property (strong, nonatomic) IBOutlet UIButton *btnSmileyDefault;
@property (strong, nonatomic) IBOutlet UIButton *btnReduce;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinnerSmileySearch;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) SmileyCache *smileyCache;
@property AddMessageViewController* addMessageVC;

- (IBAction)actionReduce;

@end
