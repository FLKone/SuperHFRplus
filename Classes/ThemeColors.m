//
//  ThemeColors.m
//  HFRplus
//
//  Created by Aynolor on 17/02/17.
//
//

#import "ThemeColors.h"
#import "Constants.h"
#import "ThemeManager.h"
#import "TabBarController.h"

#define DEFAULT_VOID_COLOR [UIColor redColor]

@implementation ThemeColors

#pragma mark User defaults

// User colors
+ (UIColor*)getUserColor:(NSString*)sSetting {
    // Read a color from settings
    NSString *theColorStr = [[NSUserDefaults standardUserDefaults] objectForKey:sSetting];
    if ([theColorStr length] > 0) {
        return [self colorWithString:theColorStr];
    }
    
    // When not present take value from default values
    return [self resetUserColor:sSetting];
}

+ (UIColor*)resetUserColor:(NSString*)sSetting {
    UIColor* c = [self getDefaultUserColor:sSetting];
    [self updateUserColor:sSetting withColor:c];
    return c;
}

+ (void)updateUserColor:(NSString*)sSetting withColor:(UIColor*)c{
    // Save a color
    NSString *theColorStr = [self stringFromColor:c];
    [[NSUserDefaults standardUserDefaults] setObject:theColorStr forKey:sSetting];
}

+ (UIColor*)getDefaultUserColor:(NSString*)sSetting {
    UIColor* c;
    if  ([sSetting isEqualToString:@"theme_day_color_action"]) {
        c = [ThemeColors defaultTintColor:ThemeLight];
    }
    else if ([sSetting isEqualToString:@"theme_night_color_action"]) {
        c = [ThemeColors defaultTintColor:ThemeDark];
    }
    else if ([sSetting isEqualToString:@"theme_day_color_love"]) {
        c = [ThemeColors defaultLoveColor:ThemeLight];
    }
    else if ([sSetting isEqualToString:@"theme_night_color_love"]) {
        c = [ThemeColors defaultLoveColor:ThemeDark];
    }
    else if ([sSetting isEqualToString:@"theme_day_color_superfavori"]) {
        c = [ThemeColors defaultSuperFavorite:ThemeLight];
    }
    else if ([sSetting isEqualToString:@"theme_night_color_superfavori"]) {
        c = [ThemeColors defaultSuperFavorite:ThemeDark];
    }
    return c;
}

+ (CGFloat)getUserBrightness:(NSString*)sSetting {
    // Read a color from settings
    if ([[NSUserDefaults standardUserDefaults] objectForKey:sSetting]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:sSetting];
    }
    
    // When not present take default value
    return [self resetUserBrightness:sSetting];
}

+ (void)updateUserBrightness:(NSString*)sSetting withBrightness:(CGFloat)b {
    [[NSUserDefaults standardUserDefaults] setFloat:b forKey:sSetting];
}

+ (CGFloat)resetUserBrightness:(NSString*)sSetting {
    CGFloat b = 0;
    if ([sSetting isEqualToString:@"theme_night_brightness"]) {
        b = 1.0;
    }
    [[NSUserDefaults standardUserDefaults] setFloat:b forKey:sSetting];
     return b;
}

+ (NSString *) stringFromColor:(UIColor*)c {
    CGFloat red, green, blue, alpha;
    [c getRed: &red green: &green blue: &blue alpha: &alpha];
    return [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", red, green, blue, alpha];
}

+ (UIColor *) colorWithString: (NSString *)stringToConvert {
    NSString *cString = [stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Proper color strings are denoted with braces
    if (![cString hasPrefix:@"{"]) return DEFAULT_VOID_COLOR;
    if (![cString hasSuffix:@"}"]) return DEFAULT_VOID_COLOR;
    
    // Remove braces
    cString = [cString substringFromIndex:1];
    cString = [cString substringToIndex:([cString length] - 1)];
    
    // Separate into components by removing commas and spaces
    NSArray *components = [cString componentsSeparatedByString:@", "];
    if ([components count] != 4) return DEFAULT_VOID_COLOR;
    
    // Create the color
    return [UIColor colorWithRed:[[components objectAtIndex:0] floatValue]
                           green:[[components objectAtIndex:1] floatValue]
                            blue:[[components objectAtIndex:2] floatValue]
                           alpha:[[components objectAtIndex:3] floatValue]];
}

#pragma mark -
#pragma mark Colors definitions

// Background barre principale du bas
+ (UIColor *)tabBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
                return [UIColor whiteColor];
                //return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
            } else {
                return [UIColor whiteColor];
            }
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:23.0/255.0 green:24.0/255.0 blue:26.0/255.0 alpha:1.0]];
        default:                         return [UIColor whiteColor];
