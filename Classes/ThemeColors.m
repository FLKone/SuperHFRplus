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

@implementation ThemeColors


static float fDarkColor1 = 100;//[[NSUserDefaults standardUserDefaults] integerForKey:@"theme_dark_color1"];
static float fDarkColor2 = 0.57; //100% par défaut
static float fDarkColor3 = 100; // Unused


// Ajustement brightness of dark theme
// En input valeur de 50 a 200:
// 100 = pas de modif sur le thème Dark
// 0 = Noir absolu = Thème OLED
// > 100 = Gris plus clair
+ (void)setDarkColor1:(int)b {
    fDarkColor1 = (float)b;
}
+ (void)setDarkColor2:(int)b {
    fDarkColor2 = (float)b/200.0; // valeur de 0 à 1
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
        brightness = fDarkColor1/100*(brightness-min/255) + min/255;
        brightness = MAX(MIN(brightness, 1.0), 0.0); // Be sure to have a value ≥0 and ≤1;
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    
    CGFloat white;
    if ([color getWhite:&white alpha:&alpha]) {
        white = fDarkColor1/100*white;
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }
    
    return nil;
}

/*
// Adjust brightness color with amount value (in %)
+ (UIColor*)changeBrightness:(UIColor*)color amount:(CGFloat)amount
{
    CGFloat hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        brightness += (amount-1.0);
        brightness = MAX(MIN(brightness, 1.0), 0.0);
        return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    }
    
    CGFloat white;
    if ([color getWhite:&white alpha:&alpha]) {
        white += (amount-1.0);
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white alpha:alpha];
    }
    
    return nil;
}*/

// Modify hue of color in param with value val
+ (UIColor *)changeHue:(UIColor*)color withValue:(CGFloat)val
{
    CGFloat newHue, hue, saturation, brightness, alpha;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        newHue = MAX(MIN(val, 1.0), 0.0);
        return [UIColor colorWithHue:newHue saturation:saturation brightness:brightness alpha:alpha];
    }
}


// Background barre principale du bas
+ (UIColor *)tabBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:23.0/255.0 green:24.0/255.0 blue:26.0/255.0 alpha:1.0]];
        case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

// Background barre principale du haut
+ (UIColor *)navBackgroundColor:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        switch (theme) {
            case ThemeLight: return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
            case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:23.0/255.0 green:24.0/255.0 blue:26.0/255.0 alpha:1.0]];
                //case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:46.0/255.0 green:48.0/255.0 blue:51.0/255.0 alpha:1.0]];
            case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
            default:         return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        }
    }
    return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0]; //OK
}

//
+ (UIColor *)textFieldBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:46.0/255.0 green:47.0/255.0 blue:51.0/255.0 alpha:1.0] withMin:20.0];
        case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        default:         return [UIColor whiteColor];
    }
}

+ (UIColor *)textColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:136.0/255.0 green:136.0/255.0 blue:136.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}


+ (UIColor *)navItemTextColor:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        switch (theme) {
            case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
            case ThemeOLED:  return [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
            default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        }
    }
    else {
        return [UIColor blueColor];//colorWithRed:113/255.f green:120/255.f blue:128/255.f alpha:1.00];
    }
}

// Texte barre du haut
+ (UIColor *)titleTextAttributesColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor blackColor];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:186.0/255.0 green:186.0/255.0 blue:186.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            
    }
}


+ (UIColor *)lightTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:186.0/255.0 green:186.0/255.0 blue:186.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:86.0/255.0 green:86.0/255.0 blue:86.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
            
    }
}

// Couleur du nb de messages dans VosSujets et auteur dans Messages
+ (UIColor *)topicMsgTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.79];
        case ThemeDark:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.79];
            
    }
}

// Couleur du fond derrière les listes de topic : plutot en color1 si on arrive à changer la couleur du titre de section
+ (UIColor *)greyBackgroundColor:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        switch (theme) {
            case ThemeLight: return [UIColor groupTableViewBackgroundColor];
            case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:1.0]];
            case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
            default:         return [UIColor groupTableViewBackgroundColor];
        }
    }
    return [UIColor whiteColor]; //OK
}

+ (UIColor *)addMessageBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor whiteColor];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor:  [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:1.0]];
        case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
}

// Fond des items des listes Categorie/ Sujets/Messages :
// Theme light: reste blanc
+ (UIColor *)cellBackgroundColor:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
    
        switch (theme) {
            case ThemeLight:  return [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
            case ThemeDark:   return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:36.0/255.0 green:37.0/255.0 blue:41.0/255.0 alpha:1.0]];
            case ThemeOLED:   return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
            default:          return [UIColor whiteColor];//[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
        }
    }
    else {
        return [UIColor whiteColor]; //OK
    }
}

