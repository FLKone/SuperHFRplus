//
//  ThemeManager.m
//  HFRplus
//
//  Created by Aynolor on 17/02/17.
//
//

#import "ThemeManager.h"
#import "ThemeColors.h"
#import "AvatarTableViewCell.h"
#import "PlusCellView.h"
#import "SimpleCellView.h"


@implementation ThemeManager

@synthesize theme;

int dayDelayMin = 40;
int nightDelayMin = 10;
int dayDelay;
int nightDelay;

#pragma mark Singleton Methods

+ (ThemeManager*)sharedManager {
    static ThemeManager *sharedThemeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedThemeManager = [[self alloc] init];
    });
    return sharedThemeManager;
}

+ (Theme) currentTheme {
    return [[ThemeManager sharedManager] theme];
}

- (id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger iSettingsTheme = [defaults integerForKey:@"theme"];
        if (iSettingsTheme == 2) {
            theme = ThemeDark;
            [ThemeColors updateUserBrightness:@"theme_night_brightness" withBrightness:0.0];
        }
        else if (iSettingsTheme == 0 || iSettingsTheme == 1) {
            theme = (Theme)iSettingsTheme;
        }
        else {
            theme = ThemeLight;
        }
        [self applyAppearance];
        [self changeAutoTheme:([defaults integerForKey:@"auto_theme"] == AUTO_THEME_AUTO_CAMERA)];
    }
    return self;
}



- (void)changeTheme:(Theme)newTheme {
    self.theme = newTheme;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:self.theme] forKey:@"theme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSNotification *myNotification = [NSNotification notificationWithName:kThemeChangedNotification
                                                                   object:self  //object is usually the object posting the notification
                                                                 userInfo:nil]; //userInfo is an optional dictionary
    
    //Post it to the default notification center
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
    
    /*
    if (newTheme == ThemeLight) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    */
    
    [self applyAppearance];
}

- (void)refreshTheme {
    //Post it to the default notification center
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSNotification *myNotification = [NSNotification notificationWithName:kThemeChangedNotification
                                                                   object:self  //object is usually the object posting the notification
                                                                 userInfo:nil]; //userInfo is an optional dictionary
    [[NSNotificationCenter defaultCenter] postNotification:myNotification];
    
    [self applyAppearance];
}

/*
- (Theme)theme{
    //NSLog(@"%lu",(unsigned long)theme);
    return theme;
}*/

- (void)switchTheme {
    if (self.theme == ThemeLight) {
        [self setThemeManually:ThemeDark];
    } else {
        [self setThemeManually:ThemeLight];
    }
}

-(void)applyAppearance {
    // Apply theme to keyboard
    if ([[UITextField appearance] respondsToSelector:@selector(setKeyboardAppearance:)]) {
        [UITextField appearance].keyboardAppearance = [ThemeColors keyboardAppearance:theme];
    }
    
    [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]]
     setTintColor:[ThemeColors tintColor:theme]];
}

