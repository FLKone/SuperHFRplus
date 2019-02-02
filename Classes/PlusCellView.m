//
//  PlusCellView.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 28/01/2019.
//

#import <Foundation/Foundation.h>
#import "PlusCellView.h"
#import "ThemeManager.h"
#import "ThemeColors.h"


@implementation PlusCellView

@synthesize titleLabel;
@synthesize titleImage;


-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect adjustedFrame = self.accessoryView.frame;
    adjustedFrame.origin.x += 10.0f;
    self.accessoryView.frame = adjustedFrame;
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor =[ThemeColors cellBackgroundColor:theme];
    [titleLabel setTextColor:[ThemeColors textColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
}


@end
