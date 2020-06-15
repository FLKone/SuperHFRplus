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
            
            if (self.rehostImage.link_full) {
                [self_.fullBtn setHidden:NO];
            } else {
                [self_.fullBtn setHidden:YES];
            }
            if (self.rehostImage.link_medium) {
                [self_.mediumBtn setHidden:NO];
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
            } else {
                [self_.miniBtn setHidden:YES];
            }
        }
        
        [self_.spinner stopAnimating];
    }];
    
}

-(IBAction)copyFull {
    [self copyToPasteBoard:bbcodeImageFull];
}

- (IBAction)copyMedium {
    [self copyToPasteBoard:bbcodeImageMedium];
}

-(IBAction)copyPreview {
    [self copyToPasteBoard:bbcodeImagePreview];
}

-(IBAction)copyMini {
    [self copyToPasteBoard:bbcodeImageMini];
}

- (void)copyToPasteBoard:(bbcodeImageSizeType)imageSizeType
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"";
    
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_use_link"]) {
        case bbcodeLinkOnly:
		{
			switch (imageSizeType) {
				case bbcodeImageFull:
					pasteboard.string = rehostImage.link_full;
					break;
                case bbcodeImageMedium:
                    pasteboard.string = rehostImage.link_medium;
                    break;
                case bbcodeImagePreview:
                    pasteboard.string = rehostImage.link_preview;
                    break;
				case bbcodeImageMini:
					pasteboard.string = rehostImage.link_miniature;
					break;
			}
			break;
		}
		case bbcodeImageNoLink:
			switch (imageSizeType) {
				case bbcodeImageFull:
                    pasteboard.string = [NSString stringWithFormat:@"[img]%@[/img]", rehostImage.link_full];
					break;
                case bbcodeImageMedium:
                    pasteboard.string = [NSString stringWithFormat:@"[img]%@[/img]", rehostImage.nolink_medium];
                    break;
				case bbcodeImagePreview:
					pasteboard.string = [NSString stringWithFormat:@"[img]%@[/img]", rehostImage.nolink_preview];
					break;
				case bbcodeImageMini:
					pasteboard.string = [NSString stringWithFormat:@"[img]%@[/img]", rehostImage.nolink_miniature];
					break;
			}
			break;
        case bbcodeImageWithLink:
        {
            switch (imageSizeType) {
                case bbcodeImageFull:
                    pasteboard.string = [NSString stringWithFormat:@"[url=%@][img]%@[/img][/url]", rehostImage.link_full, rehostImage.link_full];
                    break;
                case bbcodeImageMedium:
                    pasteboard.string = [NSString stringWithFormat:@"[url=%@][img]%@[/img][/url]", rehostImage.link_full, rehostImage.link_medium];
                    break;
                case bbcodeImagePreview:
                    pasteboard.string = [NSString stringWithFormat:@"[url=%@][img]%@[/img][/url]", rehostImage.link_full, rehostImage.link_preview];
                    break;
                case bbcodeImageMini:
                    pasteboard.string = [NSString stringWithFormat:@"[url=%@][img]%@[/img][/url]", rehostImage.link_full, rehostImage.link_miniature];
                    break;
            }
			break;
        }
	}

    //NSLog(@"%@", pasteboard.string);
    if (pasteboard.string.length) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"imageReceived" object:pasteboard.string];
    }
}
@end
