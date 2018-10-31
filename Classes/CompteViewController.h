//
//  CompteViewController.h
//  HFRplus
//
//  Created by FLK on 12/08/10.
//

#import <UIKit/UIKit.h>
#import "IdentificationViewController.h"

@interface CompteViewController : UIViewController <IdentificationViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITableView *comptesTableView;
}

@property (nonatomic, strong) IBOutlet UITableView* comptesTableView;
@property (nonatomic, strong) IBOutlet UILabel* loadingLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property BOOL pop;

- (void)checkLogin;
- (IBAction)login;
- (IBAction)logout;

- (IBAction)goToProfil;
@end
