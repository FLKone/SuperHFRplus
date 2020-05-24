//
//  RehostCell.h
//  HFRplus
//
//  Created by Shasta on 16/12/2013.
//
//

#import <UIKit/UIKit.h>
#import "RehostImage.h"

@interface RehostCell : UITableViewCell <UIAlertViewDelegate> {}

@property (nonatomic, strong) IBOutlet UIImageView *previewImage;
@property (nonatomic, strong) IBOutlet UIButton *miniBtn;
@property (nonatomic, strong) IBOutlet UIButton *previewBtn;
@property (nonatomic, strong) IBOutlet UIButton *fullBtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) RehostImage *rehostImage;
@property (strong, nonatomic) IBOutlet UIButton *mediumBtn;

-(void)configureWithRehostImage:(RehostImage *)image;

-(IBAction)copyFull;
-(IBAction)copyMedium;
-(IBAction)copyPreview;
-(IBAction)copyMini;


@end
