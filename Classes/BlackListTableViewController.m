//
//  BlackListTableViewController.m
//  HFRplus
//
//  Created by FLK on 28/08/2015.
//
//

#import "HFRplusAppDelegate.h"
#import "BlackListTableViewController.h"
#import "BlackList.h"
#import "InsetLabel.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "Constants.h"

@interface BlackListTableViewController ()

@end

@implementation BlackListTableViewController

NSInteger Sort_BL_Comparer(id id1, id id2, void *context)
{
    // Sort Function
    NSDictionary* dc1 = (NSDictionary*)id1;
    NSDictionary* dc2 = (NSDictionary*)id2;
    
    NSComparisonResult result = [[dc1 valueForKey:@"word"] compare:[dc2 valueForKey:@"word"] options:NSCaseInsensitiveSearch];
    
    return result;
}

- (void)reloadData {
    NSArray *sortedArray = [[[BlackList shared] getBlackListForActiveCompte] sortedArrayUsingFunction:Sort_BL_Comparer context:(__bridge void * _Nullable)(self)];
    self.listDict = (NSMutableArray *)sortedArray;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    self.title = @"Liste noire";
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[BlackList shared] removeFromBlackList:[[self.listDict objectAtIndex:indexPath.row] valueForKey:@"word"] andSave:YES];
        [self reloadData];
    }
}

- (NSTextAttachment *)iconForList {
    // creates a text attachment with an image
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [ThemeColors thorHammer:[[ThemeManager sharedManager] theme]];
    return attachment;
}

@end
