//
//  OfflineCellView.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 11/10/2019.
//
/*

#import <Foundation/Foundation.h>
#import "OfflineCellView.h"
#import "ThemeManager.h"
#import "ThemeColors.h"


@implementation OfflineCellView


-(void)layoutSubviews {
    [super layoutSubviews];
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    [self.labelTitle setTextColor:[ThemeColors textColor:theme]];
    [self.labelMessageNumber setTextColor:[ThemeColors topicMsgTextColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
    if (self.isSuperFavorite) {
        self.backgroundColor = [ThemeColors cellBackgroundColorSuperFavorite];
        self.contentView.superview.backgroundColor = [ThemeColors cellBackgroundColorSuperFavorite];
        [self.labelDate setTextColor:[ThemeColors tintColorSuperFavorite]];
        [self.labelBadge setTextColor:[ThemeColors cellBackgroundColorSuperFavorite]];
        self.labelBadge.backgroundColor = [ThemeColors tintColorSuperFavorite];
    } else {
        self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
        self.contentView.superview.backgroundColor = [ThemeColors cellBackgroundColor:theme];
        [self.labelDate setTextColor:[ThemeColors cellTintColor:theme]];
        [self.labelBadge setTextColor:[ThemeColors cellBackgroundColor:theme]];
        self.labelBadge.backgroundColor = [ThemeColors tintColor];
    }
}


@end
*/
