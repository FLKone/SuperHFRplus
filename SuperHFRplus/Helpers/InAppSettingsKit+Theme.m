//
//  InAppSettingsKit+Theme.m
//  SuperHFRplus
//
//  Created by FLK on 10/11/2017.
//

#import "InAppSettingsKit+Theme.h"


@implementation IASKSpecifierValuesViewController (Theme)

-(void)setThemeColors:(Theme)theme {
    self.tableView.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.tableView.separatorColor = [ThemeColors cellBorderColor:theme];
    [_tableView reloadData];
}

@end

