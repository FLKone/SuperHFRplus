//
//  AQCellCView.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 02/02/2019.
//

#ifndef AQCellCView_h
#define AQCellCView_h

@interface AQCellView : UITableViewCell {
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *titleTime;
    IBOutlet UILabel *titleInitiator;
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleTime;
@property (strong, nonatomic) IBOutlet UILabel *titleInitiator;

@end

#endif /* AQCellCView_h */
