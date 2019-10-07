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
    IBOutlet UITableView *offlineTableView;
    IBOutlet UIView *loadingView;
    int iNumberNewOffline;
    MessagesTableViewController *messagesTableViewController;

    ASIHTTPRequest *request;
}

@property (nonatomic, strong) IBOutlet UITableView *OfflineTableView;
//@property (nonatomic, strong) IBOutlet UIView *loadingView;

@property (strong, nonatomic) ASIHTTPRequest *request;
@property (nonatomic, strong) NSMutableDictionary *dictData;
@property (nonatomic,strong) NSMutableArray *marrXMLData;
@property (nonatomic,strong) NSMutableString *mstrXMLString;
@property (nonatomic,strong) NSMutableDictionary *mdictXMLPart;
@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;
@property int *iNumberNewOffline;


@end



#endif /* OfflineTableViewController_h */
