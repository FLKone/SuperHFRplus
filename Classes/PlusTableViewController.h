//
//  PlusViewController.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 26/01/2019.
//

#ifndef PlusViewController_h
#define PlusViewController_h

#import <UIKit/UIKit.h>

@interface PlusTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
    IBOutlet UITableView *plusTableView;
}

@property (nonatomic, strong) IBOutlet UITableView *plusTableView;

@end


#endif /* PlusViewController_h */