- (void)applyThemeToCell:(UITableViewCell *)cell{
    cell.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    cell.textLabel.textColor = [ThemeColors cellTextColor:theme];
    if ([cell respondsToSelector:@selector(setTintColor:)]) {
        cell.tintColor = [ThemeColors tintColor:theme];
    }

    if(![cell isKindOfClass:[AvatarTableViewCell class]]){
        if ([cell.imageView respondsToSelector:@selector(setTintColor:)]) {
            UIImage *img =[cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.imageView.image = img;
            cell.imageView.tintColor = [ThemeColors cellIconColor:theme];
        }
    }
    
    if([cell isKindOfClass:[PlusCellView class]]){
        PlusCellView* plusCellView = (PlusCellView*)cell;
        UIImage *img =[plusCellView.titleImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        plusCellView.titleImage.image = img;
        plusCellView.titleImage.tintColor = [ThemeColors cellIconColor:theme];
    }
    
    if([cell isKindOfClass:[SimpleCellView class]]){
        SimpleCellView* simpleCellView = (SimpleCellView*)cell;
        UIImage *img = [simpleCellView.imageIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        simpleCellView.imageIcon.image = img;
        simpleCellView.imageIcon.tintColor = [ThemeColors cellIconColor:theme];
    }
    
    cell.selectionStyle = [ThemeColors cellSelectionStyle:theme];
}

- (void)applyThemeToTextField:(UITextField *)textfield{
    //if(theme == ThemeDark){
        
        textfield.backgroundColor = [ThemeColors textFieldBackgroundColor:[[ThemeManager sharedManager] theme]];
        textfield.textColor = [ThemeColors cellTextColor:[[ThemeManager sharedManager] theme]];
        if ([textfield respondsToSelector:@selector(setTintColor:)]) {
            textfield.tintColor = [ThemeColors cellTextColor:[[ThemeManager sharedManager] theme]];
        }
        
        UIButton *btnClear = [textfield valueForKey:@"_clearButton"];
        UIImage *imageNormal = [btnClear imageForState:UIControlStateNormal];
        UIGraphicsBeginImageContextWithOptions(imageNormal.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGRect rect = (CGRect){ CGPointZero, imageNormal.size };
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        [imageNormal drawInRect:rect];
        
        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
        [[UIColor whiteColor] setFill];
        CGContextFillRect(context, rect);
        
        UIImage *imageTinted  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [btnClear setImage:imageTinted forState:UIControlStateNormal];
        
        textfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textfield.attributedPlaceholder.string
                                        attributes:@{
                                                     NSForegroundColorAttributeName: [ThemeColors placeholderColor:theme]
                                                     }
         ];
        
    //}
}

- (void)applyThemeToAlertController:(UIAlertController *)alert{
    // Vieww hierarchy : https://stackoverflow.com/a/44606994/1853603
    UIView *firstSubview = alert.view.subviews.firstObject;
    UIView *alertContentView = firstSubview.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        subSubView.backgroundColor = [ThemeColors alertBackgroundColor:theme];
    }
    
    // If dark theme, hide white effect view
    if(theme == ThemeDark){
         [alertContentView.subviews objectAtIndex:1].alpha = 0.0f;
    }
    
    // If present send title and text message color
    if (alert.title != nil)
    {
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:alert.title attributes:@{NSForegroundColorAttributeName: [ThemeColors textColor:theme], NSFontAttributeName: [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold]}];
        [alert setValue:attributedString forKey:@"attributedTitle"];
    }
    if (alert.message != nil)
    {
        NSAttributedString* attributedString2 = [[NSAttributedString alloc] initWithString:alert.message attributes:@{NSForegroundColorAttributeName: [ThemeColors textColor:theme], NSFontAttributeName: [UIFont systemFontOfSize:13.f weight:UIFontWeightRegular]}];
        [alert setValue:attributedString2 forKey:@"attributedMessage"];
    }
}

- (void)changeAutoTheme:(BOOL)autoTheme{
    if(autoTheme){
        if(!self.luminosityHandler){
            self.luminosityHandler = [[LuminosityHandler alloc] init];
            self.luminosityHandler.delegate = self;
        }
        [self.luminosityHandler capture];
    }else{
        [self.luminosityHandler stop];
    }
}
    
- (void)didUpdateLuminosity:(float)luminosity {
    if(dayDelay == 0 || nightDelay == 0) {
        dayDelay = dayDelayMin;
        nightDelay = nightDelayMin;
    }
    
    if(luminosity < 0 && self.theme != ThemeDark) {
        nightDelay--;
    } else if(luminosity >= 0 && self.theme != ThemeLight) {
        dayDelay--;
    }
    
    if(nightDelay == 0) {
       dispatch_async(dispatch_get_main_queue(), ^{ [self setTheme:ThemeDark]; });
    }
    
    if(dayDelay == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self setTheme:ThemeLight]; });
    }

}

- (void)setThemeManually:(Theme)newTheme {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"auto_theme"] == AUTO_THEME_AUTO_TIME) {
        Theme calculatedTheme = (Theme)[self getThemeFromCurrentTime];
        //NSLog(@"AUTO_THEME_AUTO_TIME > MANUAL current theme %d / calculated %d",self.theme, calculatedTheme);
        if ([[NSUserDefaults standardUserDefaults]  objectForKey:@"force_manual_theme"] == nil) {
            if (newTheme != calculatedTheme) {
                //NSLog(@"AUTO_THEME_AUTO_TIME > manual force theme");
                [[NSUserDefaults standardUserDefaults] setInteger:newTheme forKey:@"force_manual_theme"];
            } else {
                //NSLog(@"AUTO_THEME_AUTO_TIME > REMOVE manual force theme");
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"force_manual_theme"];
            }
        }
    }
    
    [self changeTheme:newTheme];
}

- (void) checkTheme {
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"auto_theme"] == AUTO_THEME_AUTO_TIME) {
        // Check if theme has been changed manually last time
        Theme calculatedTheme = (Theme)[self getThemeFromCurrentTime];
        [self setTheme:calculatedTheme];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"auto_theme"] == AUTO_THEME_AUTO_IOS) {
        if (@available(iOS 13.0, *)) {
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                NSLog(@"=============== UITraitCollection DARK =============== ");
                [self setTheme:ThemeDark];
            } else {
                NSLog(@"............... UITraitCollection light .............. ");
                [self setTheme:ThemeLight];
            }
        }
    }
}

- (Theme) getThemeFromCurrentTime {
    NSDate *now = [NSDate date];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    NSDateFormatter * df2 = [[NSDateFormatter alloc] init];
    NSString *sTimeDay = [[NSUserDefaults standardUserDefaults] stringForKey:@"auto_theme_day_time"];
    NSString *sTimeNight = [[NSUserDefaults standardUserDefaults] stringForKey:@"auto_theme_night_time"];
    [df setDateFormat:@"YY-MM-dd HH:mm"];
    [df2 setDateFormat:@"YY-MM-dd"];
    NSString *today = [df2 stringFromDate:now];
    NSDate *dTimeDay = [df dateFromString:[NSString stringWithFormat:@"%@ %@", today,  sTimeDay]];
    NSDate *dTimeNight = [df dateFromString:[NSString stringWithFormat:@"%@ %@", today,  sTimeNight]];
    
    if ([dTimeDay earlierDate:now] == now || [dTimeNight laterDate:now] == now) {
        return ThemeDark;
    }
    return ThemeLight;
}
@end
