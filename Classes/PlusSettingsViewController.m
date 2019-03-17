//
//  SettingsViewController.m
//  HFRplus
//
//  Created by FLK on 05/07/12.
//

#import "PlusSettingsViewController.h"
#import "HFRplusAppDelegate.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "HFRAlertView.h"

@import InAppSettingsKit;

@implementation PlusSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //...
        self.delegate = self;

    }
    return self;
}

/* UNUSED ? TODELETE?
- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
    
     IASKAppSettingsViewController *settingsVC = ((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]);
    settingsVC.neverShowPrivacySettings = YES;
    NSLog(@"awakeFromNib");
    
    self.delegate = self;
}
*/

-(void)viewDidLoad {
    //NSLog(@"viewDidLoadviewDidLoadviewDidLoadviewDidLoad");
    [super viewDidLoad];
    self.showCreditsFooter = NO;
    self.neverShowPrivacySettings = YES;
    [self.tableView setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
}

-(void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"menu_debug"];
    if (!enabled) {
        [self hideCell:@"menu_debug_entry"];
    }
    
    BOOL autoThemeEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_theme"];
    
    if(autoThemeEnabled){
        [self hideCell:@"theme"];
        [self showCell:@"auto_theme_day"];
        [self showCell:@"auto_theme_night"];
    }else{
        [self showCell:@"theme"];
        [self hideCell:@"auto_theme_day"];
        [self hideCell:@"auto_theme_night"];
    }
    
    // Startup status got from User defaults
    BOOL adjustThemeDarkEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"theme_dark_adjust"];
    if (adjustThemeDarkEnabled) {
        [self showCell:@"theme_dark_color1"];
        [self showCell:@"theme_dark_color2"];
    } else {
        [self hideCell:@"theme_dark_color1"];
        [self hideCell:@"theme_dark_color2"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_period"]) {
        [self showCell:@"theme_noel_disabled"];
    } else {
        [self hideCell:@"theme_noel_disabled"];
    }
    [self setThemeColors:[[ThemeManager sharedManager] theme]];

    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
    NSLog(@"settingDidChange %@", notification);

    if ([notification.userInfo objectForKey:@"menu_debug"]) {
        BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"menu_debug"];
        
        if (!enabled) {
            [self hideCell:@"menu_debug_entry"];
        }else{
           [self showCell:@"menu_debug_entry"];
        }
    } else if([notification.userInfo objectForKey:@"theme"]) {
        Theme theme = (Theme)[[notification.userInfo objectForKey:@"theme"] intValue];
        [[ThemeManager sharedManager] setTheme:theme];
        [self setThemeColors:theme];

    } else if([notification.userInfo objectForKey:@"auto_theme"]) {
        
        [[ThemeManager sharedManager] changeAutoTheme:[[NSUserDefaults standardUserDefaults] boolForKey:@"auto_theme"]];
        BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_theme"];
        
        if(enabled){
            [self hideCell:@"theme"];
            [self showCell:@"auto_theme_day"];
            [self showCell:@"auto_theme_night"];
        }else{
            [self showCell:@"theme"];
            [self hideCell:@"auto_theme_day"];
            [self hideCell:@"auto_theme_night"];
        }
    } else if([notification.userInfo objectForKey:@"theme_dark_adjust"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_dark_adjust"]) {
            [self showCell:@"theme_dark_color1"];
            [self showCell:@"theme_dark_color2"];
            //  Apply customisation
            NSInteger value1 = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme_dark_color1"];
            NSInteger value2 = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme_dark_color2"];
            [ThemeColors setDarkColor1:value1];
            [ThemeColors setDarkColor2:value2];
            [[ThemeManager sharedManager] refreshTheme];
        } else {
            [self hideCell:@"theme_dark_color1"];
            [self hideCell:@"theme_dark_color2"];
            // Back to default
            [ThemeColors setDarkColor1:100];
            [ThemeColors setDarkColor2:33];
            [[ThemeManager sharedManager] refreshTheme];
        }
    }
    else if([notification.userInfo objectForKey:@"theme_noel_disabled"]) {
        [[ThemeManager sharedManager] refreshTheme];
    }
    else if([notification.userInfo objectForKey:@"theme_dark_color1"])
    {
        NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme_dark_color1"];
        [ThemeColors setDarkColor1:value];
        [[ThemeManager sharedManager] refreshTheme];
    }
    else if([notification.userInfo objectForKey:@"theme_dark_color2"])
    {
        NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme_dark_color2"];
        [ThemeColors setDarkColor2:value];
        [[ThemeManager sharedManager] refreshTheme];
    }
    else if([notification.userInfo objectForKey:@"icon"]) {
        NSString *newIcon = [notification.userInfo objectForKey:@"icon"];

        if ([[UIApplication sharedApplication] supportsAlternateIcons] == NO)
            return;

        NSLog(@"icon %@", newIcon);
        if ([newIcon isEqualToString:@"super"]) {
            [[UIApplication sharedApplication] setAlternateIconName:nil completionHandler:nil];
        } else if ([newIcon isEqualToString:@"classic"]) {
            [[UIApplication sharedApplication] setAlternateIconName:@"Icon-CLASSIC"
                                                  completionHandler:^(NSError * _Nullable error) {
                                                      NSLog(@"%@", [error description]);
                                                  }];
        } else if ([newIcon isEqualToString:@"beta"]) {
            [[UIApplication sharedApplication] setAlternateIconName:@"Icon-BETA"
                                                  completionHandler:^(NSError * _Nullable error) {
                                                      NSLog(@"%@", [error description]);
                                                  }];
        } else if ([newIcon isEqualToString:@"redface"]) {
            [[UIApplication sharedApplication] setAlternateIconName:@"Icon-REDFACE"
                                                  completionHandler:^(NSError * _Nullable error) {
                                                      NSLog(@"%@", [error description]);
                                                  }];
        } else if ([newIcon isEqualToString:@"blue"]) {
            [[UIApplication sharedApplication] setAlternateIconName:@"Icon-BLUE"
                                                  completionHandler:^(NSError * _Nullable error) {
                                                      NSLog(@"%@", [error description]);
                                                  }];
        } else if ([newIcon isEqualToString:@"white"]) {
            [[UIApplication sharedApplication] setAlternateIconName:@"Icon-WHITE"
                                                  completionHandler:^(NSError * _Nullable error) {
                                                      NSLog(@"%@", [error description]);
                                                  }];
        }
    }  else if([notification.userInfo objectForKey:@"size_smileys"]) {
        NSNotification *myNotification = [NSNotification notificationWithName:kSmileysSizeChangedNotification
                                                                       object:self  //object is usually the object posting the notification
                                                                     userInfo:nil]; //userInfo is an optional dictionary
        
        //Post it to the default notification center
        [[NSNotificationCenter defaultCenter] postNotification:myNotification];
    }

    [self.tableView reloadData];
}

