//
//  RehostCell.m
//  HFRplus
//
//  Created by Shasta on 16/12/2013.
//
//

#import "RehostCell.h"
#import "RehostImage.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "ThemeManager.h"
#import "ThemeColors.h"

@implementation RehostCell
@synthesize previewImage, rehostImage;
@synthesize miniBtn, previewBtn, mediumBtn, fullBtn, spinner;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.miniBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [self.mediumBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [self.previewBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [self.fullBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    
    self.miniBtn.layer.cornerRadius = 5; // this value vary as per your desire
    self.miniBtn.layer.borderWidth = 1; // this value vary as per your desire
    self.miniBtn.clipsToBounds = YES;

    self.mediumBtn.layer.cornerRadius = 5; // this value vary as per your desire
    self.mediumBtn.layer.borderWidth = 1; // this value vary as per your desire
    self.mediumBtn.clipsToBounds = YES;

    self.previewBtn.layer.cornerRadius = 5; // this value vary as per your desire
    self.previewBtn.layer.borderWidth = 1; // this value vary as per your desire
    self.previewBtn.clipsToBounds = YES;

    self.fullBtn.layer.cornerRadius = 5; // this value vary as per your desire
    self.fullBtn.layer.borderWidth = 1; // this value vary as per your desire
    self.fullBtn.clipsToBounds = YES;
    
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor =[ThemeColors cellBackgroundColor:theme];

    self.miniBtn.layer.borderColor = [ThemeColors tintColor].CGColor;
    self.mediumBtn.layer.borderColor = [ThemeColors tintColor].CGColor;
    self.previewBtn.layer.borderColor = [ThemeColors tintColor].CGColor;
    self.fullBtn.layer.borderColor = [ThemeColors tintColor].CGColor;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)configureWithRehostImage:(RehostImage *)image;
{
    NSLog(@"RehostCell configureWithRehostImage");

    self.rehostImage = image;
    
    [self.miniBtn setHidden:YES];
    [self.mediumBtn setHidden:YES];
    [self.previewBtn setHidden:YES];
    [self.fullBtn setHidden:YES];
    [self.previewImage setHidden:YES];
    [self.spinner setHidden:NO];
    [self.spinner startAnimating];
    
    NSString *url = self.rehostImage.nolink_preview;
    if (url == nil) {
        url = self.rehostImage.nolink_medium;
    }
    if (url == nil) {
        url = self.rehostImage.nolink_full;
    }

    
	url = [url stringByReplacingOccurrencesOfString:@"[img]" withString:@""];
	url = [url stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
	url = [url stringByReplacingOccurrencesOfString:@"hfr-rehost.net" withString:@"reho.st"];
    //NSLog(@"url = %@", url);

    __weak RehostCell *self_ = self;

    [self.previewImage sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //
        if (image) {
            [self_.previewImage setImage:image];
            [self_.previewImage setHidden:NO];
            [self.previewBtn setHidden:YES];

            if (self.rehostImage.link_full) {
                [self_.fullBtn setHidden:NO];
                self_.fullBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                self_.fullBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                
                if (self_.rehostImage.full_width && [self_.rehostImage.full_width intValue] > 0 && self_.rehostImage.full_height && [self_.rehostImage.full_height intValue] > 0) {
                    // Only display maximum dimension
                    if ([self_.rehostImage.full_width intValue] > [self_.rehostImage.full_height intValue]) {
                        [self_.fullBtn setTitle:[NSString stringWithFormat:@"Maxi\n%@ px", self_.rehostImage.full_width] forState: UIControlStateNormal];
                    }
                    else {
                        [self_.fullBtn setTitle:[NSString stringWithFormat:@"Maxi\n%@ px", self_.rehostImage.full_height] forState: UIControlStateNormal];
                    }
                }
                else {
                    [self_.fullBtn setTitle:[NSString stringWithFormat:@"Maxi"] forState: UIControlStateNormal];
                }
            } else {
                [self_.fullBtn setHidden:YES];
            }
            if (self.rehostImage.link_medium) {
                [self_.mediumBtn setHidden:NO];
                self_.mediumBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                self_.mediumBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                [self_.mediumBtn setTitle:@"Medium\n800 px" forState: UIControlStateNormal];
            } else {
                [self_.mediumBtn setHidden:YES];
            }
            if (self.rehostImage.link_preview) {
                [self_.previewBtn setHidden:NO];
            } else {
                [self_.previewBtn setHidden:YES];
            }
            if (self.rehostImage.link_miniature) {
                [self_.miniBtn setHidden:NO];
                self_.miniBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                self_.miniBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                [self_.miniBtn setTitle:@"Mini\n120 px" forState: UIControlStateNormal];
            } else {
                [self_.miniBtn setHidden:YES];
            }
        }
        
        float height = self.bounds.size.height;
        float width = self.bounds.size.width;
        float b = 20; // Border size of every button
        float s = 50; // Shift to center a little more when there are only 2 buttons
        //NSLog(@"Calculating button position -------- w/h: %f, %f", width, height);
        if ([self.mediumBtn isHidden]) {
            self.fullBtn.frame = CGRectMake(b + s, b, width/3 - 2*b, height - 2*b);
            self.miniBtn.frame = CGRectMake(width*2/3 + b - s, b, width/3 - 2*b, height - 2*b);
            //NSLog(@"fullBtn %@", NSStringFromCGRect(self.fullBtn.frame));
            //NSLog(@"mediumBtn isHidden");
            //NSLog(@"miniBtn %@", NSStringFromCGRect(self.miniBtn.frame));
        }
        else {
            self.fullBtn.frame = CGRectMake(b, b, width/3 - 2*b, height - 2*b);
            self.mediumBtn.frame = CGRectMake(width/3 + b, b, width/3 - 2*b, height - 2*b);
            self.miniBtn.frame = CGRectMake(width*2/3 + b, b, width/3 - 2*b, height - 2*b);
            //NSLog(@"fullBtn %@", NSStringFromCGRect(self.fullBtn.frame));
            //NSLog(@"mediumBtn %@", NSStringFromCGRect(self.mediumBtn.frame));
            //NSLog(@"miniBtn %@", NSStringFromCGRect(self.miniBtn.frame));

        }
        [self_.spinner stopAnimating];
    }];
    
}

-(IBAction)copyFull {
    [self.rehostImage copyToPasteBoard:bbcodeImageFull];
}

- (IBAction)copyMedium {
    [self.rehostImage copyToPasteBoard:bbcodeImageMedium];
}

-(IBAction)copyPreview {
    [self.rehostImage copyToPasteBoard:bbcodeImagePreview];
}

-(IBAction)copyMini {
    [self.rehostImage copyToPasteBoard:bbcodeImageMini];
}

@end
