//
//  ThemeSettingsViewController.h
//  SuperHFRplus
//
//  Created by ezzz on 23/07/2019.
//
#import <UIKit/UIKit.h>
#import "ColorPickerViewController.h"

@interface ThemeSettingsViewController : UIViewController
{
}

@property (strong, nonatomic) IBOutlet UITableView *tableThemeSettings;
@property ColorPickerViewController* colorPickerViewController;




/*
//@property (strong, nonatomic) IBOutlet UISegmentedControl *choixURL;
@property (strong, nonatomic) IBOutlet UISlider *sliderDayColorAction;
@property (strong, nonatomic) IBOutlet UISlider *sliderDayColorLove;
@property (strong, nonatomic) IBOutlet UISlider *sliderDayColorSuperFavori;
@property (strong, nonatomic) IBOutlet UISlider *sliderNightColorAction;
@property (strong, nonatomic) IBOutlet UISlider *sliderNightColorLove;
@property (strong, nonatomic) IBOutlet UISlider *sliderNightColorSuperFavori;
@property (strong, nonatomic) IBOutlet UILabel *lblDayColorAction;
@property (strong, nonatomic) IBOutlet UILabel *lblDayColorLove;
@property (strong, nonatomic) IBOutlet UILabel *lblDayColorSuperFavori;
@property (strong, nonatomic) IBOutlet UILabel *lblNightColorAction;
@property (strong, nonatomic) IBOutlet UILabel *lblNightColorLove;
@property (strong, nonatomic) IBOutlet UILabel *lblNightColorSuperFavori;

- (IBAction)changeDayColorAction:(UISlider *)sender;
- (IBAction)changeDayColorLove:(UISlider *)sender;
- (IBAction)changeDayColorSuperFavori:(UISlider *)sender;
- (IBAction)changeNightColorAction:(UISlider *)sender;
- (IBAction)changeNightColorLove:(UISlider *)sender;
- (IBAction)changeNightColorSuperFavori:(UISlider *)sender;

- (IBAction)actionDefautThemeDay:(id)sender;
- (IBAction)actionDefautThemeNight:(id)sender;
*/

@end
