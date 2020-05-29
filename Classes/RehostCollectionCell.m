//
//  RehostCell.m
//  HFRplus
//
//  Created by ezzz on 05/2020
//
//

#import "RehostCollectionCell.h"
#import "RehostImage.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "ThemeManager.h"
#import "ThemeColors.h"

@implementation RehostCollectionCell
@synthesize previewImage, fullBtn, spinner, rehostImage;

#define IMAGEVIEW_BORDER_LENGTH 0
#define CELL_INDEX_0 0

/*
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup {
}*/

-(void)layoutSubviews
{
    [super layoutSubviews];

    [self.fullBtn setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.7]];
    self.fullBtn.layer.cornerRadius = 5; // this value vary as per your desire
    self.fullBtn.layer.borderWidth = 1; // this value vary as per your desire
    self.fullBtn.clipsToBounds = YES;
    
    [self applyTheme];
}

-(void)applyTheme {
    /*
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor =[ThemeColors cellBackgroundColor:theme];
    self.fullBtn.layer.borderColor = [ThemeColors tintColor].CGColor;
     */
}

-(void)configureWithIcon:(UIImage *)image border:(int)border {
    __weak RehostCollectionCell *self_ = self;
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;

    self.previewImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    //[self addSubview:self.previewImage];
    [self_.previewImage setImage:image];
    //[self_.previewImage setHidden:NO];
    self_.previewImage.clipsToBounds = NO;
    //[self addSubview:self.previewImage];
    
    /*
    self.fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullBtn setTitle:@"" forState:UIControlStateNormal];
    self.fullBtn.frame = self.bounds;
    //[newPhotoBtn addTarget:self action:@selector(uploadNewPhoto:) forControlEvents:UIControlEventTouchUpInside];
    self.fullBtn.layer.cornerRadius = 15;
    self.fullBtn.layer.borderWidth = 1;
    self.fullBtn.layer.borderColor = [ThemeColors tintColor].CGColor;
    self.fullBtn.clipsToBounds = YES;
    [self.fullBtn setImage:image forState:UIControlStateNormal];

    [self addSubview:self.fullBtn];*/
    [self_.spinner stopAnimating];
}

-(void)configureWithRehostImage:(RehostImage *)image;
{
    self.previewImage = [[UIImageView alloc] initWithFrame:(CGRectInset(self.bounds, IMAGEVIEW_BORDER_LENGTH, IMAGEVIEW_BORDER_LENGTH))];
    [self addSubview:self.previewImage];
    self.rehostImage = image;
    
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

    __weak RehostCollectionCell *self_ = self;

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
        }
        self.fullBtn.frame = self.bounds;

        [self_.spinner stopAnimating];
    }];
    
}

-(IBAction)copyFull {
    [self.rehostImage copyToPasteBoard:bbcodeImageFull];
}


@end
