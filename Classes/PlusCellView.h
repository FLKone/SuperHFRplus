//
//  PlusCellView.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 27/01/2019.
//

#ifndef PlusCellView_h
#define PlusCellView_h

@interface PlusCellView : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *badgeLabel;
    IBOutlet UIImageView *titleImage;
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *titleImage;
@property (strong, nonatomic) IBOutlet UILabel *badgeLabel;

@end

#endif /* PlusCellView_h */
