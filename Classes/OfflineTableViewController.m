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
#import "HFRAlertView.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "HTMLParser.h"
#import "Favorite.h"
#import "Forum.h"

#define  UNICODE_CIRCLE_FULL        @"\U000025CF"
#define  UNICODE_CIRCLE_3QUARTERS   @"\U000025D4"
#define  UNICODE_CIRCLE_HALF        @"\U000025D1"
#define  UNICODE_CIRCLE_1QUARTER    @"\U000025D5"
#define  UNICODE_CIRCLE_EMPTY       @"\U000025CB"


@implementation OfflineTableViewController;
@synthesize offlineTableView, maintenanceView, listOfflineTopicsKeys, alertProgress, progressView, request;
@synthesize arrayData, arrayNewData, arrayTopics, arrayCategories, arrayCategoriesHidden, arrayCategoriesVisibleOrder, arrayCategoriesHiddenOrder; //v2 remplace arrayData, arrayDataID, arrayDataID2, arraySection
@synthesize topicActionAlert, pressedIndexPath, selectedTopic;

#pragma mark -
#pragma mark Data lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib2 = [UINib nibWithNibName:@"FavoriteCellView" bundle:nil];
    [self.offlineTableView registerNib:nib2 forCellReuseIdentifier:@"FavoriteCellID"];

    self.title = @"Topics hors ligne (beta)";
    self.navigationController.navigationBar.translucent = NO;
    //Supprime les lignes vides à la fin de la liste
    self.offlineTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenu)];;

    [[OfflineStorage shared] verifyCacheIntegrity];
    
    // Add PullToRefresh function to tableview
    /*
    __weak OfflineTableViewController *self_ = self;
    [self.offlineTableView addPullToRefreshWithActionHandler:^{
        [self_ refreshContent];
    }];*/
    //[self.OfflineTableView triggerPullToRefresh];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = self.offlineTableView.backgroundColor = self.maintenanceView.backgroundColor = [ThemeColors greyBackgroundColor];
    self.offlineTableView.separatorColor = [ThemeColors cellBorderColor];
    if (self.offlineTableView.indexPathForSelectedRow) {
        [self.offlineTableView deselectRowAtIndexPath:self.offlineTableView.indexPathForSelectedRow animated:NO];
    }
    
    /*
    self.offlineTableView.pullToRefreshView.arrowColor = [ThemeColors cellTextColor];
    self.offlineTableView.pullToRefreshView.textColor = [ThemeColors cellTextColor];
    self.offlineTableView.pullToRefreshView.activityIndicatorViewStyle = [ThemeColors activityIndicatorViewStyle];
    */
    [self.offlineTableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
}


-(void) actionMenu {
    UIAlertController *actionAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Actualiser les topics" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self reload]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Mettre à jour le cache" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [self refreshCache]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Vider le cache" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) { [self deleteCache]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Tout supprimer" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) { [self deleteCacheAndTopics]; }]];
    [actionAlert addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { }]];

    [self presentViewController:actionAlert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:actionAlert];
}

- (void)reload
{
    //listOfflineTopicsKeys = [[OfflineStorage shared].dicOfflineTopics allKeys];
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"vos_sujets"]) {
        case 0:
            [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forum1f.php?owntopic=1", [k ForumURL]]]]];
            break;
        case 1:
            [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forum1f.php?owntopic=3", [k ForumURL]]]]];
            break;
        default:
            [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/forum1f.php?owntopic=1", [k ForumURL]]]]];
            break;
    }
    
    [request setDelegate:self];

    [request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentComplete:)];
    [request setDidFailSelector:@selector(fetchContentFailed:)];
    
    [request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentStarted");
    //Bouton Stop

    self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelFetchContent)];
    self.navigationItem.rightBarButtonItem = segmentBarItem;

    //[self.favoritesTableView.pullToRefreshView stopAnimating];

    [self.maintenanceView setHidden:YES];
     /*
    [self.favoritesTableView setHidden:YES];
    [self.loadingView setHidden:NO];
     */
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentComplete");

    //Bouton Reload
    /*
    self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    */
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionMenu)];;

    [self loadDataInTableView:[theRequest responseData]];
    
    [self.arrayData removeAllObjects];
    self.arrayData = [NSMutableArray arrayWithArray:self.arrayNewData];
    [self.arrayNewData removeAllObjects];
    
    [self.offlineTableView reloadData];
}

