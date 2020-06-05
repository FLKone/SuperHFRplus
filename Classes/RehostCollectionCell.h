//
//  RehostCollectionCell.h
//  HFRplus
//
//  Created by ezzz on 05/2020
//
//

#import <UIKit/UIKit.h>
#import "RehostImage.h"

@interface RehostCollectionCell : UICollectionViewCell

@property (strong,nonatomic) UIImageView *previewImage;
@property (nonatomic, strong) IBOutlet UIButton *fullBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) RehostImage *rehostImage;

- (void)configureWithIcon:(UIImage *)image border:(int)border;
- (void)configureWithRehostImage:(RehostImage *)image;

@end

@interface SmileyCollectionCell : UICollectionViewCell

@property (strong,nonatomic) UIImageView *smileyImage;
@property (strong,nonatomic) UIButton *smileyButton;
@property (strong, nonatomic) NSString *smileyCode;

@end