//return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

// Background barre principale du haut
+ (UIColor *)navBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
                return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
            } else {
                return [UIColor whiteColor];
            }
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:23.0/255.0 green:24.0/255.0 blue:26.0/255.0 alpha:1.0]];
            //case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:46.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0]];
        default:         return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)navBackgroundColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight:
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
                return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
            } else {
                return [UIColor whiteColor];
            }
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:23.0/255.0 green:24.0/255.0 blue:26.0/255.0 alpha:1.0]];
            //case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:46.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0]];
        default:         return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}


+ (UIColor *)textFieldBackgroundColor:(Theme)theme {
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.7];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:46.0/255.0 green:47.0/255.0 blue:51.0/255.0 alpha:0.7] withMin:20.0];
        default:         return [UIColor whiteColor];
    }
}

+ (UIColor *)textFieldBackgroundColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.7];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:46.0/255.0 green:47.0/255.0 blue:51.0/255.0 alpha:0.7] withMin:20.0];
        default:         return [UIColor whiteColor];
    }
}

+ (UIColor *)headerBLBackgroundColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:46.0/255.0 green:47.0/255.0 blue:51.0/255.0 alpha:1.0] withMin:20.0];
        default:         return [UIColor whiteColor];
    }
}

+ (UIColor *)textColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}

+ (UIColor *)textColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}


// Theme clair: un peu plus clair que textColor
// Thème sombre: un peu plus foncé que textColor
+ (UIColor *)textColor2:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}

+ (UIColor *)textColorPseudo:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)navItemTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}

// Texte barre du haut
+ (UIColor *)titleTextAttributesColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor blackColor];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}

// Texte barre du haut
+ (UIColor *)titleTextAttributesColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor blackColor];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}


+ (UIColor *)lightTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:186.0/255.0 green:186.0/255.0 blue:186.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            
    }
}

// Couleur du nb de messages dans VosSujets et auteur dans Messages
+ (UIColor *)topicMsgTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.79];
        case ThemeDark:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.79];
            
    }
}

// Couleur du nb de messages dans VosSujets et auteur dans Messages
+ (UIColor *)topicMsgTextColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.79];
        case ThemeDark:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.79];
            
    }
}

// Couleur du fond derrière les listes de topic : plutot en color1 si on arrive à changer la couleur du titre de section
+ (UIColor *)greyBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor groupTableViewBackgroundColor];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:1.0]];
        default:         return [UIColor groupTableViewBackgroundColor];
    }
    return [UIColor whiteColor]; //OK
}

+ (UIColor *)greyBackgroundColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor groupTableViewBackgroundColor];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:1.0]];
        default:         return [UIColor groupTableViewBackgroundColor];
    }
}

+ (UIColor *)addMessageBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor:  [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:1.0]];
        default:         return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
}


+ (UIColor *)messageBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:  return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        case ThemeDark:   return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:36.0/255.0 green:37.0/255.0 blue:41.0/255.0 alpha:1.0]];
        default:          return [UIColor whiteColor];//[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)messageModoBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:  return [UIColor colorWithRed:255/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        case ThemeDark:   return [UIColor colorWithRed:74/255.0 green:46/255.0 blue:60/255.0 alpha:1.0];
        default:          return [UIColor whiteColor];//[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)messageHeaderMeBackgroundColor:(Theme)theme{
    UIColor* c;
    CGFloat h, s, b, a;

    switch ([ThemeManager currentTheme]) {
        case ThemeLight:
            c = [ThemeColors getUserColor:@"theme_day_color_action"]; break;
        case ThemeDark: // Orange
            c = [ThemeColors getUserColor:@"theme_night_color_action"]; break;
    }
    [c getHue:&h saturation:&s brightness:&b alpha:&a];
    return [UIColor colorWithHue:h saturation:0.1 brightness:0.9 alpha:1.0];;
}

+ (UIColor *)messageHeaderLoveBackgroundColor {
    return [ThemeColors loveColor];
}

