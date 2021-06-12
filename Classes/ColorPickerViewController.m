//
//  ColorPickerViewController.m
//  SuperHFRplus
//
//  Created by ezzz on 23/07/2019.
//

#import "ColorPickerViewController.h"
#import "ThemeColorCellView.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "HFRAlertView.h"

@implementation ColorPickerViewController

@synthesize sColorSettingName, sColorSettingTitle, labelColorDisplay, sliderHue, sliderBrightness, sliderSaturation;
@synthesize labelCouleur, labelSaturation, labelLuminosite;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(resetColor)];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = sColorSettingTitle;
    
    UIColor* c = [ThemeColors getUserColor:sColorSettingName];
    CGFloat h, s, b, a;
    [c getHue:&h saturation:&s brightness:&b alpha:&a];
    
    labelColorDisplay.clipsToBounds = YES;
    labelColorDisplay.layer.cornerRadius = 20 * 1.2 / 2;
    labelColorDisplay.backgroundColor = c;
    
    sliderHue.maximumValue = 1.0;
    sliderHue.minimumValue = 0.0;
    sliderHue.value = h;
    sliderHue.tintColor = [UIColor colorWithHue:h saturation:1.0 brightness:1.0 alpha:1.0];
    
    sliderSaturation.maximumValue = 1.0;
    sliderSaturation.minimumValue = 0.0;
    sliderSaturation.value = s;
    sliderSaturation.tintColor = [UIColor colorWithHue:h saturation:s brightness:1.0 alpha:1.0];
    
    sliderBrightness.maximumValue = 1.0;
    sliderBrightness.minimumValue = 0.0;
    sliderBrightness.value = b;
    sliderBrightness.tintColor = [UIColor colorWithHue:0 saturation:0 brightness:b alpha:1.0];
    
    self.view.backgroundColor = [ThemeColors greyBackgroundColor];
    
    labelCouleur.textColor = [ThemeColors cellTextColor];
    labelSaturation.textColor = [ThemeColors cellTextColor];
    labelLuminosite.textColor = [ThemeColors cellTextColor];
}

- (IBAction)actionChangeHue:(UISlider *)sender {
    [self updateColor];
}

- (IBAction)actionChangeSaturation:(UISlider *)sender {
    [self updateColor];
}

- (IBAction)actionChangeBrightness:(UISlider *)sender {
    [self updateColor];
}

- (void)updateColor {
    UIColor* newColor = [UIColor colorWithHue:sliderHue.value saturation:sliderSaturation.value brightness:sliderBrightness.value alpha:1.0];
    labelColorDisplay.backgroundColor = newColor;
    [ThemeColors updateUserColor:sColorSettingName withColor:newColor];
    [[ThemeManager sharedManager] refreshTheme];
    
    NSLog(@"Update user color: %f, %f, %f,",sliderHue.value, sliderSaturation.value, sliderBrightness.value);
}

- (void)resetColor
{
    [HFRAlertView  DisplayOKCancelAlertViewWithTitle:@"Revenir aux valeurs par défaut ?" andMessage:nil handlerOK:^(UIAlertAction * action) {
        [ThemeColors resetUserColor:sColorSettingName];
        [[ThemeManager sharedManager] refreshTheme];
    }];
}

@end

