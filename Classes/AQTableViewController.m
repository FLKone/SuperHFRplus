//
//  AQTableViewController.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 02/02/2019.
//

#import <Foundation/Foundation.h>
#import "AQTableViewController.h"
#import "PlusTableViewController.h"
#import "MessagesTableViewController.h"
#import "AQCellView.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "ThemeManager.h"
#import "ThemeColors.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "PullToRefreshErrorViewController.h"

@implementation AQTableViewController;
@synthesize aqTableView; //, arrayData;
@synthesize marrXMLData;
@synthesize mstrXMLString;
@synthesize mdictXMLPart;

#pragma mark -
#pragma mark Data lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"AQCellView" bundle:nil];
    [self.aqTableView registerNib:nib forCellReuseIdentifier:@"AQCellViewId"];
    
    self.title = @"Alertes Qualitay";
    self.navigationController.navigationBar.translucent = NO;
    //Supprime les lignes vides à la fin de la liste
    self.aqTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];;

    // Add PullToRefresh function to tableview
    __weak AQTableViewController *self_ = self;
    [self.aqTableView addPullToRefreshWithActionHandler:^{
        [self_ fetchContent];
    }];
    
    //[self.aqTableView triggerPullToRefresh];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = self.aqTableView.backgroundColor = self.aqTableView.pullToRefreshView.backgroundColor = [ThemeColors greyBackgroundColor];
    self.aqTableView.separatorColor = [ThemeColors cellBorderColor];
    if (self.aqTableView.indexPathForSelectedRow) {
        [self.aqTableView deselectRowAtIndexPath:self.aqTableView.indexPathForSelectedRow animated:NO];
    }
    
    self.aqTableView.pullToRefreshView.arrowColor = [ThemeColors cellTextColor];
    self.aqTableView.pullToRefreshView.textColor = [ThemeColors cellTextColor];
    self.aqTableView.pullToRefreshView.activityIndicatorViewStyle = [ThemeColors activityIndicatorViewStyle];
    
    [self.aqTableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    iNumberNewAQ = 0;
    [[NSUserDefaults standardUserDefaults] setObject:[[NSDate alloc] init] forKey:@"last_check_aq"];
    
    [self setBadgePlusTableView];
}

