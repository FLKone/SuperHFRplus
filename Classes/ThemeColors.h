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
}

// User color handling methods
+ (void)updateUserColor:(NSString*)sSetting withColor:(UIColor*)c;
+ (UIColor*)getUserColor:(NSString*)sSetting;
+ (UIColor*)resetUserColor:(NSString*)sSetting;
+ (void)updateUserBrightness:(NSString*)sSetting withBrightness:(CGFloat)c;
+ (CGFloat)getUserBrightness:(NSString*)sSetting;
+ (CGFloat)resetUserBrightness:(NSString*)sSetting;

// Colors definition
+ (UIColor *)tabBackgroundColor:(Theme)theme;
+ (UIColor *)navBackgroundColor;
+ (UIColor *)navBackgroundColor:(Theme)theme;
+ (UIColor *)greyBackgroundColor;
+ (UIColor *)greyBackgroundColor:(Theme)theme;
+ (UIColor *)messageBackgroundColor:(Theme)theme;
+ (UIColor *)messageModoBackgroundColor:(Theme)theme;
+ (UIColor *)messageMeBackgroundColor:(Theme)theme;
+ (UIColor *)messageHeaderMeBackgroundColor:(Theme)theme;
+ (UIColor *)messageHeaderLoveBackgroundColor:(Theme)theme;
+ (UIColor *)messageMeQuotedBackgroundColor:(Theme)theme;
+ (UIColor *)addMessageBackgroundColor:(Theme)theme;
+ (UIColor *)cellBackgroundColor:(Theme)theme;
+ (UIColor *)defaultSuperFavorite:(Theme)theme;
+ (UIColor *)tintColorSuperFavorite;
+ (UIColor *)cellBackgroundColorSuperFavorite;
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
+ (UIColor *)defaultTintColor:(Theme)theme;
+ (UIColor *)tintColor;
+ (UIColor *)tintColorWithAlpha:(CGFloat)newAlpha;
+ (UIColor *)tintLightColor;
+ (UIColor *)tintWhiteColor:(Theme)theme;
+ (UIColor *)tintColorDisabled:(Theme)theme;
+ (UIColor *)loveColor;
+ (UIColor *)loveColor:(Theme)theme;
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
//+ (NSString *)isOLEDThemeAlternate:(Theme)theme;
+ (NSString *)landscapePath:(Theme)theme;
+ (UIImage *)imageFromColor:(UIColor *)color;
+ (UIBarStyle)barStyle:(Theme)theme;
+ (UIStatusBarStyle)statusBarStyle:(Theme)theme;
+ (UIKeyboardAppearance)keyboardAppearance:(Theme)theme;
+ (UIKeyboardAppearance)keyboardAppearance;
+ (UIImage *)thorHammer:(Theme)theme;
+ (UIImage *)heart:(Theme)theme;
+ (UIImage *)avatar:(Theme)theme;
+ (UIImage *)tintImage:(UIImage *)image withTheme:(Theme)theme;
+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color;
+ (UIActivityIndicatorViewStyle)activityIndicatorViewStyle;
+ (UIScrollViewIndicatorStyle)scrollViewIndicatorStyle:(Theme)theme;
+ (NSString *) hexFromUIColor:(UIColor *)color;
+ (NSString *) rgbaFromUIColor:(UIColor *)color;
+ (NSString *) rgbaFromUIColor:(UIColor *)color withAlpha:(CGFloat)newAlpha;
+ (NSString *) rgbaFromUIColor:(UIColor *)color withAlpha:(CGFloat)newAlpha addSaturation:(CGFloat)s;
+ (NSString *) rgbaFromUIColor:(UIColor *)color withAlpha:(CGFloat)newAlpha addSaturation:(CGFloat)s addBrightness:(CGFloat)b;
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
