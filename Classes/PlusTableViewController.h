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
#import "CreditsViewController.h"
#import "AQTableViewController.h"
#import "OfflineTableViewController.h"

@interface PlusTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate> {
    IBOutlet UITableView *plusTableView;
    int iAQBadgeNumer;
    PlusSettingsViewController *settingsViewController;
    CompteViewController *compteViewController;
    AQTableViewController *aqTableViewController;
    CreditsViewController *creditsViewController;
    CreditsViewController *charteViewController;
}

@property (nonatomic, strong) IBOutlet UITableView *plusTableView;
@property int iAQBadgeNumer;
@property (nonatomic, strong) PlusSettingsViewController *settingsViewController;
@property (nonatomic, strong) CompteViewController *compteViewController;
@property (nonatomic, strong) AQTableViewController *aqTableViewController;
@property (nonatomic, strong) OfflineTableViewController *offlineTableViewController;
@property (nonatomic, strong) CreditsViewController *creditsViewController;
@property (nonatomic, strong) CreditsViewController *charteViewController;

@end

#endif /* PlusTableViewController_h */
