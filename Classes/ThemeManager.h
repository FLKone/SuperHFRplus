//
//  ThemeManager.h
//  HFRplus
//
//  Created by Aynolor on 17/02/17.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "LuminosityHandler.h"

#define AUTO_THEME_MANUAL 0
#define AUTO_THEME_AUTO_CAMERA 1
#define AUTO_THEME_AUTO_TIME 2
#define AUTO_THEME_AUTO_IOS 3


@interface ThemeManager : NSObject <LuminosityHandlerDelegate>  {
}

@property Theme theme;
@property LuminosityHandler *luminosityHandler;
    
+ (ThemeManager*)sharedManager;
+ (Theme)currentTheme;
- (void)applyThemeToCell:(UITableViewCell *)cell;
- (void)applyThemeToTextField:(UITextField *)textfield;
- (void)applyThemeToAlertController:(UIAlertController *)alert;
- (void)switchTheme;
- (void)changeAutoTheme:(BOOL)autoTheme;
- (void)refreshTheme;
- (void)checkTheme;
- (void)setThemeManually:(Theme)newTheme;
- (Theme)getThemeFromCurrentTime;
@end
