//
//  SimpleCellView.m
//  SuperHFRplus
//
//  Created by ezzz on 28/01/2019.
//

#import <Foundation/Foundation.h>
#import "SimpleCellView.h"
#import "ThemeManager.h"
#import "ThemeColors.h"


@implementation SimpleCellView

@synthesize labelText, labelBadge;


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
    [labelText setTextColor:[ThemeColors textColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
}


@end