// ??
+ (UIColor *)cellHighlightBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:46.0/255.0 green:47.0/255.0 blue:51.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:26.0/255.0 green:27.0/255.0 blue:31.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)cellIconColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:186.0/255.0 green:186.0/255.0 blue:186.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}

+ (UIColor *)cellTextColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor blackColor];
        case ThemeDark:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
        default:         return [UIColor blackColor];
    }
}

// Ligne séparant les topics dans les Categories/Sujets/Messages
+ (UIColor *)cellBorderColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:68.0/255.0 green:70.0/255.0 blue:77.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:0.3];
        default:         return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)cellTintColor:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        return [self tintColor:theme];
    }
    else {
        return [UIColor colorWithRed:42/255.0 green:116/255.0 blue:217/255.0 alpha:1.0]; //OK
    }
}

+ (UIColor *)placeholderColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor grayColor];
        case ThemeDark:  return [UIColor colorWithRed:110.0/255.0 green:113.0/255.0 blue:125.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:90.0/255.0 green:93.0/255.0 blue:95.0/255.0 alpha:1.0];
        default:         return [UIColor grayColor];
            
    }
}

+ (UIColor *)headSectionBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:239/255.0f green:239/255.0f blue:239/255.0f alpha:1.0];
        case ThemeDark:  return [ThemeColors adjustDarkThemeBrightnessOfColor: [UIColor colorWithRed:19.0/255.0 green:19.0/255.0 blue:20.0/255.0 alpha:1.0]];
        case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:0.7];
    }
}

// Texte du titres de section (Categories ou titre dans les settings)
+ (UIColor *)headSectionTextColor:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIColor* c;
        switch (theme) {
            case ThemeLight: return [UIColor colorWithRed:109/255.0f green:109/255.0f blue:114/255.0f alpha:1];
            case ThemeDark:  return [UIColor colorWithRed:146.0/255.0 green:147.0/255.0 blue:151.0/255.0 alpha:1.0];
            case ThemeOLED:  return [UIColor colorWithRed:176.0/255.0 green:177.0/255.0 blue:181.0/255.0 alpha:1.0];
            default: return [UIColor colorWithRed:109/255.0f green:109/255.0f blue:114/255.0f alpha:1];
        }
    }
    return [UIColor whiteColor]; //OK
}

+ (UITableViewCellSelectionStyle)cellSelectionStyle:(Theme)theme{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
    
        switch (theme) {
            case ThemeLight:
                return UITableViewCellSelectionStyleDefault;
            case ThemeDark:
            case ThemeOLED:
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIColor *c;
        switch (theme) {
            case ThemeLight: return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                
            case ThemeDark:
                c = [UIColor colorWithRed:42.0/255.0 green:143.0/255.0 blue:250.0/255.0 alpha:1.0];
                return [self changeHue:c withValue:fDarkColor2];
            case ThemeOLED:  return [UIColor colorWithRed:42.0/255.0 green:143.0/255.0 blue:250.0/255.0 alpha:1.0];
                c = [UIColor colorWithRed:42.0/255.0 green:143.0/255.0 blue:250.0/255.0 alpha:1.0];
                return [self changeHue:c withValue:fDarkColor2];
            default:         return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        }
    }
    return [UIColor colorWithRed:0.0 green:0/255.0 blue:0.0 alpha:1.0];
}

+ (UIColor *)tintLightColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:229.0/255.0 green:242.0/255.0 blue:255.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:85.0/255.0 green:67.0/255.0 blue:52.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:85.0/255.0 green:67.0/255.0 blue:52.0/255.0 alpha:1.0];
        default:  return [UIColor colorWithRed:229.0/255.0 green:242.0/255.0 blue:255.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)tintWhiteColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor whiteColor];
        case ThemeDark:  return [UIColor colorWithRed:42.0/255.0 green:143.0/255.0 blue:250.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:42.0/255.0 green:143.0/255.0 blue:250.0/255.0 alpha:1.0];
        default:         return [UIColor whiteColor];
            
    }
}

+ (UIColor *)overlayColor:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        case ThemeDark:
        case ThemeOLED:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1];
        default:
            return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
            
    }
}

+ (UIColor *)toolbarColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:19.0/255.0 green:19.0/255.0 blue:20.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        default:  return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)toolbarPageBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        case ThemeDark:  return [UIColor colorWithRed:38.0/255.0 green:40.0/255.0 blue:46.0/255.0 alpha:1.0];
        case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        default:  return [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
            
    }
}

+ (UIColor *)alertBackgroundColor:(Theme)theme{
    switch (theme) {
        case ThemeLight: return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.9];
        case ThemeDark:  return [UIColor colorWithRed:30.0/255.0 green:31.0/255.0 blue:33.0/255.0 alpha:0.7];
        case ThemeOLED:  return [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
        default:         return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.9];

    }
}

