//
//  PlusTableViewController.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 26/01/2019.
//

#import <Foundation/Foundation.h>
#import "PlusTableViewController.h"
#import "PlusSettingsViewController.h"
#import "CompteViewController.h"
#import "CreditsViewController.h"
#import "AQTableViewController.h"
#import "PlusCellView.h"
#import "ThemeColors.h"
#import "ThemeManager.h"

@implementation PlusTableViewController;
@synthesize plusTableView, iAQBadgeNumer, settingsViewController, compteViewController, aqTableViewController, creditsViewController;
;


- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"PlusCellView" bundle:nil];
    [self.plusTableView registerNib:nib forCellReuseIdentifier:@"PlusCellId"];

    self.title = @"Plus";
    self.navigationController.navigationBar.translucent = NO;
    self.plusTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.compteViewController = [[CompteViewController alloc] initWithNibName:@"CompteViewController" bundle:nil];
    self.settingsViewController = [[PlusSettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
    self.aqTableViewController = [[AQTableViewController alloc] initWithNibName:@"AQTableView" bundle:nil];
    self.creditsViewController = [[CreditsViewController alloc] initWithNibName:@"CreditsViewController" bundle:nil];
    
    iAQBadgeNumer = 0;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = self.plusTableView.backgroundColor = [ThemeColors greyBackgroundColor];
    self.plusTableView.separatorColor = [ThemeColors cellBorderColor];
    if (self.plusTableView.indexPathForSelectedRow) {
        [self.plusTableView deselectRowAtIndexPath:self.plusTableView.indexPathForSelectedRow animated:NO];
    }
    [self.aqTableViewController fetchContentForNewAQ];
    
    [self.plusTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:self.compteViewController animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:self.aqTableViewController animated:YES];
            break;
        case 2:
            [self.navigationController pushViewController:self.settingsViewController animated:YES];
            break;
        case 3:
            [self.navigationController pushViewController:self.creditsViewController animated:YES];
            break;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Titre à supprimer";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlusCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"PlusCellId"];
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"Compte(s)";
            cell.titleImage.image = [UIImage imageNamed:@"CircledUserMaleFilled-40"];
            cell.badgeLabel.text = @"";
            cell.badgeLabel.backgroundColor = [UIColor clearColor];
            break;
        case 1:
            cell.titleLabel.text = @"Alertes Qualitay";
            cell.titleImage.image = [UIImage imageNamed:@"08-chat"];
            cell.badgeLabel.clipsToBounds = YES;
            cell.badgeLabel.layer.cornerRadius = 20 * 1.2 / 2;
            if (iAQBadgeNumer > 0) {
                cell.badgeLabel.backgroundColor =  [ThemeColors tintColor];
                cell.badgeLabel.textColor = [UIColor whiteColor];
                cell.badgeLabel.text = [NSString stringWithFormat:@"%d", iAQBadgeNumer];
            } else {
                cell.badgeLabel.backgroundColor = [UIColor clearColor];
                cell.badgeLabel.textColor = [UIColor clearColor];
                cell.badgeLabel.text = @"";
            }
            break;
        case 2:
            cell.titleLabel.text = @"Réglages";
            cell.titleImage.image = [UIImage imageNamed:@"20-gear2"];
            cell.badgeLabel.text = @"";
            cell.badgeLabel.backgroundColor = [UIColor clearColor];
            break;
        case 3:
            cell.titleLabel.text = @"Crédits";
            cell.titleImage.image = [UIImage imageNamed:@"AboutFilled-25"];
            cell.badgeLabel.text = @"";
            cell.badgeLabel.backgroundColor = [UIColor clearColor];
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [[ThemeManager sharedManager] applyThemeToCell:cell];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end


