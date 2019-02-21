//
//  AQCellCView.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 02/02/2019.
//

#ifndef AQCellCView_h
#define AQCellCView_h

@interface AQCellView : UITableViewCell {
    IBOutlet UILabel *labelTitleTopic;
    IBOutlet UILabel *labelTitleAQ;
    IBOutlet UILabel *labelTime;
}

@property (nonatomic, strong) IBOutlet UILabel *labelTitleTopic;
@property (strong, nonatomic) IBOutlet UILabel *labelTitleAQ;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;

@end

#endif /* AQCellCView_h */
