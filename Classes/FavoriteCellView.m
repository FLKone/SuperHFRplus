//
//  FavoriteCellView.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 04/04/2019.
//

#import <Foundation/Foundation.h>
#import "FavoriteCellView.h"
#import "ThemeManager.h"
#import "ThemeColors.h"


@implementation FavoriteCellView


-(void)layoutSubviews {
    [super layoutSubviews];
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    // Background color of topic cells in favorite list
    self.contentView.superview.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    [self.labelTitle setTextColor:[ThemeColors textColor:theme]];
    [self.labelMessageNumber setTextColor:[ThemeColors topicMsgTextColor:theme]];
    [self.labelDate setTextColor:[ThemeColors cellTintColor:theme]];
    [self.labelBadge setTextColor:[ThemeColors cellBackgroundColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
}


@end
