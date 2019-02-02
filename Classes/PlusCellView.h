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
    IBOutlet UIImageView *titleImage;
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *titleImage;

@end

#endif /* PlusCellView_h */