+ (UIColor *)defaultLoveColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: // Rose
            return [UIColor colorWithHue:0.9 saturation:0.1 brightness:1.0 alpha:1.0];
        case ThemeDark: // Rose
            return [UIColor colorWithHue:0.9 saturation:0.9 brightness:0.3 alpha:1.0];
    }
}

+ (UIColor *)loveColor:(Theme)theme {
    switch (theme) {
        case ThemeLight:
            return [ThemeColors getUserColor:@"theme_day_color_love"]; break;
        case ThemeDark: // Orange
            return [ThemeColors getUserColor:@"theme_night_color_love"]; break;
    }
}

+ (UIColor *)loveColor {
    return [self loveColor:[ThemeManager currentTheme]];
}

// Tint color avec transparence 0.07/1
+ (UIColor *)messageMeQuotedBackgroundColor:(Theme)theme{
    CGFloat r, g, b, alpha;
    UIColor* cTintColor = [self tintColor:theme];
    [cTintColor getRed:&r green:&g blue:&b alpha:&alpha];
    return [UIColor colorWithRed:r green:g blue:b alpha:0.07];
}

// Fond des items des listes Categorie/ Sujets/Messages :
// Theme light: reste blanc
+ (UIColor *)cellBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:  return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        case ThemeDark:   return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:36.0/255.0 green:37.0/255.0 blue:41.0/255.0 alpha:1.0]];
        default:          return [UIColor whiteColor];//[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)defaultSuperFavorite:(Theme)theme {
    switch (theme) {
        case ThemeLight: // Light yellow
            return [UIColor colorWithHue:0.13 saturation:0.08 brightness:1.0 alpha:1.0];
        case ThemeDark: // Dark blue
            return [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.2 alpha:1.0];
    }
}


// Fond des items des listes Categorie/ Sujets/Messages :
// Theme light: reste blanc
+ (UIColor *)cellBackgroundColorSuperFavorite {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight:
            return [ThemeColors getUserColor:@"theme_day_color_superfavori"]; break;
        case ThemeDark: // Orange
            return [ThemeColors getUserColor:@"theme_night_color_superfavori"]; break;
    }
}

+ (UIColor *)tintColorSuperFavorite {
    UIColor* c;
    CGFloat h, s, b, a;
    
    switch ([ThemeManager currentTheme]) {
        case ThemeLight:
            c = [ThemeColors getUserColor:@"theme_day_color_superfavori"]; break;
        case ThemeDark: // Orange
            c = [ThemeColors getUserColor:@"theme_night_color_superfavori"]; break;
    }
    [c getHue:&h saturation:&s brightness:&b alpha:&a];
    return [UIColor colorWithHue:h saturation:0.9 brightness:0.9 alpha:1.0];;
}


// ??
+ (UIColor *)cellHighlightBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:46.0/255.0 green:47.0/255.0 blue:51.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)cellIconColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}

+ (UIColor *)cellTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor blackColor];
        case ThemeDark:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        default:         return [UIColor blackColor];
    }
}

+ (UIColor *)cellTextColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor blackColor];
        case ThemeDark:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        default:         return [UIColor blackColor];
    }
}


+ (UIColor *)cellDisabledTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
        default:         return [UIColor blackColor];
    }
}

// Ligne séparant les topics dans les Categories/Sujets/Messages
+ (UIColor *)cellBorderColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            
    }
}
// Ligne séparant les topics dans les Categories/Sujets/Messages
+ (UIColor *)cellBorderColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:105.0/255.0 green:105.0/255.0 blue:105.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    }
}


+ (UIColor *)cellTintColor:(Theme)theme{
    return [self tintColor:theme];
}

+ (UIColor *)placeholderColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor grayColor];
        case ThemeDark:  return [UIColor colorWithRed:110.0/255.0 green:113.0/255.0 blue:125.0/255.0 alpha:1.0];
        default:         return [UIColor grayColor];
            
    }
}

+ (UIColor *)headSectionBackgroundColor{
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor colorWithRed: 230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:19.0/255.0 green:19.0/255.0 blue:20.0/255.0 alpha:1.0]];
        default:         return [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
    }
}

// Texte du titres de section (Categories ou titre dans les settings)
+ (UIColor *)headSectionTextColor {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight: return [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:1];
        case ThemeDark:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        default: return [UIColor colorWithRed:109/255.0f green:109/255.0f blue:114/255.0f alpha:1];
    }
}

