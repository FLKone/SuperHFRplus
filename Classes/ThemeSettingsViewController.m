//
//  ThemeSettingsViewController.m
//  SuperHFRplus
//
//  Created by ezzz on 23/07/2019.
//

#import "ThemeSettingsViewController.h"
#import "ColorPickerViewController.h"
#import "ThemeColorCellView.h"
#import "ThemeBrightnessCellView.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "HFRAlertView.h"

@implementation ThemeSettingsViewController

@synthesize tableThemeSettings, colorPickerViewController;

NSString * const DAY_COLOR_SETTINGS[] = { @"theme_day_color_action", @"theme_day_color_love" , @"theme_day_color_superfavori" };
NSString * const NIGHT_COLOR_SETTINGS[] = { @"theme_night_color_action", @"theme_night_color_love" , @"theme_night_color_superfavori" };
NSString * const DAY_COLOR_NAME[] = { @"Couleur action", @"Couleur Love list" , @"Couleur cellule super favori" };
NSString * const NIGHT_COLOR_NAME[] = { @"Couleur action", @"Couleur Love list" , @"Couleur cellule super favori" };
int const DAY_SETTINGS = 3;
int const NIGHT_SETTINGS = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"ThemeColorCellView" bundle:nil];
    [self.tableThemeSettings registerNib:nib forCellReuseIdentifier:@"ThemeColorCellId"];
    UINib *nib2 = [UINib nibWithNibName:@"ThemeBrightnessCellView" bundle:nil];
    [self.tableThemeSettings registerNib:nib2 forCellReuseIdentifier:@"ThemeBrightnessCellId"];

    self.colorPickerViewController = [[ColorPickerViewController alloc] initWithNibName:@"ColorPickerViewController" bundle:nil];
    
    self.title = @"Ajustement thème";
    self.navigationController.navigationBar.translucent = NO;
    self.tableThemeSettings.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetAllThemesQuestion)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = self.tableThemeSettings.backgroundColor = [ThemeColors greyBackgroundColor];
    self.tableThemeSettings.separatorColor = [ThemeColors cellBorderColor];
    if (self.tableThemeSettings.indexPathForSelectedRow) {
        [self.tableThemeSettings deselectRowAtIndexPath:self.tableThemeSettings.indexPathForSelectedRow animated:NO];
    }
    
    [self.tableThemeSettings reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* sTitle;
     switch (indexPath.section) {
        case 0:
             [self.colorPickerViewController setSColorSettingName:DAY_COLOR_SETTINGS[indexPath.row]];
             sTitle = [NSString stringWithFormat:@"%@", DAY_COLOR_NAME[indexPath.row]];
             self.colorPickerViewController.sColorSettingTitle = sTitle;
             [self.navigationController pushViewController:self.colorPickerViewController animated:YES];
             break;
        case 1:
             if (indexPath.row < 3) {
                 [self.colorPickerViewController setSColorSettingName:NIGHT_COLOR_SETTINGS[indexPath.row]];
                 sTitle = [NSString stringWithFormat:@"%@", NIGHT_COLOR_NAME[indexPath.row]];
                 self.colorPickerViewController.sColorSettingTitle = sTitle;
                 [self.navigationController pushViewController:self.colorPickerViewController animated:YES];
             }
             break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return DAY_SETTINGS;
            break;
        case 1:
            return NIGHT_SETTINGS + 1; // + 1 for Brightness
            break;
    };
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // NIGHT
        ThemeColorCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeColorCellId"];
        cell.labelColorName.text = DAY_COLOR_NAME[indexPath.row];
        cell.labelColorName.textColor = [ThemeColors cellTextColor];
        cell.labelColorBadge.clipsToBounds = YES;
        cell.labelColorBadge.layer.cornerRadius = 10 * 1.2 / 2;
        cell.labelColorBadge.backgroundColor = [ThemeColors getUserColor:DAY_COLOR_SETTINGS[indexPath.row]];
        cell.labelColorName.textColor = [ThemeColors cellTextColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [[ThemeManager sharedManager] applyThemeToCell:cell];
        return cell;
    }
    else { // NIGHT
        if (indexPath.row == 3) {
            ThemeBrightnessCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeBrightnessCellId"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeBrightnessCellId"];
            cell.brightnessSettingsName = @"theme_night_brightness";
            cell.sliderBrightness.minimumValue = 0.0;
            cell.sliderBrightness.maximumValue = 1.5;
            cell.sliderBrightness.value = [ThemeColors getUserBrightness:@"theme_night_brightness"];
            if ([[ThemeManager sharedManager] theme] == ThemeLight) {
                cell.imageSlider.image = [UIImage imageNamed:@"Brightness-black-512"];
            }
            else {
                cell.imageSlider.image = [UIImage imageNamed:@"Brightness-white-512"];
            }
            UIImage *image = [[UIImage imageNamed:@"reset-512"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.buttonReset setImage:image forState:UIControlStateNormal];
            cell.buttonReset.tintColor = [ThemeColors tintColor];

            
            [[ThemeManager sharedManager] applyThemeToCell:cell];
            return cell;
        }
        else {
            ThemeColorCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeColorCellId"];
            cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeColorCellId"];
            cell.labelColorName.text = DAY_COLOR_NAME[indexPath.row];
            cell.labelColorName.textColor = [ThemeColors cellTextColor];
            cell.labelColorBadge.clipsToBounds = YES;
            cell.labelColorBadge.layer.cornerRadius = 10 * 1.2 / 2;
            cell.labelColorBadge.backgroundColor = [ThemeColors getUserColor:NIGHT_COLOR_SETTINGS[indexPath.row]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [[ThemeManager sharedManager] applyThemeToCell:cell];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat curWidth = self.view.frame.size.width;
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0,0,curWidth,HEIGHT_FOR_HEADER_IN_SECTION)];
    customView.backgroundColor = [ThemeColors headSectionBackgroundColor];
    customView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, curWidth, HEIGHT_FOR_HEADER_IN_SECTION)];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    
    [button setTitleColor:[ThemeColors headSectionTextColor] forState:UIControlStateNormal];
    [button setTitle:[title uppercaseString] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(10, 10, 14, 14)];
    
    [customView addSubview:button];
    
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Thème clair";
    }
    else
    {
        return @"Thème sombre";
    }
}

- (void)resetAllThemesQuestion
{
    [HFRAlertView  DisplayOKCancelAlertViewWithTitle:@"Revenir aux couleurs par défaut ?" andMessage:nil handlerOK:^(UIAlertAction * action) {
        [self resetAllThemes];
    }];
}

- (void)resetAllThemes
{
    [ThemeColors resetUserColor:DAY_COLOR_SETTINGS[0]];
    [ThemeColors resetUserColor:DAY_COLOR_SETTINGS[1]];
    [ThemeColors resetUserColor:DAY_COLOR_SETTINGS[2]];
    [ThemeColors resetUserColor:NIGHT_COLOR_SETTINGS[0]];
    [ThemeColors resetUserColor:NIGHT_COLOR_SETTINGS[1]];
    [ThemeColors resetUserColor:NIGHT_COLOR_SETTINGS[2]];
    [ThemeColors resetUserBrightness:@"theme_night_brightness"];
    [self.tableThemeSettings reloadData];
    [[ThemeManager sharedManager] refreshTheme];
}

@end

