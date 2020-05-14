//
// BookmarksTableViewController.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 07/10/2019.
//

#ifndef BookmarksTableViewController_h
#define BookmarksTableViewController_h

#import <UIKit/UIKit.h>

@class MessagesTableViewController;

@interface BookmarksTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, NSXMLParserDelegate> {
}

@property (nonatomic, strong) IBOutlet UITableView *bookmarksTableView;
@property (strong, nonatomic) IBOutlet UILabel *maintenanceView;

@property (nonatomic, strong) NSIndexPath *pressedIndexPath;
@property (strong, nonatomic) MessagesTableViewController *messagesTableViewController;

@end



#endif /*BookmarksTableViewController_h */