+ (UIBarStyle)barStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIBarStyleDefault;
        case ThemeDark:
        case ThemeOLED:
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
        case ThemeOLED:
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
        case ThemeOLED:
            return UIKeyboardAppearanceDark;
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
        case ThemeOLED:
            return @"body{background:rgba(0, 0, 0, 1);color: rgba(126, 127, 131, 1);} a{color: rgba(42, 153, 250, 1);} .ios7 h1 {background:rgba(0, 0, 0, 1);color: rgba(109, 109, 114, 1);}.ios7 ul, .ios7 p {background:rgba(0, 0, 0, 1);}";
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
        case ThemeOLED:
            return @"body.ios7 {background:rgba(0, 0, 0, 1);} body.ios7 .button { background-image : none !important; background-color : rgba(255, 255, 255,0.2); border-bottom:1px solid rgb(48,30,37); } body.ios7 #container_ajax img.smile, body.ios7 #smileperso img.smile { background-image : none !important; background-color: rgba(255, 255, 255, 0.2); border-bottom:1px solid rgb(48,30,37); } body.ios7 .button.selected, body.ios7 #container_ajax img.smile.selected, body.ios7 #smileperso img.smile.selected { background-image : none !important; background-color:rgba(255,255,255,0.1); }";
        default:
            return @"body.ios7 {background:#bbc2c9;} body.ios7 .button { background-image : none !important; background-color : rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 #container_ajax img.smile, body.ios7 #smileperso img.smile { background-image : none !important; background-color: rgba(255,255,255,1); border-bottom:1px solid rgb(136,138,142); } body.ios7 .button.selected, body.ios7 #container_ajax img.smile.selected, body.ios7 #smileperso img.smile.selected { background-image : none !important; background-color:rgba(136,138,142,1); }";
    }
}

+ (NSString *)isLightThemeAlternate:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"";
        case ThemeDark:
        case ThemeOLED:
            return @"alternate";
        default:
            return @"";
    }
}
+ (NSString *)isDarkThemeAlternate:(Theme)theme{
    switch (theme) {
        case ThemeOLED:
        case ThemeLight:
            return @"alternate";
        case ThemeDark:
            return @"";
        default:
            return @"alternate";
    }
}

+ (NSString *)isOLEDThemeAlternate:(Theme)theme{
    switch (theme) {
        case ThemeDark:
        case ThemeLight:
            return @"alternate";
        case ThemeOLED:
            return @"";
        default:
            return @"alternate";
    }
}

/* BAE no more used ?
+ (NSString *)messagesCssPath:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"style-liste.css";
        case ThemeDark:
            return @"style-liste-dark.css";
        case ThemeOLED:
            return @"style-liste-oled.css";
        default:
            return @"style-liste.css";
    }
}

+ (NSString *)messagesRetinaCssPath:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return @"style-liste-retina.css";
        case ThemeDark:
            return @"style-liste-retina-dark.css";
        case ThemeOLED:
            return @"style-liste-retina-oled.css";
        default:
            return @"style-liste-retina.css";
    }
}
*/

+ (NSString *)landscapePath:(Theme)theme{
    switch (theme) {
    case ThemeLight:
        return @"121-landscapebig.png";
    case ThemeDark:
    case ThemeOLED:
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
        case ThemeOLED:
            return [UIImage imageNamed:@"ThorHammerGrey-20"];
        default:
            return [UIImage imageNamed:@"ThorHammerBlack-20"];
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


+ (UIActivityIndicatorViewStyle)activityIndicatorViewStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
            return UIActivityIndicatorViewStyleGray;
        case ThemeDark:
        case ThemeOLED:
            return UIActivityIndicatorViewStyleWhite;
        default:
           return UIActivityIndicatorViewStyleGray;
    }
}

+ (UIScrollViewIndicatorStyle)scrollViewIndicatorStyle:(Theme)theme{
    switch (theme) {
        case ThemeLight:
        case ThemeDark:
            return UIScrollViewIndicatorStyleDefault;
        case ThemeOLED:
            return UIScrollViewIndicatorStyleWhite;
        default:
            return UIScrollViewIndicatorStyleDefault;
    }
}

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

+ (NSString *) getActionColorCssHueRotation:(Theme)theme
{
    int iHueActionDegrees = 0;
    if (theme >= ThemeDark)
    {
        // 0 => 140deg (rouge), 120/200 (0.6)=> 360eg (bleue), x => x×(360−140)÷0,6+140
        iHueActionDegrees = (int)(fDarkColor2*(360-140)/0.6+140);
    }
    
    return [NSString stringWithFormat:@"%ideg", iHueActionDegrees];
}
@end
