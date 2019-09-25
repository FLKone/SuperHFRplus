//
//  ThemeColorCellView.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 04/04/2019.
//

#ifndef ThemeColorCellView_h
#define ThemeColorCellView_h

@interface ThemeColorCellView : UITableViewCell {
}

- (void)applyTheme;

@property (strong, nonatomic) IBOutlet UILabel *labelColorName;
@property (strong, nonatomic) IBOutlet UILabel *labelColorBadge;

@end
    
#endif /* ThemeColorCellView_h */