-(void)loadDataInTableView:(NSData *)contentData
{
    NSLog(@"loadDataInTableView");
    
    [self.arrayCategories removeAllObjects];
    [self.arrayCategoriesHidden removeAllObjects];
    
    HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:NULL];
    HTMLNode * bodyNode = [myParser body];
    //HTMLNode *hash_check = [bodyNode findChildWithAttribute:@"name" matchingName:@"hash_check" allowPartial:NO];
    //[[HFRplusAppDelegate sharedAppDelegate] setHash_check:[hash_check getAttributeNamed:@"value"]];

    HTMLNode *tableNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"main" allowPartial:NO]; //Get favs for cat
    NSArray *temporaryFavoriteArray = [tableNode findChildTags:@"tr"];
    
    BOOL first = YES;
    Favorite *aFavorite;
    NSMutableArray* tmpTopics = [[NSMutableArray alloc] init];
    
    //Loop through all the tags
    for (HTMLNode * trNode in temporaryFavoriteArray)
    {
        if ([[trNode className] rangeOfString:@"fondForum1fCat"].location != NSNotFound)
        {
            if (!first) {
                // On rajoute la catégorie si elle est visible à la liste des sujets (cat  + topics)
                if (aFavorite.topics.count > 0)
                {
                    //[self.arrayNewData addObject:aFavorite];
                    [self addFavorite:aFavorite into:self.arrayNewData andTopicsInto:tmpTopics];
                }
            }

            aFavorite = [[Favorite alloc] init];
            [aFavorite parseNode:trNode];
            first = NO;
        }
        else if ([[trNode className] rangeOfString:@"ligne_booleen"].location != NSNotFound) {
            [aFavorite addTopicWithNode:trNode];
        }
    }
    if (!first)
    {
        // On rajoute la catégorie si elle est visible à la liste des sujets (cat  + topics)
        if (aFavorite.topics.count > 0)
        {
            //[self.arrayNewData addObject:aFavorite];
            [self addFavorite:aFavorite into:self.arrayNewData andTopicsInto:tmpTopics];
        }
    }
    
    //self.arrayTopics
    
    //NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey: @"dDateOfLastPost" ascending:NO selector:@selector(compare:)];
    //self.arrayTopics = (NSMutableArray *)[tmpTopics sortedArrayUsingDescriptors: [NSMutableArray arrayWithObject:sortDescriptorDate]];
    
    for (Topic* t in tmpTopics) {
        [[OfflineStorage shared] updateOfflineTopic:t];
    }
    
    [self.offlineTableView reloadData];
}

- (void)addFavorite:(Favorite*)fav into:(NSMutableArray*)arrayDataLocal andTopicsInto:(NSMutableArray*)arrayTopicsLocal
{
    [arrayDataLocal addObject:fav];
    for (Topic* topic in fav.topics)
    {
        [arrayTopicsLocal addObject:topic];
    }
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentFailed");
    /*
    //Bouton Reload
    self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
    */
    
    [self.maintenanceView setHidden:NO];

    // Popup
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]  preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) { }];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
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
        c++;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = ((float)c)/total;
            [self.alertProgress setMessage:[NSString stringWithFormat:@"%.f%%",((float)c)/total * 100.]];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = 1.0;
        [self.alertProgress setMessage:@"100%"];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.offlineTableView reloadData];
    });
}

