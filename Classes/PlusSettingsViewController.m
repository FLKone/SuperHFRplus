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
#import "MPStorage.h"
#import "MultisManager.h"

@import InAppSettingsKit;

@implementation PlusSettingsViewController

@synthesize spinner;

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
    self.spinner = [[UIActivityIndicatorView alloc]
                                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.navigationController.view addSubview:spinner];

}

-(void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"menu_debug"];
    if (!enabled) {
        [self hideCell:@"menu_debug_entry"];
    }
    
    NSInteger autoThemeEnabled = [[NSUserDefaults standardUserDefaults] integerForKey:@"auto_theme"];
    
    if (autoThemeEnabled == AUTO_THEME_AUTO_CAMERA) {
        [self hideCell:@"theme"];
        [self hideCell:@"auto_theme_day_time"];
        [self hideCell:@"auto_theme_night_time"];
    } else if (autoThemeEnabled == AUTO_THEME_AUTO_TIME) {
        [self showCell:@"theme"];
        [self showCell:@"auto_theme_day_time"];
        [self showCell:@"auto_theme_night_time"];
    } else {
        [self showCell:@"theme"];
        [self hideCell:@"auto_theme_day_time"];
        [self hideCell:@"auto_theme_night_time"];
    }
    
    // Startup status got from User defaults
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_day_adjust"]) {
        [self showCell:@"theme_day_tintcolor"];
        [self showCell:@"theme_day_color_superfavori"];
        [self showCell:@"theme_day_color_love"];
    } else {
        [self hideCell:@"theme_day_tintcolor"];
        [self hideCell:@"theme_day_color_superfavori"];
        [self hideCell:@"theme_day_color_love"];
        [self hideCell:@"theme_night_color_love"];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_night_adjust"]) {
        [self showCell:@"theme_night_brightness"];
        [self showCell:@"theme_night_tintcolor"];
        [self showCell:@"theme_night_color_superfavori"];
        [self showCell:@"theme_night_color_love"];
    } else {
        [self hideCell:@"theme_night_brightness"];
        [self hideCell:@"theme_night_tintcolor"];
        [self hideCell:@"theme_night_color_superfavori"];
        [self hideCell:@"theme_night_color_love"];
    }

    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_period"]) {
        [self showCell:@"theme_noel_disabled"];
    } else {
        [self hideCell:@"theme_noel_disabled"];
    }
    [self setThemeColors:[[ThemeManager sharedManager] theme]];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"mpstorage_active"]) {
        [self showCell:@"mpstorage_last_rw"];
        [self hideCell:@"mpstorage_reset"];
    }
    else {
        [self hideCell:@"mpstorage_last_rw"];
        [self hideCell:@"mpstorage_reset"];
    }

    
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
        [[ThemeManager sharedManager] setThemeManually:theme];
        [self setThemeColors:theme];

    } else if([notification.userInfo objectForKey:@"auto_theme"]) {        
        NSInteger iAutoTheme = [[NSUserDefaults standardUserDefaults] integerForKey:@"auto_theme"];
        // 0 = Manuel, 1 = Automatique, 2 = Heure fixe
        if (iAutoTheme == AUTO_THEME_AUTO_CAMERA) {
            [self hideCell:@"theme"];
            [self hideCell:@"auto_theme_day_time"];
            [self hideCell:@"auto_theme_night_time"];
            [[ThemeManager sharedManager] changeAutoTheme:YES];
        } else if (iAutoTheme == AUTO_THEME_AUTO_TIME) {
            [self showCell:@"theme"];
            [self showCell:@"auto_theme_day_time"];
            [self showCell:@"auto_theme_night_time"];
            [[ThemeManager sharedManager] changeAutoTheme:NO];
            [[ThemeManager sharedManager] setTheme:[[ThemeManager  sharedManager] getThemeFromCurrentTime]];
        } else {
            [self showCell:@"theme"];
            [self hideCell:@"auto_theme_day_time"];
            [self hideCell:@"auto_theme_night_time"];
            [[ThemeManager sharedManager] changeAutoTheme:NO];
        }
    } else if([notification.userInfo objectForKey:@"auto_theme_day_time"] || [notification.userInfo objectForKey:@"auto_theme_night_time"] ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"force_manual_theme"];
        [[ThemeManager sharedManager] checkTheme];
    } /*else if([notification.userInfo objectForKey:@"theme_day_adjust"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_day_adjust"]) {
            [self showCell:@"theme_day_tintcolor"];
            [self showCell:@"theme_day_color_superfavori"];
            [self showCell:@"theme_day_color_love"];
            
            [ThemeColors setDayTintColor:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"theme_day_tintcolor"]];
            [ThemeColors setDayColorSuperFavori:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"theme_day_color_superfavori"]];
            [ThemeColors setDayColorLove:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"theme_day_color_love"]];
        } else {
            [self hideCell:@"theme_day_tintcolor"];
            [self hideCell:@"theme_day_color_superfavori"];
            [self hideCell:@"theme_day_color_love"];
            // Back to default
            [ThemeColors setDayTintColor:33];
            [ThemeColors setDayColorSuperFavori:33];
            [ThemeColors setDayColorLove:33];
        }
        [[ThemeManager sharedManager] refreshTheme];
    } else if([notification.userInfo objectForKey:@"theme_night_adjust"]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_night_adjust"]) {
            [self showCell:@"theme_night_brightness"];
            [self showCell:@"theme_night_tintcolor"];
            [self showCell:@"theme_night_color_superfavori"];
            [self showCell:@"theme_night_color_love"];

            [ThemeColors setNightBrightness:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"theme_night_brightness"]];
            [ThemeColors setNightTintColor:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"theme_night_tintcolor"]];
            [ThemeColors setNightColorSuperFavori:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"theme_night_color_superfavori"]];
            [ThemeColors setNightColorLove:(int)[[NSUserDefaults standardUserDefaults] integerForKey:@"theme_night_color_love"]];
            [[ThemeManager sharedManager] refreshTheme];
        } else {
            [self hideCell:@"theme_night_brightness"];
            [self hideCell:@"theme_night_tintcolor"];
            [self hideCell:@"theme_night_color_superfavori"];
            [self hideCell:@"theme_night_color_love"];
            // Back to default
            [ThemeColors setNightBrightness:100];
            [ThemeColors setNightTintColor:33];
            [ThemeColors setNightColorSuperFavori:33];
            [ThemeColors setNightColorLove:33];
        }
        [[ThemeManager sharedManager] refreshTheme];
    }*/
    else if([notification.userInfo objectForKey:@"theme_noel_disabled"]) {
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
    } else if([notification.userInfo objectForKey:@"mpstorage_active"]) {
        // NOT WORKING [self.spinner startAnimating];
        NSLog(@"notification.userInfo objectForKey:@mpstorage_active]");
        if (![[MultisManager sharedManager] getCurrentPseudo]) {
            [HFRAlertView DisplayAlertViewWithTitle:@"MPstorage" andMessage:@"Vous devez être identifié sur le forum pour activer la fonctionnalité." forDuration:(long)2];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"mpstorage_active"];
            [self hideCell:@"mpstorage_last_rw"];
            [self hideCell:@"mpstorage_reset"];
            return;
        }

        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"mpstorage_active"]) {
            // MPStorage : Init (find topic Id at first startup), then do nothing
            
            if ([[MPStorage shared] initOrResetMP:[[MultisManager sharedManager] getCurrentPseudo] fromView:self.view]) {
                [self showCell:@"mpstorage_last_rw"];
                [self hideCell:@"mpstorage_reset"];
            }
        }
        else {
            [self hideCell:@"mpstorage_last_rw"];
            [self hideCell:@"mpstorage_reset"];
        }
    }

    //[self.spinner stopAnimating];

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
    hv.textLabel.textColor = [ThemeColors headSectionTextColor];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *hv = (UITableViewHeaderFooterView *)view;
    hv.textLabel.textColor = [ThemeColors headSectionTextColor];
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


