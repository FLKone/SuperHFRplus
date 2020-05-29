//
//  RehostCollectionCell.h
//  HFRplus
//
//  Created by ezzz on 05/2020
//
//

#import <UIKit/UIKit.h>
#import "RehostImage.h"

/*
@interface RehostCollectionCell : UICollectionViewCell <UIAlertViewDelegate> {
}

@property (nonatomic, strong) RehostImage *rehostImage;

-(IBAction)copyImage;

-(void)configureWithRehostImage:(RehostImage *)image;

- (void)copyToPasteBoard:(bbcodeImageSizeType)imageSizeType withLink:(bbcodeLinkType)linkType;
*/
@interface RehostCollectionCell : UICollectionViewCell

@property (strong,nonatomic) UIImageView *previewImage;
@property (nonatomic, strong) IBOutlet UIButton *fullBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) RehostImage *rehostImage;

- (void)configureWithIcon:(UIImage *)image border:(int)border;
- (void)configureWithRehostImage:(RehostImage *)image;

- (IBAction)copyFull;

@end
