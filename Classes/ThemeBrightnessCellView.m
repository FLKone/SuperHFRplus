//
//  ThemeBrightnessCellView.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 04/04/2019.
//

#import <Foundation/Foundation.h>
#import "ThemeBrightnessCellView.h"
#import "ThemeManager.h"
#import "ThemeColors.h"


@implementation ThemeBrightnessCellView

@synthesize brightnessSettingsName;

-(void)layoutSubviews {
    [super layoutSubviews];
    [self applyTheme];
}

-(void)applyTheme {
/*
    Theme theme = [[ThemeManager sharedManager] theme];
    [self.labelColorName setTextColor:[ThemeColors textColor:theme]];
    //self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    [self.labelBadge setTextColor:[ThemeColors cellBackgroundColor:theme]];
    self.labelBadge.backgroundColor = [ThemeColors tintColor];*/
}


- (IBAction)changeBrightness:(UISlider *)sender {
    [ThemeColors updateUserBrightness:brightnessSettingsName withBrightness:sender.value];
    [[ThemeManager sharedManager] refreshTheme];
}
- (IBAction)resetBrightness:(id)sender {
    [ThemeColors resetUserBrightness:brightnessSettingsName];
    [[ThemeManager sharedManager] refreshTheme];
}
@end
