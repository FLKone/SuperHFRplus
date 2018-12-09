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

@implementation ThemeManager

int dayDelayMin = 40;
int nightDelayMin = 10;
int dayDelay;
int nightDelay;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static ThemeManager *sharedThemeManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedThemeManager = [[self alloc] init];
    });
    return sharedThemeManager;
}

- (id)init {
    if (self = [super init]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        theme = [defaults integerForKey:@"theme"];
        if(!theme){
            theme = ThemeLight;
        }

        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_dark_adjust"])
        {
            //  Apply customisation
            NSInteger value1 = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme_dark_color1"];
            NSInteger value2 = [[NSUserDefaults standardUserDefaults] integerForKey:@"theme_dark_color2"];
            [ThemeColors setDarkColor1:value1];
            [ThemeColors setDarkColor2:value2];
        }
        
        [self applyAppearance];
        [self changeAutoTheme:[defaults boolForKey:@"auto_theme"]];
    }
    return self;
}

- (void)setTheme:(Theme)newTheme {
    theme = newTheme;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:theme] forKey:@"theme"];
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

- (Theme)theme{
    //NSLog(@"%lu",(unsigned long)theme);
    return theme;
}

- (void)switchTheme {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    Theme day = [defaults integerForKey:@"auto_theme_day"];
    Theme night = [defaults integerForKey:@"auto_theme_night"];

    if (self.theme == day) {
        [self setTheme:night];
    } else {
        [self setTheme:day];
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
    if(theme == ThemeDark || theme == ThemeOLED){
         [alertContentView.subviews objectAtIndex:1].alpha = 0.0f;
    }
    
    // If present send title and text message color
    if (alert.title != nil)
    {
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:alert.message attributes:@{NSForegroundColorAttributeName: [ThemeColors textColor:theme]}];
        [alert setValue:attributedString forKey:@"attributedMessage"];
    }
    if (alert.message != nil)
    {
        NSAttributedString* attributedString2 = [[NSAttributedString alloc] initWithString:alert.title attributes:@{NSForegroundColorAttributeName: [ThemeColors textColor:theme]}];
        [alert setValue:attributedString2 forKey:@"attributedTitle"];
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
    
-(void)didUpdateLuminosity:(float)luminosity {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    Theme day = [defaults integerForKey:@"auto_theme_day"];
    Theme night = [defaults integerForKey:@"auto_theme_night"];
    
    if(dayDelay == 0 || nightDelay == 0){
        dayDelay = dayDelayMin;
        nightDelay = nightDelayMin;
    }
    
    if(luminosity < 0 && self.theme !=night){
        nightDelay--;
    }else if(luminosity >= 0 && self.theme !=day){
        dayDelay--;
    }
    
    if(nightDelay == 0){
       dispatch_async(dispatch_get_main_queue(), ^{ [self setTheme:night]; });
    }
    
    if(dayDelay == 0){
        dispatch_async(dispatch_get_main_queue(), ^{ [self setTheme:day]; });
    }

}


@end
