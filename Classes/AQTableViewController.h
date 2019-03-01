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
#import "MessagesTableViewController.h"

@class ASIHTTPRequest;

@interface AQTableViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, NSXMLParserDelegate> {
    IBOutlet UITableView *aqTableView;
    IBOutlet UIView *loadingView;
    int iNumberNewAQ;
    MessagesTableViewController *messagesTableViewController;

    ASIHTTPRequest *request;
}

@property (nonatomic, strong) IBOutlet UITableView *aqTableView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;

@property (strong, nonatomic) ASIHTTPRequest *request;
@property (nonatomic, strong) NSMutableDictionary *dictData;
@property (nonatomic,strong) NSMutableArray *marrXMLData;
@property (nonatomic,strong) NSMutableString *mstrXMLString;
@property (nonatomic,strong) NSMutableDictionary *mdictXMLPart;
@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;
@property int *iNumberNewAQ;

- (void)fetchContentForNewAQ;

@end

#endif /* AQTableViewController_h */
