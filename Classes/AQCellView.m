//
//  AQCellView.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 02/02/2019.
//

#import <Foundation/Foundation.h>
#import "AQCellView.h"
#import "ThemeManager.h"
#import "ThemeColors.h"


@implementation AQCellView

@synthesize titleLabel;
@synthesize titleTime;

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
