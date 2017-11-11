//
//  SettingsViewController.m
//  HFRplus
//
//  Created by FLK on 05/07/12.
//

#import "SettingsViewController.h"
#import "HFRplusAppDelegate.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
@import InAppSettingsKit;

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //...
        self.delegate = self;

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
    
     IASKAppSettingsViewController *settingsVC = ((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]);
    settingsVC.neverShowPrivacySettings = YES;
    NSLog(@"awakeFromNib");
    
    self.delegate = self;
}

-(void)viewDidLoad {
    //NSLog(@"viewDidLoadviewDidLoadviewDidLoadviewDidLoad");
    [super viewDidLoad];
    self.showCreditsFooter = NO;
    [self.tableView setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    
    NSMutableSet *hiddenKeys = [NSMutableSet set];
    
    // Désactivation de la configuration du thème pour iOS 5-6
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [hiddenKeys addObject:@"theme"];
    }
    
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"menu_debug"];
    IASKAppSettingsViewController *settingsVC = ((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]);
    
    if (!enabled) {
        [hiddenKeys addObject:@"menu_debug_entry"];
    }
    
    NSLog(@"hiddenKeys %@", hiddenKeys);
    
    settingsVC.hiddenKeys = hiddenKeys;//enabled ? nil : [NSSet setWithObjects:@"menu_debug_entry", nil];
    [self setThemeColors:[[ThemeManager sharedManager] theme]];
}



#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
    NSLog(@"settingDidChange %@", notification);

    if ([notification.userInfo objectForKey:@"menu_debug"]) {
        //IASKAppSettingsViewController *activeController = self;
        NSMutableSet *hiddenKeys = [NSMutableSet set];

        // Désactivation de la configuration du thème pour iOS 5-6
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            [hiddenKeys addObject:@"theme"];
        }
        
        BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"menu_debug"];

        IASKAppSettingsViewController *settingsVC = ((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]);
    
        //((IASKAppSettingsViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]).hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"menu_debug_entry", nil];
        
        if (!enabled) {
            [hiddenKeys addObject:@"menu_debug_entry"];
        }
        
        NSLog(@"hiddenKeys %@", hiddenKeys);
        
        settingsVC.hiddenKeys = hiddenKeys;//enabled ? nil : [NSSet setWithObjects:@"menu_debug_entry", nil];
        
        //[activeController setHiddenKeys:enabled ? nil : [NSSet setWithObjects:@"AutoConnectTest", nil] animated:YES];
        
    } else if([notification.userInfo objectForKey:@"theme"]) {

        Theme theme = (Theme)[[notification.userInfo objectForKey:@"theme"] intValue];
        [[ThemeManager sharedManager] setTheme:theme];
        [self setThemeColors:theme];

    } else if([notification.userInfo objectForKey:@"icon"]) {
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
        }
    }
    /*
    if UIApplication.shared.alternateIconName == nil {
        UIApplication.shared.setAlternateIconName("Icon-RED")
    } else if UIApplication.shared.alternateIconName == "Icon-RED" {
        UIApplication.shared.setAlternateIconName("Icon-Original")
    } else if UIApplication.shared.alternateIconName == "Icon-Original" {
        UIApplication.shared.setAlternateIconName(nil)
    }
     */
    [self.tableView reloadData];
}

-(void)setThemeColors:(Theme)theme{
    [self.navigationController.navigationBar setBackgroundImage:[ThemeColors imageFromColor:[ThemeColors navBackgroundColor:theme]] forBarMetrics:UIBarMetricsDefault];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setTintColor:)]) {
        [self.navigationController.navigationBar setTintColor:[ThemeColors tintColor:theme]];
    }

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [ThemeColors textColor:theme]}];
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
    //NSLog(@"settingsViewController");
    
    
    
	if ([key isEqualToString:@"EmptyCacheButton"]) {

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Vider le cache ?" message:@"Tous les onglets (Catégories, Favoris etc.) seront reinitialisés.\nAttention donc si vous êtes en train de lire un sujet intéressant :o" delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Oui !", nil];
		[alert show];
	}
    else if ([key isEqualToString:@"SetCheckpoint"]) {

        //[TestFlight passCheckpoint:@"DEBUG"];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    [[HFRplusAppDelegate sharedAppDelegate] resetApp];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *ImageCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"ImageCache"];
    NSString *SmileCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SmileCache"];
    
	if ([fileManager fileExistsAtPath:ImageCachePath])
	{
		[fileManager removeItemAtPath:ImageCachePath error:NULL];
	}
    
	if ([fileManager fileExistsAtPath:SmileCachePath])
	{
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