+ (UITableViewCellSelectionStyle)cellSelectionStyle:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
    
        switch (theme) {
            case ThemeLight:
                return UITableViewCellSelectionStyleDefault;
            case ThemeDark:
                return UITableViewCellSelectionStyleNone;
            default:
                return UITableViewCellSelectionStyleDefault;
                
        }
    }
    else {
        return UITableViewCellSelectionStyleBlue;
    }
};

+ (UIColor *)tintColor:(Theme)theme{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"] == NO) {
        return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    }
    
    //UIColor* c;
    //CGFloat h, s, b, a;
    
    switch (theme) {
        case ThemeLight:
            return [ThemeColors getUserColor:@"theme_day_color_action"]; break;
        case ThemeDark: // Orange
            return [ThemeColors getUserColor:@"theme_night_color_action"]; break;
    }
    /*
    [c getHue:&h saturation:&s brightness:&b alpha:&a];
    NSLog(@"Hue : %f", h);
    return [UIColor colorWithHue:h saturation:0.1 brightness:0.9 alpha:1.0];;*/
}

+ (UIColor *)tintColor {
    return [self tintColor:[ThemeManager currentTheme]];
}

+ (UIColor *)tintColorWithAlpha:(CGFloat)newAlpha {
    UIColor* c = [self tintColor:[ThemeManager currentTheme]];
    CGFloat r, g, b, alpha;
    [c getRed:&r green:&g blue:&b alpha:&alpha];
    return [UIColor colorWithRed:r green:g blue:b alpha:newAlpha];
}


+ (UIColor *)defaultTintColor:(Theme)theme {
    switch (theme) {
        case ThemeLight: // Blue
            return [UIColor colorWithHue:211.0/360.0 saturation:0.9 brightness:0.95 alpha:1.0];
        case ThemeDark: // Orange
            return [UIColor colorWithHue:31.0/360.0 saturation:0.9 brightness:0.95 alpha:1.0];
    }
}
/*
+ (UIColor *)tintColor {
    CGFloat h, s, b, a;
    UIColor *c;
    
    switch ([ThemeManager currentTheme]) {
        case ThemeLight:
            c = [ThemeColors getUserColor:@"theme_day_color_action"]; break;
        case ThemeDark: // Orange
            c = [ThemeColors getUserColor:@"theme_night_color_action"]; break;
    }
    [c getHue:&h saturation:&s brightness:&b alpha:&a];
    return [UIColor colorWithHue:h saturation:0.9 brightness:0.95 alpha:1.0];;
}
*/

+ (UIColor *)tintLightColor {
    CGFloat h, s, b, a;
    UIColor *c;
    /*
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
        switch ([ThemeManager currentTheme]) {
            case ThemeLight: return [UIColor colorWithRed:229.0/255.0 green:242.0/255.0 blue:255.0/255.0 alpha:1.0];
            case ThemeDark:
                c = [UIColor colorWithRed:85.0/255.0 green:67.0/255.0 blue:52.0/255.0 alpha:1.0];
                return [self changeHue:c withValue:fDarkColor2];
                //[UIColor colorWithRed:85.0/255.0 green:67.0/255.0 blue:52.0/255.0 alpha:1.0];
            case ThemeOLED:  return [UIColor colorWithRed:85.0/255.0 green:67.0/255.0 blue:52.0/255.0 alpha:1.0];
            default:  return [UIColor colorWithRed:229.0/255.0 green:242.0/255.0 blue:255.0/255.0 alpha:1.0];
        }
    } else {*/
    switch ([ThemeManager currentTheme]) {
        case ThemeLight:
            c = [ThemeColors getUserColor:@"theme_day_color_action"]; break;
        case ThemeDark:
            c = [ThemeColors getUserColor:@"theme_night_color_action"]; break;
    }
    [c getHue:&h saturation:&s brightness:&b alpha:&a];
    return [UIColor colorWithHue:h saturation:0.1 brightness:1.0 alpha:1.0];;
}

+ (UIColor *)tintWhiteColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor whiteColor];
        case ThemeDark:  return [UIColor colorWithRed:42.0/255.0 green:143.0/255.0 blue:250.0/255.0 alpha:1.0];
        default:         return [UIColor whiteColor];
            
    }
}

