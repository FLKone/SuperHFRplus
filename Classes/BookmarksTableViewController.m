//
//  BookmarksTableViewController.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 07/10/2019.
//

#import <Foundation/Foundation.h>
#import "BookmarksTableViewController.h"
#import "PlusTableViewController.h"
#import "MessagesTableViewController.h"
#import "AQCellView.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "MultisManager.h"
#import "ThemeManager.h"
#import "ThemeColors.h"
#import "MPStorage.h"
#import "FavoriteCellView.h"
#import "HFRAlertView.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "HTMLParser.h"
#import "Favorite.h"
#import "Forum.h"
#import "Constants.h"
#import "Bookmark.h"

@implementation BookmarksTableViewController;
@synthesize bookmarksTableView, maintenanceView, messagesTableViewController, pressedIndexPath;

#pragma mark - Data lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"FavoriteCellView" bundle:nil];
    [self.bookmarksTableView registerNib:nib forCellReuseIdentifier:@"FavoriteCellID"];

    self.title = @"Bookmarks";
    self.navigationController.navigationBar.translucent = NO;

    //Supprime les lignes vides à la fin de la liste
    self.bookmarksTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenu)];;
    
    
    // Add PullToRefresh function to tableview
    __weak BookmarksTableViewController *self_ = self;
    [self.bookmarksTableView addPullToRefreshWithActionHandler:^{
        [self_ reload];
    }];
    //[self.bookmarksTableView triggerPullToRefresh];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = self.bookmarksTableView.backgroundColor = self.bookmarksTableView.pullToRefreshView.backgroundColor = self.maintenanceView.backgroundColor = [ThemeColors greyBackgroundColor];
    self.bookmarksTableView.separatorColor = [ThemeColors cellBorderColor];
    if (self.bookmarksTableView.indexPathForSelectedRow) {
        [self.bookmarksTableView deselectRowAtIndexPath:self.bookmarksTableView.indexPathForSelectedRow animated:NO];
    }
    
    self.bookmarksTableView.pullToRefreshView.arrowColor = [ThemeColors cellTextColor];
    self.bookmarksTableView.pullToRefreshView.textColor = [ThemeColors cellTextColor];
    self.bookmarksTableView.pullToRefreshView.activityIndicatorViewStyle = [ThemeColors activityIndicatorViewStyle];

    [self.bookmarksTableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
}


-(void) actionMenu {
    UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    //[actionAlert addAction:[UIAlertAction actionWithTitle:@"Mettre à jour le cache" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self refreshCache]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Actualiser" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self reload]; }]];
    //[actionAlert addAction:[UIAlertAction actionWithTitle:@"Supprimer le cache" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) { [self deleteCache]; }]];
    //[actionAlert addAction:[UIAlertAction actionWithTitle:@"Supprimer le cache et les topics" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) { [self deleteCacheAndTopics]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }]];

    [self presentViewController:actionAlert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:actionAlert];
}

- (void)reload {
    [[MPStorage shared] reloadMPStorageAsynchronousWithCompletion:^{
        
    }];
     //listBookmarksTopicsKeys = [[MPStorage shared].dicBookmarksTopics allKeys];
}