-(void) addProgressBar {
    self.alertProgress = [UIAlertController alertControllerWithTitle:@"Téléchargement des topics" message:@"0%" preferredStyle:UIAlertControllerStyleAlert];
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


- (void)deleteCache {
    
    [HFRAlertView DisplayOKCancelAlertViewWithTitle:@"Supprimer le contenu des topics en cache ?"
                                          andMessage:nil
                                          handlerOK:^(UIAlertAction * action) {[[OfflineStorage shared] eraseAllTopicsInCache]; [self.offlineTableView reloadData];}];
}

- (void)deleteCacheAndTopics {
    
    [HFRAlertView DisplayOKCancelAlertViewWithTitle:@"Supprimer le contenu des topics en cache ?"
                                          andMessage:nil
                                          handlerOK:^(UIAlertAction * action) {[[OfflineStorage shared] eraseAllTopics]; [self.offlineTableView reloadData];}];
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
    NSString* sPoll = @"";
    if (tmpTopic.isPoll) {
        sPoll = @" \U00002263";
    }

    NSString* sSymbol = UNICODE_CIRCLE_EMPTY;
    if (tmpTopic.isTopicLoadedInCache) {
        if (tmpTopic.maxTopicPageLoaded < tmpTopic.maxTopicPage) {
            sSymbol = UNICODE_CIRCLE_HALF;
        } else {
            sSymbol = UNICODE_CIRCLE_FULL;
        }
    }
    
    if (tmpTopic.isTopicLoadedInCache == NO) {
        [cell.labelMessageNumber setText:[NSString stringWithFormat:@"%@ %d \U00002192 %d", sSymbol, tmpTopic.curTopicPage, tmpTopic.maxTopicPage]];
        cell.isFavoriteDisabled = YES;
        cell.userInteractionEnabled = NO;
    } else {
        cell.isFavoriteDisabled = NO;
        cell.userInteractionEnabled = YES;

        if (tmpTopic.maxTopicPageLoaded > tmpTopic.minTopicPageLoaded) {
            [cell.labelMessageNumber setText:[NSString stringWithFormat:@"%@ %d / %d \U00002192 %d", sSymbol, tmpTopic.curTopicPageLoaded, tmpTopic.minTopicPageLoaded, tmpTopic.maxTopicPageLoaded]];
        } else {
            [cell.labelMessageNumber setText:[NSString stringWithFormat:@"%@ %d / %d", sSymbol, tmpTopic.curTopicPageLoaded, tmpTopic.maxTopicPageLoaded]];
        }
    }
    
    // Badge
    int iPageNumber = [tmpTopic maxTopicPage] - [tmpTopic curTopicPage];
    if (tmpTopic.isTopicLoadedInCache == YES) {
        iPageNumber = tmpTopic.maxTopicPageLoaded - tmpTopic.curTopicPageLoaded;
    }
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

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint longPressLocation = [longPressRecognizer locationInView:self.offlineTableView];
        self.pressedIndexPath = [[self.offlineTableView indexPathForRowAtPoint:longPressLocation] copy];

        if (topicActionAlert != nil) {
            topicActionAlert = nil;
        }
        NSMutableArray *arrayActionsMessages = [NSMutableArray array];
        [arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"la dernière page", @"lastPageAction", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
        [arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"la page numéro...", @"chooseTopicPage", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];

        /* Evol onglet sticky (gardée au cas où)
        [arrayActionsMessages addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Nouvel onglet", @"newTabBar", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]]; */


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
        
    }
}

-(void)lastPageAction{
    NSIndexPath *indexPath = pressedIndexPath;
    NSNumber* topicID = [listOfflineTopicsKeys objectAtIndex:(NSUInteger)indexPath.row];
    Topic *topic = [[OfflineStorage shared].dicOfflineTopics objectForKey:topicID];
    if (topic.isTopicLoadedInCache) {
        topic.curTopicPage = topic.maxTopicPageLoaded;
        MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andOfflineTopic:topic];
        self.messagesTableViewController = aView;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hors ligne" style: UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:self.messagesTableViewController animated:YES];
    }
}

