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
    CGFloat fDarkColor1;
    CGFloat fDarkColor2;
}

+ (void)setDarkColor1:(int)b; // Brightness for dark colors in % compare to default Dark theme
+ (void)setDarkColor2:(int)b; // Action color for dark theme (converted to hue value)

+ (CGFloat)fDarkColor1;
+ (CGFloat)fDarkColor2;

+ (UIColor *)tabBackgroundColor:(Theme)theme;
+ (UIColor *)navBackgroundColor;
+ (UIColor *)navBackgroundColor:(Theme)theme;
+ (UIColor *)greyBackgroundColor;
+ (UIColor *)greyBackgroundColor:(Theme)theme;
+ (UIColor *)messageBackgroundColor:(Theme)theme;
+ (UIColor *)messageModoBackgroundColor:(Theme)theme;
+ (UIColor *)messageMeBackgroundColor:(Theme)theme;
+ (UIColor *)messageHeaderMeBackgroundColor:(Theme)theme;
+ (UIColor *)messageMeQuotedBackgroundColor:(Theme)theme;
+ (UIColor *)addMessageBackgroundColor:(Theme)theme;
+ (UIColor *)cellBackgroundColor:(Theme)theme;
+ (UIColor *)cellBackgroundColorSuperFavorite:(Theme)theme;
+ (UIColor *)cellHighlightBackgroundColor:(Theme)theme;
+ (UITableViewCellSelectionStyle)cellSelectionStyle:(Theme)theme;
+ (UIColor *)cellIconColor:(Theme)theme;
+ (UIColor *)cellTextColor:(Theme)theme;
+ (UIColor *)cellTextColor;
+ (UIColor *)cellDisabledTextColor:(Theme)theme;
+ (UIColor *)cellBorderColor;
+ (UIColor *)cellBorderColor:(Theme)theme;
+ (UIColor *)cellTintColor:(Theme)theme;
+ (UIColor *)placeholderColor:(Theme)theme;
+ (UIColor *)headSectionBackgroundColor;
+ (UIColor *)headSectionTextColor;
+ (UIColor *)textColor:(Theme)theme;
+ (UIColor *)textColor;
+ (UIColor *)textColor2:(Theme)theme;
+ (UIColor *)textColorPseudo:(Theme)theme;
+ (UIColor *)navItemTextColor:(Theme)theme;
+ (UIColor *)titleTextAttributesColor;
+ (UIColor *)titleTextAttributesColor:(Theme)theme;
+ (UIColor *)textFieldBackgroundColor:(Theme)theme;
+ (UIColor *)headerBLBackgroundColor;
+ (UIColor *)lightTextColor:(Theme)theme;
+ (UIColor *)topicMsgTextColor:(Theme)theme;
+ (UIColor *)topicMsgTextColor;
+ (UIColor *)tintColor:(Theme)theme;
+ (UIColor *)tintColor;
+ (UIColor *)tintLightColor;
+ (UIColor *)tintWhiteColor:(Theme)theme;
+ (UIColor *)tintColorDisabled:(Theme)theme;
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
+ (UIKeyboardAppearance)keyboardAppearance;
+ (UIImage *)thorHammer:(Theme)theme;
+ (UIImage *)avatar:(Theme)theme;
+ (UIImage *)tintImage:(UIImage *)image withTheme:(Theme)theme;
+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color;
+ (UIActivityIndicatorViewStyle)activityIndicatorViewStyle;
+ (UIScrollViewIndicatorStyle)scrollViewIndicatorStyle:(Theme)theme;
+ (NSString *) hexFromUIColor:(UIColor *)color;
+ (NSString *) rgbaFromUIColor:(UIColor *)color;
+ (NSString *) rgbaFromUIColor:(UIColor *)color withAlpha:(CGFloat) newAlpha;
+ (NSString *) getColorBorderQuotation:(Theme)theme;
+ (UIColor *)  getColorBorderAvatar:(Theme)theme;
+ (UIColor *)adjustDarkThemeBrightnessOfColor:(UIColor*)color;
+ (UIColor *)adjustDarkThemeBrightnessOfColor:(UIColor*)color withMin:(CGFloat)min;
+ (UIColor *)changeHue:(UIColor*)color withValue:(CGFloat)val;
+ (NSString*) tabBarItemSelectedImageAtIndex:(int)index;
+ (NSString*) tabBarItemUnselectedImageAtIndex:(int)index;
+ (UIImageRenderingMode) tabBarItemSelectedImageRendering;
+ (UIImageRenderingMode) tabBarItemUnselectedImageRendering;

@end
