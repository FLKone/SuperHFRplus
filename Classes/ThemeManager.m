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
        
        [self applyAppearance];
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
                                      
- (Theme)theme{
    //NSLog(@"%lu",(unsigned long)theme);
    return theme;
}

- (void)switchTheme {
    if (self.theme == ThemeLight) {
        [self setTheme:ThemeDark];
    }
    else {
        [self setTheme:ThemeLight];
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
    if(theme == ThemeDark){
         [alertContentView.subviews objectAtIndex:1].alpha = 0.0f;
    }
}

@end