+ (UIColor *)tintColorDisabled:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        switch (theme) {
            case ThemeLight:
                return [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
            case ThemeDark:
                return [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1.0];
        }
    }
    return [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
}

+ (UIColor *)overlayColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        case ThemeDark:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1];
        default:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
            
    }
}

+ (UIColor *)toolbarColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:19.0/255.0 green:19.0/255.0 blue:20.0/255.0 alpha:1.0];
        default:  return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)toolbarPageBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:38.0/255.0 green:40.0/255.0 blue:46.0/255.0 alpha:1.0];
        default:  return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)alertBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.9];
        case ThemeDark:  return [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:0.7];
        default:         return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.9];
    }
}

+ (UIBarStyle)barStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIBarStyleDefault;
        case ThemeDark:
            return UIBarStyleBlack;
        default:
            return UIBarStyleDefault;
            
    }
}

+ (UIStatusBarStyle)statusBarStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIStatusBarStyleDefault;
        case ThemeDark:
            return UIStatusBarStyleLightContent;
        default:
            return UIStatusBarStyleDefault;
            
    }
}

+ (UIKeyboardAppearance)keyboardAppearance:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIKeyboardAppearanceDefault;
        case ThemeDark:
            return UIKeyboardAppearanceDark;
        default:
            return UIKeyboardAppearanceDefault;
            
    }
}

+ (UIKeyboardAppearance)keyboardAppearance {
    switch ([ThemeManager currentTheme]) {
        case ThemeDark:
            return UIKeyboardAppearanceDark;
        case ThemeLight:
        default:
            return UIKeyboardAppearanceDefault;
            
    }
}


+ (NSString *)creditsCss:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"body{background:#efeff4;}.ios7 h1 {background:#efeff4;color: rgba(109, 109, 114, 1);}.ios7 ul {background:#fff;}.ios7 ul, .ios7 p {background:#fff;}";
        case ThemeDark:
            return @"body{background:rgba(30, 31, 33, 1);color: rgba(146, 147, 151, 1);} a{color: rgba(42, 153, 250, 1);} .ios7 h1 {background:rgba(36, 37, 41, 1);color: rgba(109, 109, 114, 1);}.ios7 ul, .ios7 p {background:rgba(30, 31, 33, 1);}";
        default:
            return @"body{background:#efeff4;}.ios7 h1 {background:#efeff4;color: rgba(109, 109, 114, 1);}.ios7 ul {background:#fff;}.ios7 ul, .ios7 p {background:#fff;}";
    }
}

+ (NSString *)smileysCss:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"body.ios7 {background:#bbc2c9;} body.ios7 .button { background-image : none !important; background-color : rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 #container_ajax img.smile, body.ios7 #smileperso img.smile { background-image : none !important; background-color: rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 .button.selected, body.ios7 #container_ajax img.smile.selected, body.ios7 #smileperso img.smile.selected { background-image : none !important; background-color:rgba(136,138,142,1); }";
        case ThemeDark:
            return @"body.ios7 {background:rgba(30, 31, 33, 1);} body.ios7 .button { background-image : none !important; background-color : rgba(255, 255, 255,0.2); border-bottom:1px solid rgb(68,70,77); } body.ios7 #container_ajax img.smile, body.ios7 #smileperso img.smile { background-image : none !important; background-color: rgba(255, 255, 255, 0.2); border-bottom:1px solid rgb(68,70,77); } body.ios7 .button.selected, body.ios7 #container_ajax img.smile.selected, body.ios7 #smileperso img.smile.selected { background-image : none !important; background-color:rgba(255,255,255,0.1); }";
        default:
            return @"body.ios7 {background:#bbc2c9;} body.ios7 .button { background-image : none !important; background-color : rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 #container_ajax img.smile, body.ios7 #smileperso img.smile { background-image : none !important; background-color: rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 .button.selected, body.ios7 #container_ajax img.smile.selected, body.ios7 #smileperso img.smile.selected { background-image : none !important; background-color:rgba(136,138,142,1); }";
    }
}

+ (NSString *)isLightThemeAlternate:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"";
        case ThemeDark:
            return @"alternate";
        default:
            return @"";
    }
}
+ (NSString *)isDarkThemeAlternate:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"alternate";
        case ThemeDark:
            return @"";
        default:
            return @"alternate";
    }
}

