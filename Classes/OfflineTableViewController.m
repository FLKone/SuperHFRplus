//
//  OfflineTableViewController.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 07/10/2019.
//

#import <Foundation/Foundation.h>
#import "OfflineTableViewController.h"
#import "PlusTableViewController.h"
#import "MessagesTableViewController.h"
#import "AQCellView.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "MultisManager.h"
#import "ThemeManager.h"
#import "ThemeColors.h"
#import "OfflineStorage.h"
#import "FavoriteCellView.h"

@implementation OfflineTableViewController;
@synthesize offlineTableView, listOfflineTopicsKeys, alertProgress, progressView;

#pragma mark -
#pragma mark Data lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib2 = [UINib nibWithNibName:@"FavoriteCellView" bundle:nil];
    [self.offlineTableView registerNib:nib2 forCellReuseIdentifier:@"FavoriteCellID"];

    self.title = @"Topics hors ligne";
    self.navigationController.navigationBar.translucent = NO;
    //Supprime les lignes vides à la fin de la liste
    self.offlineTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenu)];;

    // Add PullToRefresh function to tableview
    //__weak OfflineTableViewController *self_ = self;
    //[self.OfflineTableView addPullToRefreshWithActionHandler:^{
    //    [self_ fetchContent];
    //}];
    //[self.OfflineTableView triggerPullToRefresh];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = self.offlineTableView.backgroundColor = [ThemeColors greyBackgroundColor];
    self.offlineTableView.separatorColor = [ThemeColors cellBorderColor];
    if (self.offlineTableView.indexPathForSelectedRow) {
        [self.offlineTableView deselectRowAtIndexPath:self.offlineTableView.indexPathForSelectedRow animated:NO];
    }
    
    /*
    self.OfflineTableView.pullToRefreshView.arrowColor = [ThemeColors cellTextColor];
    self.OfflineTableView.pullToRefreshView.textColor = [ThemeColors cellTextColor];
    self.OfflineTableView.pullToRefreshView.activityIndicatorViewStyle = [ThemeColors activityIndicatorViewStyle];
    */
    
    [self.offlineTableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
}


-(void) actionMenu {
    UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Actualiser" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self reload]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Mettre à jour le cache" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self refreshCache]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Vider le cache" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) { [self deleteCache]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }]];

    [self presentViewController:actionAlert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:actionAlert];
}

- (void)reload
{
    listOfflineTopicsKeys = [[OfflineStorage shared].dicOfflineTopics allKeys];
    //[self.OfflineTableView triggerPullToRefresh];
}

- (void)refreshCache
{
    [self addProgressBar];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadOfflineTopicsToCache];
    });

}
-(void) loadOfflineTopicsToCache {
    listOfflineTopicsKeys = [[OfflineStorage shared].dicOfflineTopics allKeys];
    int total = (int)[listOfflineTopicsKeys count];
    int c = 0;
    for (NSNumber* keyTopidID in listOfflineTopicsKeys)
    {
        Topic *tmpTopic = [[OfflineStorage shared].dicOfflineTopics objectForKey:keyTopidID];
        NSLog(@"Loading topic %@", keyTopidID);
        [[OfflineStorage shared] loadTopicToCache:tmpTopic];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = ((float)c)/total;
        });

        c++;
    }
    self.progressView.progress = 1.0;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) addProgressBar {
    self.alertProgress = [UIAlertController alertControllerWithTitle:@"Téléchargement des topics" message:@"50%" preferredStyle:UIAlertControllerStyleAlert];
    [self.alertProgress addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];

    UIView *alertView = self.alertProgress.view;

    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    self.progressView.progress = 0.0;
    self.progressView.translatesAutoresizingMaskIntoConstraints = false;
    [alertView addSubview:self.progressView];


    NSLayoutConstraint *bottomConstraint = [self.progressView.bottomAnchor constraintEqualToAnchor:alertView.bottomAnchor];
    [bottomConstraint setActive:YES];
    bottomConstraint.constant = -45; // How to constraint to Cancel button?

    [[self.progressView.leftAnchor constraintEqualToAnchor:alertView.leftAnchor] setActive:YES];
    [[self.progressView.rightAnchor constraintEqualToAnchor:alertView.rightAnchor] setActive:YES];

    [self presentViewController:self.alertProgress animated:true completion:nil];
}


