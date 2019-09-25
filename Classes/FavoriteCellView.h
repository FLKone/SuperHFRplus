//
//  FavoriteCellView.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 04/04/2019.
//

#ifndef FavoriteCellView_h
#define FavoriteCellView_h

@interface FavoriteCellView : UITableViewCell {
}

- (void)applyTheme;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelBadgeWidth;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelMessageNumber;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelBadge;
@property BOOL isSuperFavorite;

@end
    
#endif /* FavoriteCellView_h */