#pragma mark - TableView delegate methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //int i = [[MPStorage shared] getBookmarksNumber];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*listBookmarksTopicsKeys = [[MPStorage shared].dicBookmarksTopics allKeys];
    return self.listBookmarksTopicsKeys.count;*/
    int i = [[MPStorage shared] getBookmarksNumber];
    return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FavoriteCellView *cell = (FavoriteCellView *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteCellID"];

    [cell setShowsReorderControl:NO];

    Bookmark* bookmark = [[MPStorage shared] getBookmarkAtIndex:(int)indexPath.row];
    
    // Label
    UIFont *font2 = [UIFont fontWithName:@"fontello" size:15];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font2 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:bookmark.sLabel attributes: arialDict];
    [cell.labelTitle setAttributedText:aAttrString1];

    // Page number
    [cell.labelMessageNumber setText:[NSString stringWithFormat:@"%@", bookmark.sAuthorPost]];
    
    
    // No badge
    cell.labelBadge.clipsToBounds = YES;
    cell.labelBadge.layer.cornerRadius = 20 / 2;
    [cell.labelBadge setText:@""];
    cell.labelBadge.backgroundColor = [UIColor clearColor];
    cell.labelBadgeWidth.constant = 0;

    // Posteur + date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy à hh:mm"];
    NSString *theDate = [dateFormat stringFromDate:bookmark.dateBookmarkCreation];
    [cell.labelDate setText:[NSString stringWithFormat:@"%@", theDate]];
    
    [cell applyTheme];
    
    return cell;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    /*
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint longPressLocation = [longPressRecognizer locationInView:self.bookmarksTableView];
        self.pressedIndexPath = [[self.bookmarksTableView indexPathForRowAtPoint:longPressLocation] copy];

        if (topicActionAlert != nil) {
            topicActionAlert = nil;
        }
        NSMutableArray *arrayActionsMessages = [NSMutableArray array];
        [arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"la dernière page", @"lastPageAction", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
        [arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"la page numéro...", @"chooseTopicPage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];


        topicActionAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        for( NSDictionary *dico in arrayActionsMessages) {
            [topicActionAlert addAction:[UIAlertAction actionWithTitle:[dico valueForKey:@"title"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([self respondsToSelector:NSSelectorFromString([dico valueForKey:@"code"])])
                {
                    //[self performSelector:];
                    [self performSelectorOnMainThread:NSSelectorFromString([dico valueForKey:@"code"]) withObject:nil waitUntilDone:NO];
                }
                else {
                    NSLog(@"CRASH not respondsToSelector %@", [dico valueForKey:@"code"]);
                    
                    [self performSelectorOnMainThread:NSSelectorFromString([dico valueForKey:@"code"]) withObject:nil waitUntilDone:NO];
                }
            }]];
        }

        CGPoint longPressLocation2 = [longPressRecognizer locationInView:[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view]];
        CGRect origFrame = CGRectMake( longPressLocation2.x, longPressLocation2.y, 1, 1);
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // Can't use UIAlertActionStyleCancel in dark theme : https://stackoverflow.com/a/44606994/1853603
            UIAlertActionStyle cancelButtonStyle = [[ThemeManager sharedManager] theme] == ThemeDark ? UIAlertActionStyleDefault : UIAlertActionStyleCancel;
            [topicActionAlert addAction:[UIAlertAction actionWithTitle:@"Annuler" style:cancelButtonStyle handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
        } else {
            // Required for UIUserInterfaceIdiomPad
            topicActionAlert.popoverPresentationController.sourceView = [[[HFRplusAppDelegate sharedAppDelegate] splitViewController] view];
            topicActionAlert.popoverPresentationController.sourceRect = origFrame;
            topicActionAlert.popoverPresentationController.backgroundColor = [ThemeColors alertBackgroundColor:[[ThemeManager sharedManager] theme]];
        }
        
        [self presentViewController:topicActionAlert animated:YES completion:nil];
        [[ThemeManager sharedManager] applyThemeToAlertController:topicActionAlert];
        
    }*/
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Bookmark* bookmark = [[MPStorage shared] getBookmarkAtIndex:(int)indexPath.row];
    NSString* sURL = [bookmark getUrl];
    //NSString* sURL = @"/forum2.php?config=hfr.inc&cat=14&post=115&numreponse=5978240#t5978240";
    NSLog(@"URL: (%@)", sURL);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"https://forum.hardware.fr/forum2.php?config=hfr.inc&cat=14&post=115&numreponse=5978240#t5978240"]];
    [request startSynchronous];
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    NSLog(@"Code:%d, Status:%@", statusCode, statusMessage);
    //
    self.messagesTableViewController = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:sURL];

    // Open topic
    // Sur iPhone
    if (([self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ||
        [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ||
        [[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Bookmarks" style: UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:self.messagesTableViewController animated:YES];
    }
    else { //iPad
        [[[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:NO];
        
        [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] setViewControllers:[NSMutableArray arrayWithObjects:self.messagesTableViewController, nil] animated:YES];
        
        if ([self.messagesTableViewController.splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftBarButtonItem = self.messagesTableViewController.splitViewController.displayModeButtonItem;
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;
        }
        
        // Close left panel on ipad in portrait mode
        [[HFRplusAppDelegate sharedAppDelegate] hidePrimaryPanelOnIpad];
    }
    
}


@end


