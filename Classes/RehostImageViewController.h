//
//  RehostImageViewController.h
//  SuperHFRplus
//
//  Created by ezzz on 22/07/2020.
//

#ifndef RehostImageViewController_h
#define RehostImageViewController_h

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "ASIHTTPRequest.h"

@class AddMessageViewController, ASIHTTPRequest;

@interface RehostImageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
 {
     id _popover;
     UIPickerView        *myPickerView;
}

// Data

@property (nonatomic, strong) NSMutableArray *rehostImagesArray;
@property (nonatomic, strong) NSMutableArray *rehostImagesSortedArray;
@property AddMessageViewController* addMessageVC;

// UI

@property (nonatomic, strong) id popover;
@property (strong, nonatomic) IBOutlet UITableView *tableViewImages;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionImages;
@property (strong, nonatomic) IBOutlet UIButton *btnCamera;
@property (strong, nonatomic) IBOutlet UIButton *btnPhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnBBCodeType;
@property (strong, nonatomic) IBOutlet UIButton *btnMaxSize;
@property (strong, nonatomic) IBOutlet UIButton *btnReduce;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property BOOL bModeFullScreen;

// Methods

- (void)updateExpandButton;
- (float)getDisplayHeight;
- (void)actionReduce:(id)sender;
- (void)updateTheme;

@end

#endif /* RehostImageViewController_h */