-(void)reload
{
    [self.aqTableView triggerPullToRefresh];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Titre à supprimer";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return marrXMLData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AQCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"AQCellViewId"];
    NSString *sTopicTitle = [[marrXMLData objectAtIndex:indexPath.row] valueForKey:@"topic_title"];
    NSString *sAqPubDate = [[marrXMLData objectAtIndex:indexPath.row] valueForKey:@"pubDate"];
    NSString *sInitiator = [[marrXMLData objectAtIndex:indexPath.row] valueForKey:@"initiator"];
    NSString *sAqNom = [[marrXMLData objectAtIndex:indexPath.row] valueForKey:@"title"];
    NSString *sAqComment = [[marrXMLData objectAtIndex:indexPath.row] valueForKey:@"comment"];
    BOOL bIsNew = [[[marrXMLData objectAtIndex:indexPath.row] valueForKey:@"is_new"] boolValue];

    cell.labelTitleTopic.text = sTopicTitle;
    cell.labelTitleAQ.text = sAqNom;
    cell.labelCommentAQ.text = sAqComment;
    
    cell.labelTime.text = [NSString stringWithFormat:@"par %@ %@", sInitiator, sAqPubDate];;
    
    [cell.labelTitleTopic setTextColor:[ThemeColors textColor]];
    if (bIsNew) {
        [cell.labelTitleTopic setFont:[UIFont boldSystemFontOfSize:13.0f]];
    } else {
        [cell.labelTitleTopic setFont:[UIFont systemFontOfSize:13.0f]];
    }
    [cell.labelTitleAQ setTextColor:[ThemeColors topicMsgTextColor]];
    [cell.labelTime setTextColor:[ThemeColors tintColor]];

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sTopicUrl = [[marrXMLData objectAtIndex:indexPath.row] valueForKey:@"link"];
    NSString *sFormattedUrl = [[sTopicUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", [k ForumURL]] withString:@""] stringByReplacingOccurrencesOfString:@"http://forum.hardware.fr" withString:@""];

    // set AQ as no more new
    [[marrXMLData objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:NO] forKey:@"is_new"];

    self.messagesTableViewController = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:sFormattedUrl displaySeparator:YES];;

    // Open topic
    // Sur iPhone
    if (([self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ||
        [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ||
        [[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"AQ" style: UIBarButtonItemStylePlain target:nil action:nil];
        [self.navigationController pushViewController:self.messagesTableViewController animated:YES];
    } else { //iPad
        [[[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:NO];
        
        [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] setViewControllers:[NSMutableArray arrayWithObjects:self.messagesTableViewController, nil] animated:YES];
        
        if ([messagesTableViewController.splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftBarButtonItem = messagesTableViewController.splitViewController.displayModeButtonItem;
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;
        }
    }
    
}

- (void)pushTopic {
    
    if (([self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ||
        [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ||
        [[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {
        
        self.navigationItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@" "
                                         style: UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        
        [self.navigationController pushViewController:messagesTableViewController animated:YES];
    }
    else {
        [[[[[HFRplusAppDelegate sharedAppDelegate] splitViewController] viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:NO];
        
        [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] setViewControllers:[NSMutableArray arrayWithObjects:messagesTableViewController, nil] animated:YES];
        
        if ([messagesTableViewController.splitViewController respondsToSelector:@selector(displayModeButtonItem)]) {
            NSLog(@"PUSH ADD BTN");
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftBarButtonItem = messagesTableViewController.splitViewController.displayModeButtonItem;
            [[HFRplusAppDelegate sharedAppDelegate] detailNavigationController].viewControllers[0].navigationItem.leftItemsSupplementBackButton = YES;
        }
        
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark -
#pragma mark RSS xml parsing

- (void)fetchContent
{
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelFetchContent)];;
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://alerte-qualitay.toyonos.info/"]];
    
    [request setDelegate:self];
    
    [request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentComplete:)];
    [request setDidFailSelector:@selector(fetchContentFailed:)];
    
    [request startAsynchronous];
}

// This method is used outside the controller in order to get some content regarding the AQs without any impact on the current AQTable HMI
- (void)fetchContentForNewAQ
{
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://alerte-qualitay.toyonos.info/"]];
    
    [request setDelegate:self];
    
    //[request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentCompleteForNewAQs:)];
    //[request setDidFailSelector:@selector(fetchContentFailed:)];
    
    [request startAsynchronous];
}

- (void)fetchContentCompleteForNewAQs:(ASIHTTPRequest *)theRequest
{
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:[theRequest responseData]];

    iNumberNewAQ = 0;

    [xmlparser setDelegate:self];
    [xmlparser parse];

    [self setBadgePlusTableView];
}

- (void) setBadgePlusTableView {
    // Set new AQ number into Plus tab
    PlusTableViewController* plusVC = ((PlusTableViewController *)((UINavigationController *)[[HFRplusAppDelegate sharedAppDelegate] rootController].viewControllers[3]).viewControllers[0]);
    plusVC.iAQBadgeNumer = (int)iNumberNewAQ;
    [plusVC.plusTableView reloadData];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];;
    
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:[theRequest responseData]];
    
    iNumberNewAQ = 0;
    
    [xmlparser setDelegate:self];
    [xmlparser parse];
    
    // Update current date as last check time for AQ
    [[NSUserDefaults standardUserDefaults] setObject:[[NSDate alloc] init] forKey:@"last_check_aq"];
    
    [self.aqTableView reloadData];
    
    [self.aqTableView.pullToRefreshView stopAnimating];
    [self.aqTableView.pullToRefreshView setLastUpdatedDate:[NSDate date]];
}
     
 - (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    [self.aqTableView.pullToRefreshView stopAnimating];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString     *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if ([elementName isEqualToString:@"rss"]) {
        marrXMLData = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"item"]) {
        mdictXMLPart = [[NSMutableDictionary alloc] init];
    }
}

- (void)cancelFetchContent
{
    [request cancel];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    if (!mstrXMLString) {
        mstrXMLString = [[NSMutableString alloc] initWithString:string];
    }
    else {
        [mstrXMLString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if ([elementName isEqualToString:@"title"]
        || [elementName isEqualToString:@"link"]) {
        NSString *value = [mstrXMLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [mdictXMLPart setObject:value forKey:elementName];
    }
    else if ([elementName isEqualToString:@"description"] && ![mstrXMLString containsString:@"Pour ne rien rater du meilleur d'HFR, en toutes circonstances"]) {
        NSString* sTopicTitle = [mstrXMLString stringByMatching:@".*Une qualitaÿ a été detectée sur <b>([^<]+).*" capture:1L];
        NSString* sNumber = [mstrXMLString stringByMatching:@".*Elle a été signalée <b>([^<]+).*" capture:1L];
        NSString* sInitiator = [mstrXMLString stringByMatching:@".*\\>([a-zA-Z\\s\\d]+) \\(initiateur\\).*" capture:1L];
        NSString* sComment = [mstrXMLString stringByMatching:@".*\\(initiateur\\)\\<\\/b\\>\\s:\\s([^<\\/>]+).*" capture:1L];
        if (sInitiator == nil || sComment == nil) {
            sInitiator = @"Parse error";
        }
        [mdictXMLPart setObject:sNumber forKey:@"number"];
        [mdictXMLPart setObject:sTopicTitle forKey:@"topic_title"];
        [mdictXMLPart setObject:sInitiator forKey:@"initiator"];
        [mdictXMLPart setObject:sComment forKey:@"comment"];
    } else if ([elementName isEqualToString:@"pubDate"]) {
        NSString *value = [mstrXMLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"E, d MMM yy HH:mm:ss Z"];
        NSDate *dNow = [[NSDate alloc] init];
        NSDate* dAQ = [df dateFromString:value];
        NSTimeInterval secondsBetween = [dNow timeIntervalSinceDate:dAQ];
        int numberHours = secondsBetween / 3600;
        int numberDays = secondsBetween / 24 / 3600;
        int numberMonths = numberDays / 31;
        int numberYears = numberMonths / 365;

        NSDate *dLastCheckAQ = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_check_aq"];
        if (!dLastCheckAQ) {
            // Default latest AQ date
            dLastCheckAQ = [df dateFromString:@"Tue, 1 JAN 2010 00:00:00 Z"];
        }
        
        if ([dAQ earlierDate:dLastCheckAQ] == dLastCheckAQ) {
            [mdictXMLPart setObject:[NSNumber numberWithBool:YES] forKey:@"is_new"];
            iNumberNewAQ++;
        } else {
            [mdictXMLPart setObject:[NSNumber numberWithBool:NO] forKey:@"is_new"];
        }

        NSString* sDateAQ = @"";
        if (numberHours == 0) {
            sDateAQ = @"il y a 1 h";
        } else if (numberHours <= 23) {
            sDateAQ = [NSString stringWithFormat:@"il y a %d h", numberHours];
        } else if (numberDays <= 30) {
            sDateAQ = [NSString stringWithFormat:@"il y a %d j", numberDays];
        } else if (numberMonths <= 12) {
            sDateAQ = [NSString stringWithFormat:@"il y a %d mois", numberMonths];
        } else {
            if (numberYears <= 1) {
                sDateAQ = @"il y a 1 an";
            } else{
                sDateAQ = [NSString stringWithFormat:@"il y a %d ans", numberYears ];
            }
        }
        
        [mdictXMLPart setObject:sDateAQ forKey:elementName];
    }
    if ([elementName isEqualToString:@"item"]) {
        [marrXMLData addObject:mdictXMLPart];
    }
    mstrXMLString = nil;
}

/*
 https://forum.hardware.fr/forum2.php?post=78667&cat=13&config=hfr.inc&cache=&page=1&sondage=0&owntopic=0&word=&spseudo=stukka&firstnum=55696838&currentnum=0&filter=1
 
 topicId=78667
 
 parameters: "alerte_qualitay_id=-1&nom=Sir%20Douglas%20Bader&topic_id=78667&topic_titre=Le%20topic%20des%20images%20%C3%A9tonnantes%20%5Bfaites%20pas%20l…"

 alerte_qualitay_id=-1: si on veut rattacher à une AQ existante
 nom= nom AQ en input
 topic_id= id du topic (url post=XXX)
 topic_titre= titre du topic
 postid=55696
 https://forum.hardware.fr/forum2.php?post=78667&cat=13&config=hfr.inc&cache=&page=1&sondage=0&owntopic=0&word=&spseudo=stukka&firstnum=55696…"
 
 Code d'erreur:
 case "1":
 newP.innerHTML = "Ce post a été signalé avec succès !";
 break;
 case "-2":
 newP.innerHTML = "L'alerte spécifiée est inexistante !";
 break;
 case "-3":
 newP.innerHTML = "Un ou plusieurs paramètres d'appel sont manquants !";
 break;
 case "-4":
 newP.innerHTML = "Vous avez déjà signalé cette qualitaÿ !";
 break;
 default:
 newP.innerHTML = "Une erreur imprévue est survenue durant la signalisation de ce post !";
 
http://alerte-qualitay.toyonos.info/api/addAlerte.php5?alerte_qualitay_id=-1&nom=test1&topic_id=61999&topic_titre=BashHFr&pseudo=roger21&post_id=55767559&post_url=https%3A%2F%2Fforum.hardware.fr%2Fforum2.php%3Fconfig%3Dhfr.inc%26cat%3D13%26subcat%3D432%26post%3D61999%26page%3D2681%26p%3D1%26sondage%3D0%26owntopic%3D1%26trash%3D0%26trash_post%3D0%26print%3D0%26numreponse%3D0%26quote_only%3D0%26new%3D0%26nojs%3D0%23t55767559&commentaire=test2
 */

@end


