//
//  CompteTableViewCell.h
//  HFRplus
//

#import <UIKit/UIKit.h>

@interface CompteTableViewCell : UITableViewCell {
    UILabel *pseudoLabel;
    UILabel *expiryLabel;
    UIImageView *avatarImageView;
}
@property (strong, nonatomic) IBOutlet UILabel *pseudoLabel;
@property (strong, nonatomic) IBOutlet UILabel *expiryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

-(void)setAvatar:(NSString *)avatarURL;
-(void)setExpiracy:(NSArray *)cookies;
- (void)setMained:(BOOL)main;
-(void)applyTheme;

@end
