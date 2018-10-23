//
//  CompteTableViewCell.m
//  HFRplus
//


#import "CompteTableViewCell.h"
#import "ThemeManager.h"
#import "ThemeColors.h"

@implementation CompteTableViewCell
@synthesize pseudoLabel, avatarImageView, expiryLabel;


- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
    avatarImageView.clipsToBounds = YES;
    avatarImageView.layer.borderWidth = 1.0f;
    self.backgroundColor = self.contentView.superview.backgroundColor = [UIColor clearColor];
    [expiryLabel setTextColor:[ThemeColors cellIconColor:theme]];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // Configure the view for the selected state
}

- (void)setMained:(BOOL)main {
    Theme theme = [[ThemeManager sharedManager] theme];
    if(main){
        [pseudoLabel setFont:[UIFont boldSystemFontOfSize:16.]];
        [pseudoLabel setTextColor:[ThemeColors tintColor:theme]];
        avatarImageView.layer.borderColor = [ThemeColors tintColor:theme].CGColor;
    }else{
        [pseudoLabel setFont:[UIFont systemFontOfSize:16.]];
         [pseudoLabel setTextColor:[ThemeColors cellIconColor:theme]];
        avatarImageView.layer.borderColor = [ThemeColors cellIconColor:theme].CGColor;

    }
}

-(void)setExpiracy:(NSArray *)cookies {
    NSHTTPCookie *cookie = [cookies objectAtIndex:0];
    NSTimeInterval interval = cookie.expiresDate.timeIntervalSinceNow; // In seconds
    double expiry = floor(interval/86400);
    NSNumber *NSExpiry = [NSNumber numberWithDouble:expiry];
    expiryLabel.text = [NSString stringWithFormat:@"Expire dans %@ jour(s)", [NSExpiry stringValue]];
}


-(void)setAvatar:(NSData *)avatar {
    if(!avatar ){
            Theme theme = [[ThemeManager sharedManager] theme];
            avatarImageView.image = [ThemeColors avatar:theme];
        }else{
            avatarImageView.image = [UIImage imageWithData:avatar];
        }
}

@end
