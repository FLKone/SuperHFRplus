//
//  HFRAlertView.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 06/03/2019.
//

#ifndef HFRAlertView_h
#define HFRAlertView_h

@interface HFRAlertView : NSObject {
}

+ (void) DisplayAlertViewWithTitle:(NSString*)sTitle forDuration:(long)lDuration;
+ (void) DisplayAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage forDuration:(long)lDuration;
+ (void) DisplayAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage forDuration:(long)lDuration completion:(void (^)(void))completion;
+ (void) DisplayOKAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage;
+ (void) DisplayOKAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage completion:(void (^)(void))completion;
+ (void) DisplayOKCancelAlertViewWithTitle:(NSString*)sTitle andMessage:(NSString*)sMessage handlerOK:(void (^ __nullable)(UIAlertAction *action))handlerOK;

@end

#endif /* HFRAlertView_h */
