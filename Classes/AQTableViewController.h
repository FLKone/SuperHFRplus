//
//  AQTableViewController.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 02/02/2019.
//

#ifndef AQTableViewController_h
#define AQTableViewController_h


#import <UIKit/UIKit.h>
#import "PlusSettingsViewController.h"
#import "CompteViewController.h"

@interface AQTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
    IBOutlet UITableView *aqTableView;
}

@property (nonatomic, strong) IBOutlet UITableView *aqTableView;

@end

#endif /* AQTableViewController_h */
