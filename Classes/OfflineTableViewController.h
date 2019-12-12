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
@property (strong, nonatomic) IBOutlet UILabel *maintenanceView;

@property (nonatomic, strong) MessagesTableViewController *messagesTableViewController;
@property (nonatomic, strong) NSArray* listOfflineTopicsKeys;

@property (nonatomic, strong) UIAlertController *alertProgress;
@property (nonatomic, strong) UIProgressView *progressView;

@property (strong, nonatomic) ASIHTTPRequest *request;

@property (nonatomic, strong) NSMutableArray *arrayData;
@property (nonatomic, strong) NSMutableArray *arrayTopics;
@property (nonatomic, strong) NSMutableArray *arrayNewData;
@property (nonatomic, strong) NSMutableArray *arrayCategories;
@property (nonatomic, strong) NSMutableArray *arrayCategoriesHidden;
@property (nonatomic, strong) NSMutableArray *arrayCategoriesVisibleOrder; // Ordre des catégories visibles: liste de Favorite.forum.aID (identifiant de catégorie)
@property (nonatomic, strong) NSMutableArray *arrayCategoriesHiddenOrder; // Ordre des catégories masquées: liste de Favorite.forum.aID (identifiant de catégorie)


@end



#endif /* OfflineTableViewController_h */
