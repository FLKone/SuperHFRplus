//
//  RehostCell.h
//  HFRplus
//
//  Created by Shasta on 16/12/2013.
//
//

#import <UIKit/UIKit.h>
@class RehostImage;

typedef NS_ENUM(NSInteger, bbcodeImageSizeType) {
    bbcodeImageFull,
    bbcodeImageMedium,
    bbcodeImagePreview,
    bbcodeImageMini
};

typedef NS_ENUM(NSInteger, bbcodeLinkType) {
    bbcodeImageWithLink,
    bbcodeImageNoLink,
    bbcodeLinkOnly
};

@interface RehostCell : UITableViewCell <UIAlertViewDelegate> {
    UIImageView *previewImage;
    UIButton *miniBtn;
    UIButton *mediumBtn;
    UIButton *previewBtn;
    UIButton *fullBtn;
    UIActivityIndicatorView *spinner;
    RehostImage *rehostImage;
}

@property (nonatomic, strong) IBOutlet UIImageView *previewImage;
@property (nonatomic, strong) IBOutlet UIButton *miniBtn;
@property (nonatomic, strong) IBOutlet UIButton *previewBtn;
@property (nonatomic, strong) IBOutlet UIButton *fullBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) RehostImage *rehostImage;
@property (strong, nonatomic) IBOutlet UIButton *mediumBtn;

-(IBAction)copyFull;
-(IBAction)copyMedium;
-(IBAction)copyPreview;
-(IBAction)copyMini;
-(void)configureWithRehostImage:(RehostImage *)image;

- (void)copyToPasteBoard:(bbcodeImageSizeType)imageSizeType withLink:(bbcodeLinkType)linkType;

@end
