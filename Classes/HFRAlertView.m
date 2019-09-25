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
+ (void) DisplayAlertViewWithTitle:(NSString*)sTitle forDuration:(long)lDuration {
    [HFRAlertView DisplayAlertViewWithTitle:sTitle andMessage:nil forDuration:(long)lDuration];
}

+ (void) DisplayAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage forDuration:(long)lDuration {
    [HFRAlertView DisplayAlertViewWithTitle:sTitle andMessage:sMessage forDuration:lDuration completion:nil];
}

+ (void) DisplayAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage forDuration:(long)lDuration completion:(void (^)(void))completion {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:sTitle
                                                                   message:sMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [activeVC presentViewController:alert animated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, lDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:completion];
        });
    }];
    
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}

+ (void) DisplayOKAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage completion:(void (^)(void))completion {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:sTitle
                                                                   message:sMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    
    [alert addAction:defaultAction];
    [activeVC presentViewController:alert animated:YES completion:completion];
    
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}

+ (void) DisplayOKAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage {
    [HFRAlertView DisplayOKAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage completion:nil];
}

+ (void) DisplayOKAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage handlerOK:(void (^ __nullable)(UIAlertAction *action))handlerOK {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:sTitle
                                                                   message:sMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handlerOK];
    [alert addAction:defaultAction];
    [activeVC presentViewController:alert animated:YES completion:nil];
    
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}


+ (void) DisplayOKCancelAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage handlerOK:(void (^ __nullable)(UIAlertAction *action))handlerOK {
    
    [HFRAlertView DisplayOKCancelAlertViewWithTitle:sTitle andMessage:sMessage handlerOK:handlerOK handlerCancel:nil];
}

+ (void) DisplayOKCancelAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage handlerOK:(void (^ __nullable)(UIAlertAction *action))handlerOK handlerCancel:(void (^ __nullable)(UIAlertAction *action))handlerCancel{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:sTitle
                                                                   message:sMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handlerOK];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:handlerCancel];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [activeVC presentViewController:alert animated:YES completion:nil];
    
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}
@end
