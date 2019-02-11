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
#import "AQTableViewController.h"
#import "PlusCellView.h"
#import "ThemeColors.h"

@implementation PlusTableViewController;
@synthesize plusTableView, settingsViewController, compteViewController, aqTableViewController;
;


- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *nib = [UINib nibWithNibName:@"PlusCellView" bundle:nil];
    [self.plusTableView registerNib:nib forCellReuseIdentifier:@"PlusCellId"];

    self.title = @"Plus";
    self.navigationController.navigationBar.translucent = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = self.plusTableView.backgroundColor = [ThemeColors greyBackgroundColor];
    self.plusTableView.separatorColor = [ThemeColors cellBorderColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            self.compteViewController = [[CompteViewController alloc] initWithNibName:@"CompteViewController" bundle:nil];
            [self.navigationController pushViewController:self.compteViewController animated:YES];
            break;
        case 1:
            self.aqTableViewController = [[AQTableViewController alloc] initWithNibName:@"AQTableView" bundle:nil];
            [self.navigationController pushViewController:self.aqTableViewController animated:YES];
            break;
        case 2: {
            self.settingsViewController = [[PlusSettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
            [self.navigationController pushViewController:self.settingsViewController animated:YES];
            break;
        }
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlusCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"PlusCellId"];
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"Compte(s)";
            cell.titleImage.image = [UIImage imageNamed:@"CircledUserMaleFilled-40"];
            break;
        case 1:
            cell.titleLabel.text = @"Alertes Qualitay";
            cell.titleImage.image = [UIImage imageNamed:@"08-chat"];
            break;
        case 2:
            cell.titleLabel.text = @"Réglages";
            cell.titleImage.image = [UIImage imageNamed:@"20-gear2"];
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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


