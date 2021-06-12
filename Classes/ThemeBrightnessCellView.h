//
//  ThemeBrightnessCellView.h
//  SuperHFRplus
//
//  Created by ezzz on 04/04/2019.
//

#ifndef ThemeBrightnessCellView_h
#define ThemeBrightnessCellView_h

@interface ThemeBrightnessCellView : UITableViewCell {
}

@property NSString* brightnessSettingsName;

- (void)applyTheme;
@property (strong, nonatomic) IBOutlet UISlider *sliderBrightness;
- (IBAction)changeBrightness:(UISlider *)sender;
@property (strong, nonatomic) IBOutlet UIImageView *imageSlider;
@property (strong, nonatomic) IBOutlet UIButton *buttonReset;

@end
    
#endif /* ThemeBrightnessCellView_h */