+ (NSString *)landscapePath:(Theme)theme{
    switch (theme) {
    case ThemeLight:
        return @"121-landscapebig.png";
    case ThemeDark:
        return @"121-landscapebig-white.png";
    default:
        return @"121-landscapebig.png";
    }
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)thorHammer:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIImage imageNamed:@"ThorHammerBlack-20"];
        case ThemeDark:
            return [UIImage imageNamed:@"ThorHammerGrey-20"];
    }
}

+ (UIImage *)heart:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIImage imageNamed:@"HeartBlack-20"];
        case ThemeDark:
            return [UIImage imageNamed:@"Heart-20"];
    }
}


+ (UIImage *)avatar:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIImage imageNamed:@"avatar_male_gray_on_light_48x48"];
        case ThemeDark:
            return [UIImage imageNamed:@"avatar_male_gray_on_dark_48x48"];
        default:
            return [UIImage imageNamed:@"avatar_male_gray_on_dark_48x48"];
    }
}

+ (UIImage *)tintImage:(UIImage *)image withTheme:(Theme)theme{
    return [self tintImage:image withColor:[self tintColor:theme]];
}


+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color{
    
            UIImage *imageNormal = image;
            UIGraphicsBeginImageContextWithOptions(imageNormal.size, NO, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            CGRect rect = (CGRect){ CGPointZero, imageNormal.size };
            CGContextSetBlendMode(context, kCGBlendModeNormal);
            [imageNormal drawInRect:rect];
            
            CGContextSetBlendMode(context, kCGBlendModeSourceIn);
            [color setFill];
            CGContextFillRect(context, rect);
            
            UIImage *imageTinted  = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return imageTinted;
}

+ (NSString *) getColorBorderQuotation:(Theme)theme
{
    switch (theme) {
        case ThemeLight:
            return @"silver";
        case ThemeDark:
            return @"rgba(255,255,255,0.2)";
        default:
            return @"silver";
    }
}

+ (UIColor *) getColorBorderAvatar:(Theme)theme
{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:113/255.0 green:125/255.0 blue:133/255.0 alpha:1.0];
        case ThemeDark:
            return [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        default:
            return [UIColor colorWithRed:113/255.0 green:125/255.0 blue:133/255.0 alpha:1.0];
    }
}

#pragma mark -
#pragma mark Theme styles definitions
+ (UIActivityIndicatorViewStyle)activityIndicatorViewStyle {
    switch ([ThemeManager currentTheme]) {
        case ThemeLight:
            return UIActivityIndicatorViewStyleGray;
        case ThemeDark:
            return UIActivityIndicatorViewStyleWhite;
        default:
           return UIActivityIndicatorViewStyleGray;
    }
}

+ (UIScrollViewIndicatorStyle)scrollViewIndicatorStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIScrollViewIndicatorStyleDefault;
        case ThemeDark:
            return UIScrollViewIndicatorStyleWhite;
        default:
            return UIScrollViewIndicatorStyleDefault;
    }
}

+ (UIImageRenderingMode) tabBarItemSelectedImageRendering {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
        return UIImageRenderingModeAlwaysTemplate;
    }
    return UIImageRenderingModeAlwaysOriginal;
}

+ (UIImageRenderingMode) tabBarItemUnselectedImageRendering {
    return UIImageRenderingModeAlwaysTemplate;
}

+ (NSString*) tabBarItemSelectedImageAtIndex:(int)index {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
        switch (index) {
            case 0:return @"categories_on";
            case 1:return @"favorites_on";
            case 2:return @"favorites_on";
            case 3:return @"mp_on";
            case 4:return @"dots_on";
        }
    }
    else {
        switch (index) {
            case 0:return @"cadeaux_on";
            case 1:return @"cadeau_on";
            case 2:return @"cadeau_on";
            case 3:return @"message_on";
            case 4:return @"cane_on";
        }
    }
    return @"";
}


+ (NSString*) tabBarItemUnselectedImageAtIndex:(int)index {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
        switch (index) {
            case 0:return @"categories";
            case 1:return @"favorites";
            case 2:return @"favorites";
            case 3:return @"mp";
            case 4:return @"dots";
        }
    }
    else {
        switch (index) {
            case 0:return @"cadeaux_off";
            case 1:return @"cadeau_off";
            case 2:return @"cadeau_off";
            case 3:return @"message_off";
            case 4:return @"cane_off";
        }
    }
    return @"";
}

#pragma mark -
#pragma mark Colors modification methods

