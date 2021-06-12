//
//  ColorPickerViewController.h
//  SuperHFRplus
//
//  Created by ezzz on 23/07/2019.
//
#import <UIKit/UIKit.h>

@interface ColorPickerViewController : UIViewController
{
}
@property NSString* sColorSettingName;
@property NSString* sColorSettingTitle;

@property (strong, nonatomic) IBOutlet UILabel *labelColorDisplay;

@property (strong, nonatomic) IBOutlet UISlider *sliderHue;
@property (strong, nonatomic) IBOutlet UISlider *sliderSaturation;
@property (strong, nonatomic) IBOutlet UISlider *sliderBrightness;
@property (strong, nonatomic) IBOutlet UILabel *labelCouleur;
@property (strong, nonatomic) IBOutlet UILabel *labelSaturation;
@property (strong, nonatomic) IBOutlet UILabel *labelLuminosite;
- (IBAction)actionChangeHue:(UISlider *)sender;
- (IBAction)actionChangeSaturation:(UISlider *)sender;
- (IBAction)actionChangeBrightness:(UISlider *)sender;

@end
