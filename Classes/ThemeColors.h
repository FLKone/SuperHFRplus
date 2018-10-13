//
//  ThemeColors.h
//  HFRplus
//
//  Created by Aynolor on 17/02/17.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"


@interface ThemeColors : NSObject {
    CGFloat fDayColor1;
    CGFloat fDayColor2;
    CGFloat fDayColor3;
}

+ (void)setDayColor1:(int)b; // Brightness for light colors
+ (void)setDayColor2:(int)b; // Brightness for dark colors
+ (void)setDayColor3:(int)b; // Action color

+ (CGFloat)fDayColor1;
+ (CGFloat)fDayColor2;
+ (CGFloat)fDayColor3;


+ (UIColor *)changeBrightness:(UIColor*)color amount:(CGFloat)amount;
+ (UIColor *)changeHue:(UIColor*)color withValue:(CGFloat)val;

+ (UIColor *)tabBackgroundColor:(Theme)theme;
+ (UIColor *)navBackgroundColor:(Theme)theme;
+ (UIColor *)greyBackgroundColor:(Theme)theme;
+ (UIColor *)addMessageBackgroundColor:(Theme)theme;
+ (UIColor *)cellBackgroundColor:(Theme)theme;
+ (UIColor *)cellHighlightBackgroundColor:(Theme)theme;
+ (UITableViewCellSelectionStyle)cellSelectionStyle:(Theme)theme;
+ (UIColor *)cellIconColor:(Theme)theme;
+ (UIColor *)cellTextColor:(Theme)theme;
+ (UIColor *)cellBorderColor:(Theme)theme;
+ (UIColor *)cellTintColor:(Theme)theme;
+ (UIColor *)placeholderColor:(Theme)theme;
+ (UIColor *)headSectionBackgroundColor:(Theme)theme;
+ (UIColor *)headSectionTextColor:(Theme)theme;
+ (UIColor *)textColor:(Theme)theme;
+ (UIColor *)navItemTextColor:(Theme)theme;
+ (UIColor *)titleTextAttributesColor:(Theme)theme;
+ (UIColor *)textFieldBackgroundColor:(Theme)theme;
+ (UIColor *)lightTextColor:(Theme)theme;
+ (UIColor *)topicMsgTextColor:(Theme)theme;
+ (UIColor *)tintColor:(Theme)theme;
+ (UIColor *)tintLightColor:(Theme)theme;
+ (UIColor *)tintWhiteColor:(Theme)theme;
+ (UIColor *)overlayColor:(Theme)theme;
+ (UIColor *)toolbarColor:(Theme)theme;
+ (UIColor *)toolbarPageBackgroundColor:(Theme)theme;
+ (UIColor *)alertBackgroundColor:(Theme)theme;
+ (NSString *)creditsCss:(Theme)theme;
+ (NSString *)smileysCss:(Theme)theme;
+ (NSString *)messagesRetinaCssPath:(Theme)theme;
+ (NSString *)messagesCssPath:(Theme)theme;
+ (NSString *)isLightThemeAlternate:(Theme)theme;
+ (NSString *)isDarkThemeAlternate:(Theme)theme;
+ (NSString *)isOLEDThemeAlternate:(Theme)theme;
+ (NSString *)landscapePath:(Theme)theme;
+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIBarStyle)barStyle:(Theme)theme;
+ (UIStatusBarStyle)statusBarStyle:(Theme)theme;
+ (UIKeyboardAppearance)keyboardAppearance:(Theme)theme;
+ (UIImage *)thorHammer:(Theme)theme;
+ (UIImage *)tintImage:(UIImage *)image withTheme:(Theme)theme;
+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color;
+ (UIActivityIndicatorViewStyle)activityIndicatorViewStyle:(Theme)theme;
+ (UIScrollViewIndicatorStyle)scrollViewIndicatorStyle:(Theme)theme;
@end
