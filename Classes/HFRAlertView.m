//
//  HFRAlertView.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 06/03/2019.
//

#import "HFRAlertView.h"
#import "ThemeManager.h"

@implementation HFRAlertView

//+ (void) DisplayAlertView:(UIViewController*)activeVC withTitle:(NSString*)sTitle andMessage:(NSString*)sMessage forDuration:(long)lDuration {
+ (void) DisplayAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage forDuration:(long)lDuration {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:sTitle
                                                                   message:sMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [activeVC presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, lDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }];

    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}

@end
