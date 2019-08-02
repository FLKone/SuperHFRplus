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
    [self.labelTitle setTextColor:[ThemeColors textColor:theme]];
    [self.labelMessageNumber setTextColor:[ThemeColors topicMsgTextColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
    if (self.isSuperFavorite) {
        self.backgroundColor = [ThemeColors cellBackgroundColorSuperFavorite];
        self.contentView.superview.backgroundColor = [ThemeColors cellBackgroundColorSuperFavorite];
        [self.labelDate setTextColor:[ThemeColors tintColorSuperFavorite]];
        [self.labelBadge setTextColor:[ThemeColors cellBackgroundColorSuperFavorite]];
        self.labelBadge.backgroundColor = [ThemeColors tintColorSuperFavorite];
        
        // Add some shadow
        self.labelTitle.layer.shadowColor = [self.labelTitle.textColor CGColor];
        self.labelTitle.layer.shadowOffset = CGSizeMake(1.0, 1.0);
        self.labelTitle.layer.shadowRadius = 0.3;
        self.labelTitle.layer.shadowOpacity = 0.3;
        self.labelTitle.layer.masksToBounds = NO;
        self.labelTitle.layer.shouldRasterize = YES;
    } else {
        self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
        self.contentView.superview.backgroundColor = [ThemeColors cellBackgroundColor:theme];
        [self.labelDate setTextColor:[ThemeColors cellTintColor:theme]];
        [self.labelBadge setTextColor:[ThemeColors cellBackgroundColor:theme]];
        self.labelBadge.backgroundColor = [ThemeColors tintColor];
        // Remove shadow
        self.labelTitle.layer.shadowOpacity = 0.0;
    }
}


@end