- (void)deleteCache
{
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    listOfflineTopicsKeys = [[OfflineStorage shared].dicOfflineTopics allKeys];
    return self.listOfflineTopicsKeys.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FavoriteCellView *cell = (FavoriteCellView *)[tableView dequeueReusableCellWithIdentifier:@"FavoriteCellID"];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                                                         initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:longPressRecognizer];
    NSNumber* keyTopidID = [listOfflineTopicsKeys objectAtIndex:(NSUInteger)indexPath.row];
    Topic *tmpTopic = [[OfflineStorage shared].dicOfflineTopics objectForKey:keyTopidID];

    UIFont *font1 = [UIFont boldSystemFontOfSize:13.0f];
    if ([tmpTopic isViewed]) {
        font1 = [UIFont systemFontOfSize:13.0f];
    }
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: font1 forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[tmpTopic aTitle] attributes: arialDict];
    
    UIFont *font2 = [UIFont fontWithName:@"fontello" size:15];
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc]initWithString:@""];
    
    if (tmpTopic.isClosed) {
        UIColor *fontcC = [UIColor colorWithHex:@"#4A4A4A" alpha:1.0];
        NSDictionary *arialDict2c = [NSDictionary dictionaryWithObjectsAndKeys:font2, NSFontAttributeName, fontcC, NSForegroundColorAttributeName, nil];
        NSMutableAttributedString *aAttrString2C = [[NSMutableAttributedString alloc] initWithString:@" " attributes: arialDict2c];
        [finalString appendAttributedString:aAttrString2C];
    }
    
    [finalString appendAttributedString:aAttrString1];
    [cell.labelTitle setAttributedText:finalString];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger vos_sujets = [defaults integerForKey:@"vos_sujets"];
    NSString* sPoll = @"";
    if (tmpTopic.isPoll) {
        sPoll = @" \U00002263";
    }
    NSString* sRondPlein = @" \U000025CF";
    NSString* sRondVide = @" \U000025CF";
    [cell.labelMessageNumber setText:[NSString stringWithFormat:@"\U000025CF %d -> %d", [tmpTopic curTopicPage], [tmpTopic maxTopicPage]]];
    
    // Badge
    int iPageNumber = [tmpTopic maxTopicPage] - [tmpTopic curTopicPage];
    if (iPageNumber == 0) {
        cell.labelBadge.clipsToBounds = YES;
        cell.labelBadge.layer.cornerRadius = 20 / 2;
        [cell.labelBadge setText:@""];
        cell.labelBadge.backgroundColor = [UIColor clearColor];
        cell.labelBadgeWidth.constant = 0;
    } else {
        int iWidth = 16;
        if (iPageNumber < 10) {
            iWidth = 16;
        } else if (iPageNumber < 100) {
            iWidth = 23;
        } else if (iPageNumber < 1000) {
            iWidth = 30;
        } else if (iPageNumber <= 9999) {
            iWidth = 38;
        } else if (iPageNumber > 9999) {
            iPageNumber = 9999;
            iWidth = 38;
        }
        cell.labelBadge.clipsToBounds = YES;
        cell.labelBadge.layer.cornerRadius = 16 / 2;
        [cell.labelBadge setText:[NSString stringWithFormat:@"%d", iPageNumber]];
        cell.labelBadgeWidth.constant = iWidth;
    }
    
    [cell setShowsReorderControl:NO];
    
    // Posteur + date
    [cell.labelDate setText:[NSString stringWithFormat:@"%@ - %@", [tmpTopic aAuthorOfLastPost], [tmpTopic aDateOfLastPost]]];

    [cell applyTheme];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* topicID = [listOfflineTopicsKeys objectAtIndex:(NSUInteger)indexPath.row];
    Topic *topic = [[OfflineStorage shared].dicOfflineTopics objectForKey:topicID];
    if (![[OfflineStorage shared] checkTopicOffline:topic]) {
        // TBD AlertView
        return;
    }
    self.messagesTableViewController = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andOfflineTopic:topic];

    // Open topic
    // Sur iPhone
    if (([self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ||
        [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ||
        [[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hors ligne" style: UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:self.messagesTableViewController animated:YES];
    }
    /* TBD IPAD*
    else { //iPad
        [[[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:NO];
        
        [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] setViewControllers:[NSMutableArray arrayWithObjects:self.messagesTableViewController, nil] animated:YES];
        
        if ([messagesTableViewController.splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftBarButtonItem = messagesTableViewController.splitViewController.displayModeButtonItem;
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;
        }
    }
    
    // Close left panel on ipad in portrait mode
    [[HFRplusAppDelegate sharedAppDelegate] hidePrimaryPanelOnIpad];*/
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark -
#pragma mark RSS xml parsing

- (void)fetchContent
{
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
}
     
 - (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
}



@end