+ (NSString *) hexFromUIColor:(UIColor *)color {
    
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[30] green:components[141] blue:components[13] alpha:components[1]];
    }
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0), (int)((CGColorGetComponents(color.CGColor))[1]*255.0), (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

+ (NSString *) rgbaFromUIColor:(UIColor *)color {
    CGFloat r, g, b, alpha;
    [color getRed:&r green:&g blue:&b alpha:&alpha];
    return [NSString stringWithFormat:@"rgba(%d, %d, %d, %1.2f)", (int)(r*255), (int)(g*255), (int)(b*255), alpha];
}

+ (NSString *) rgbaFromUIColor:(UIColor *)color withAlpha:(CGFloat) newAlpha {
    CGFloat r, g, b, alpha;
    [color getRed:&r green:&g blue:&b alpha:&alpha];
    return [NSString stringWithFormat:@"rgba(%d, %d, %d, %1.2f)", (int)(r*255), (int)(g*255), (int)(b*255), newAlpha];
}

//newsat from -1 to +1
//s=0.5, ns=1 => 1
//s=0.5, ns=0.5 => 0.75
//0.4, ns 0.5 => (1-0.4)*0.5 + 0.4
//ns(
+ (NSString *) rgbaFromUIColor:(UIColor *)color withAlpha:(CGFloat)newAlpha addSaturation:(CGFloat)newSat {
    CGFloat h, s, b, a;
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    return [self rgbaFromUIColor:[UIColor colorWithHue:h saturation:(1-s)*newSat+s brightness:b alpha:newAlpha]];
}

+ (NSString *) rgbaFromUIColor:(UIColor *)color withAlpha:(CGFloat)newAlpha addSaturation:(CGFloat)newSat addBrightness:(CGFloat)newBrightness {
    CGFloat h, s, b, a;
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    return [self rgbaFromUIColor:[UIColor colorWithHue:h saturation:(1-s)*newSat+s brightness:(1-b)*newBrightness+b alpha:newAlpha]];
}


+ (UIColor *) colorWithBrigthness:(UIColor *)color withBrightness:(CGFloat)newBrightness {
    CGFloat h, s, b, a;
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    return [UIColor colorWithHue:h saturation:s brightness:newBrightness alpha:a];
}

+ (NSString *) getActionColorCssHueRotation:(Theme)theme
{
    UIColor* c;
    CGFloat h, s, b, a;
    
    switch ([ThemeManager currentTheme]) {
        case ThemeLight:
            c = [ThemeColors getUserColor:@"theme_day_color_action"]; break;
        case ThemeDark: // Orange
            c = [ThemeColors getUserColor:@"theme_night_color_action"]; break;
    }
    [c getHue:&h saturation:&s brightness:&b alpha:&a];
    int iHueActionDegrees = (int)(h*360*(360-160)/0.555+160);
    
    return [NSString stringWithFormat:@"%ideg", iHueActionDegrees];
}

+ (UIColor*)adjustDarkThemeBrightnessOfColor:color
{
    return [ThemeColors adjustDarkThemeBrightnessOfColor:(UIColor*)color withMin:(CGFloat)0.0];
}

// Color = couleur à modifier
// Min = niveau de gris minimum entre 0 et 255
+ (UIColor*)adjustDarkThemeBrightnessOfColor:(UIColor*)color withMin:(CGFloat)min
{
    CGFloat hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        // Brithness of theme dark = 100%
        // 100% - brightness (valeur entre 0 et 1)
        // 0% - min/255
        // fDarkColor1 - fDarkColor1/100*(brightness-min/255) + min/255
        brightness = [ThemeColors getUserBrightness:@"theme_night_brightness"]*(brightness-min/255) + min/255;
        brightness = MAX(MIN(brightness, 1.0), 0.0); // Be sure to have a value ≥0 and ≤1;
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    
    CGFloat white;
    if ([color getWhite:&white alpha:&alpha]) {
        white = [ThemeColors getUserBrightness:@"theme_night_brightness"]*white;
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }
    
    return nil;
}

// Modify hue of color in param with value val
+ (UIColor *)changeHue:(UIColor*)color withValue:(CGFloat)val
{
    CGFloat newHue, hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    newHue = MAX(MIN(val, 1.0), 0.0);
    return [UIColor colorWithHue:newHue saturation:saturation brightness:brightness alpha:alpha];
}




@end
