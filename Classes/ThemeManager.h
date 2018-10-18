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

@interface ThemeManager : NSObject <LuminosityHandlerDelegate>  {
    Theme theme;
}

@property Theme theme;
@property BOOL autoTheme;
@property LuminosityHandler *luminosityHandler;
    
+ (id)sharedManager;
- (void)applyThemeToCell:(UITableViewCell *)cell;
- (void)applyThemeToTextField:(UITextField *)textfield;
- (void)applyThemeToAlertController:(UIAlertController *)alert;
- (void)switchTheme;
- (void)changeAutoTheme:(BOOL)autoTheme;
- (void)refreshTheme;

@end