-(void)hideCell:(NSString *)cell{
    NSMutableSet *hiddenKeys = self.hiddenKeys ? [NSMutableSet setWithSet:self.hiddenKeys] : [NSMutableSet set];
    if([hiddenKeys containsObject:cell]){
        return;
    }
    
    [hiddenKeys addObject:cell];
    self.hiddenKeys = hiddenKeys;
}

-(void)showCell:(NSString *)cell{
    NSMutableSet *hiddenKeys = self.hiddenKeys ? [NSMutableSet setWithSet:self.hiddenKeys] : [NSMutableSet set];
    if([hiddenKeys containsObject:cell]){
        [hiddenKeys removeObject:cell];
    }
    self.hiddenKeys = hiddenKeys;
}


-(void)setThemeColors:(Theme)theme {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
        [self.navigationController.navigationBar setBackgroundImage:[ThemeColors imageFromColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    } else {
        UIImage *navBG =[[UIImage animatedImageNamed:@"snow" duration:1.f]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeTile];
        
        [self.navigationController.navigationBar setBackgroundImage:navBG forBarMetrics:UIBarMetricsDefault];
    }
    
     [self.navigationController.navigationBar setBarTintColor:[ThemeColors navBackgroundColor:theme]];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setTintColor:)]) {
        [self.navigationController.navigationBar setTintColor:[ThemeColors tintColor:theme]];
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [ThemeColors titleTextAttributesColor:theme]}];
    [self.navigationController.navigationBar setNeedsDisplay];
    
    self.view.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.tableView.separatorColor = [ThemeColors cellBorderColor:theme];

    [self.tableView reloadData];
}


-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *hv = (UITableViewHeaderFooterView *)view;
    hv.textLabel.textColor = [ThemeColors headSectionTextColor:[[ThemeManager sharedManager] theme]];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *hv = (UITableViewHeaderFooterView *)view;
    hv.textLabel.textColor = [ThemeColors headSectionTextColor:[[ThemeManager sharedManager] theme]];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [[ThemeManager sharedManager] applyThemeToCell:cell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key {
    if ([key isEqualToString:@"EmptyCacheButton"]) {
        [HFRAlertView DisplayOKCancelAlertViewWithTitle:@"Vider le cache ?"
                                             andMessage:@"Tous les onglets (Catégories, Favoris etc.) seront reinitialisés.\nAttention donc si vous êtes en train de lire un sujet intéressant :o"
                                              handlerOK:^(UIAlertAction * action) { [self emptyCache];}];
	}
}

- (void)emptyCache {
    [[HFRplusAppDelegate sharedAppDelegate] resetApp];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *ImageCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    NSString *SmileCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SmileCache"];
    
    if ([fileManager fileExistsAtPath:ImageCachePath]) {
        [fileManager removeItemAtPath:ImageCachePath error:NULL];
    }
    
    if ([fileManager fileExistsAtPath:SmileCachePath]) {
        [fileManager removeItemAtPath:SmileCachePath error:NULL];
    }
}

#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    //NSLog(@"settingsViewControllerDidEnd");
	
	// your code here to reconfigure the app for changed settings
}

@end


