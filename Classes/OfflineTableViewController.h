//
//  OfflineTableViewController.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 07/10/2019.
//

#ifndef OfflineTableViewController_h
#define OfflineTableViewController_h

#import <UIKit/UIKit.h>
#import "PlusSettingsViewController.h"
#import "CompteViewController.h"
#import "MessagesTableViewController.h"

@class ASIHTTPRequest;

@interface OfflineTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, NSXMLParserDelegate> {
}

@property (nonatomic, strong) IBOutlet UITableView *offlineTableView;
//@property (nonatomic, strong) IBOutlet UIView *loadingView;

@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;
@property (nonatomic, strong) NSArray* listOfflineTopicsKeys;
@end



#endif /* OfflineTableViewController_h */