-(void)chooseTopicPage {
    //NSLog(@"chooseTopicPage Favs");

    NSIndexPath *indexPath = self.pressedIndexPath;
    NSNumber* topicID = [listOfflineTopicsKeys objectAtIndex:(NSUInteger)indexPath.row];
    self.selectedTopic = [[OfflineStorage shared].dicOfflineTopics objectForKey:topicID];
    if (!self.selectedTopic.isTopicLoadedInCache) {
        return;
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString * message = [[NSMutableAttributedString alloc] initWithString:@"Aller à la page"];
    [message addAttribute:NSForegroundColorAttributeName value:[ThemeColors textColor:[[ThemeManager sharedManager] theme]] range:(NSRange){0, [message.string length]}];
    [alertController setValue:message forKey:@"attributedTitle"];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSString stringWithFormat:@"(numéro entre %d et %d)", self.selectedTopic.minTopicPageLoaded, self.selectedTopic.maxTopicPageLoaded];
        [[ThemeManager sharedManager] applyThemeToTextField:textField];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        [textField addTarget:self action:@selector(textFieldTopicDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray * textfields = alertController.textFields;
        UITextField * pagefield = textfields[0];
        int number = [[pagefield text] intValue];
        [self goToPage:number];

    }]];
     [alertController addAction:[UIAlertAction actionWithTitle:@"Annuler"
                                                           style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [alertController dismissViewControllerAnimated:YES completion:nil];
                                                       }]];
    
    [[ThemeManager sharedManager] applyThemeToAlertController:alertController];
    [self presentViewController:alertController animated:YES completion:^{
        if([[ThemeManager sharedManager] theme] == ThemeDark){
            for (UIView* textfield in alertController.textFields) {
                UIView *container = textfield.superview;
                UIView *effectView = container.superview.subviews[0];
                
                if (effectView && [effectView class] == [UIVisualEffectView class]){
                    container.backgroundColor = [UIColor clearColor];
                    [effectView removeFromSuperview];
                }
            }
        }
    }];
}

-(void)textFieldTopicDidChange:(id)sender {
    //NSLog(@"textFieldDidChange %d %@", [[(UITextField *)sender text] intValue], sender);
    
    
    if ([[(UITextField *)sender text] length] > 0) {
        int val;
        if ([[NSScanner scannerWithString:[(UITextField *)sender text]] scanInt:&val]) {
            //NSLog(@"int %d %@ %@", val, [(UITextField *)sender text], [NSString stringWithFormat:@"%d", val]);
            
            if (![[(UITextField *)sender text] isEqualToString:[NSString stringWithFormat:@"%d", val]]) {
                //NSLog(@"pas int");
                [sender setText:[NSString stringWithFormat:@"%d", val]];
            }
            else if ([[(UITextField *)sender text] intValue] < 1) {
                //NSLog(@"ERROR WAS %d", [[(UITextField *)sender text] intValue]);
                [sender setText:[NSString stringWithFormat:@"%d", self.selectedTopic.minTopicPageLoaded]];
                //NSLog(@"ERROR NOW %d", [[(UITextField *)sender text] intValue]);
                
            }
            else if ([[(UITextField *)sender text] intValue] > self.selectedTopic.maxTopicPageLoaded) {
                //NSLog(@"ERROR WAS %d", [[(UITextField *)sender text] intValue]);
                [sender setText:[NSString stringWithFormat:@"%d",  self.selectedTopic.maxTopicPageLoaded]];
                //NSLog(@"ERROR NOW %d", [[(UITextField *)sender text] intValue]);
                
            }
            else {
                //NSLog(@"OK");
            }
        }
        else {
            [sender setText:@""];
        }
        
        
    }
}

-(void)goToPage:(int)newPage {
    if (self.selectedTopic.isTopicLoadedInCache && newPage <= self.selectedTopic.maxTopicPageLoaded && newPage >= self.selectedTopic.minTopicPageLoaded) {
        self.selectedTopic.curTopicPage = newPage;
        MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andOfflineTopic:self.selectedTopic];
        self.messagesTableViewController = aView;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Hors ligne" style: UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:self.messagesTableViewController animated:YES];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* topicID = [listOfflineTopicsKeys objectAtIndex:(NSUInteger)indexPath.row];
    Topic *topic = [[OfflineStorage shared].dicOfflineTopics objectForKey:topicID];
    if (![[OfflineStorage shared] checkTopicOffline:topic]) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark -
#pragma mark RSS xml parsing

- (void)refreshContent
{
}

@end


