//
//  AQTableViewController.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 02/02/2019.
//

#import <Foundation/Foundation.h>
#import "AQTableViewController.h"
#import "AQCellView.h"

@implementation AQTableViewController;
@synthesize aqTableView, arrayData;
;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"PlusCellView" bundle:nil];
    [self.plusTableView registerNib:nib forCellReuseIdentifier:@"PlusCellId"];
    
    self.title = @"Plus";
    self.navigationController.navigationBar.translucent = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
 
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
    /*
    AQCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"AQCellId"];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

@end


