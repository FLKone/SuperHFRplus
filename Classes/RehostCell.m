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
    self.miniBtn.clipsToBounds = YES;
    
    self.mediumBtn.layer.cornerRadius = 5; // this value vary as per your desire
    self.mediumBtn.clipsToBounds = YES;

    self.previewBtn.layer.cornerRadius = 5; // this value vary as per your desire
    self.previewBtn.clipsToBounds = YES;

    self.fullBtn.layer.cornerRadius = 5; // this value vary as per your desire
    self.fullBtn.clipsToBounds = YES;
        
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor =[ThemeColors cellBackgroundColor:theme];
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
            
            [self_.miniBtn setHidden:NO];
            [self_.previewBtn setHidden:NO];
            [self_.mediumBtn setHidden:NO];
            [self_.fullBtn setHidden:NO];
            [self_.miniBtn setHidden:NO];
        }
        
        [self_.spinner stopAnimating];
    }];
    
}

-(IBAction)copyFull {
    [self copyImage:bbcodeImageFull];
}

- (IBAction)copyMedium {
    [self copyImage:bbcodeImageMedium];
}

-(IBAction)copyPreview {
    [self copyImage:bbcodeImagePreview];
}

-(IBAction)copyMini {
    [self copyImage:bbcodeImageMini];
}

-(IBAction)copyImage:(bbcodeImageSizeType) bbcodeImageSize {

    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Copier le BBCode" message:@"Avec ou sans lien?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) { }];
    UIAlertAction* actionAvec = [UIAlertAction actionWithTitle:@"Avec" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) { [self copyToPasteBoard:bbcodeImageSize withLink:bbcodeImageWithLink]; }];
    UIAlertAction* actionSans = [UIAlertAction actionWithTitle:@"Sans" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) { [self copyToPasteBoard:bbcodeImageSize withLink:bbcodeImageNoLink]; }];
    UIAlertAction* actionLink = [UIAlertAction actionWithTitle:@"Le lien seulement" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) { [self copyToPasteBoard:bbcodeImageSize withLink:bbcodeLinkOnly]; }];
    
    [alert addAction:actionAvec];
    [alert addAction:actionSans];
    [alert addAction:actionLink];
    [alert addAction:cancelAction];
    
    UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    // Adjustment for ipad as we get the UISplitViewController:
    if ([activeVC isKindOfClass:[UISplitViewController class]]) {
        activeVC = [activeVC.childViewControllers objectAtIndex:0];
    }
    [activeVC presentViewController:alert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}

- (void)copyToPasteBoard:(bbcodeImageSizeType)imageSizeType withLink:(bbcodeLinkType)linkType
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"";
    
    switch (linkType) {
		case bbcodeImageWithLink:
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
					pasteboard.string = rehostImage.nolink_full;
					break;
                case bbcodeImageMedium:
                    pasteboard.string = rehostImage.nolink_medium;
                    break;
				case bbcodeImagePreview:
					pasteboard.string = rehostImage.nolink_preview;
					break;
				case bbcodeImageMini:
					pasteboard.string = rehostImage.nolink_miniature;
					break;
			}
			break;
        case bbcodeLinkOnly:
        {
			switch (imageSizeType) {
				case bbcodeImageFull:
					pasteboard.string = [[rehostImage.nolink_full stringByReplacingOccurrencesOfString:@"[img]" withString:@""] stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
					break;
                case bbcodeImageMedium:
                    pasteboard.string = [[rehostImage.nolink_medium stringByReplacingOccurrencesOfString:@"[img]" withString:@""] stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
                    break;
                case bbcodeImagePreview:
                    pasteboard.string = [[rehostImage.nolink_preview stringByReplacingOccurrencesOfString:@"[img]" withString:@""] stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
                    break;
				case bbcodeImageMini:
					pasteboard.string = [[rehostImage.nolink_miniature stringByReplacingOccurrencesOfString:@"[img]" withString:@""] stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
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
