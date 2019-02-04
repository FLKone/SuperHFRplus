//
//  PlusTableViewController.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 26/01/2019.
//

#ifndef PlusTableViewController_h
#define PlusTableViewController_h

#import <UIKit/UIKit.h>
#import "PlusSettingsViewController.h"
#import "CompteViewController.h"
#import "AQTableViewController.h"

@interface PlusTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
    IBOutlet UITableView *plusTableView;
    PlusSettingsViewController *settingsViewController;
    CompteViewController *compteViewController;
    AQTableViewController *aqTableViewController;
}

@property (nonatomic, strong) IBOutlet UITableView *plusTableView;
@property (nonatomic, strong) PlusSettingsViewController *settingsViewController;
@property (nonatomic, strong) CompteViewController *compteViewController;
@property (nonatomic, strong) AQTableViewController *aqTableViewController;

@end

#endif /* PlusTableViewController_h */
