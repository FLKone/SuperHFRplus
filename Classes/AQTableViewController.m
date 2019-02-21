//
//  AQTableViewController.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 02/02/2019.
//

#import <Foundation/Foundation.h>
#import "AQTableViewController.h"
#import "MessagesTableViewController.h"
#import "AQCellView.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "ThemeManager.h"
#import "ThemeColors.h"

@implementation AQTableViewController;
@synthesize aqTableView; //, arrayData;
@synthesize marrXMLData;
@synthesize mstrXMLString;
@synthesize mdictXMLPart;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"AQCellView" bundle:nil];
    [self.aqTableView registerNib:nib forCellReuseIdentifier:@"AQCellViewId"];
    
    self.title = @"Alertes Qualitay";
    self.navigationController.navigationBar.translucent = NO;
    //Supprime les lignes vides à la fin de la liste
    self.aqTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self fetchContent];
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

    NSDate *dNow = [[NSDate alloc] init];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"E, d MMM yy HH:mm:ss Z"];
    NSDate* dAQ = [df dateFromString:sAqPubDate];
    NSTimeInterval secondsBetween = [dNow timeIntervalSinceDate:dAQ];
    int numberDays = secondsBetween / 24 / 3600;
    int numberMonths = numberDays / 31;
    NSString* sAqFormatedPubDate = @"";
    if (numberDays == 0) {
        sAqFormatedPubDate = [NSString stringWithFormat:@"par %@ aujourd'hui", sInitiator];
    } else if (numberDays <= 30) {
        sAqFormatedPubDate = [NSString stringWithFormat:@"par %@ il y a %d jours", sInitiator, numberDays];
    } else if (numberMonths <= 12) {
        sAqFormatedPubDate = [NSString stringWithFormat:@"par %@ il y a %d mois", sInitiator, numberMonths];
    } else {
        sAqFormatedPubDate = [NSString stringWithFormat:@"par %@ il y a plus d'un an", sInitiator ];
    }

    cell.labelTitleTopic.text = sTopicTitle;
    cell.labelTitleAQ.text = sAqNom;
    cell.labelTime.text = sAqFormatedPubDate;
    
    [cell.labelTitleTopic setTextColor:[ThemeColors textColor]];
    [cell.labelTitleAQ setTextColor:[ThemeColors topicMsgTextColor]];
    [cell.labelTime setTextColor:[ThemeColors tintColor]];

    return cell;
}
/*
-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    // Background color of topic cells in favorite list
    if (self.isSuperFavorite)
    {
        self.contentView.superview.backgroundColor = [ThemeColors cellBackgroundColorSuperFavorite:theme];
    }
    else
    {
        self.contentView.superview.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    }
    [self.labelTitle setTextColor:[ThemeColors textColor:theme]];
    [self.labelMsg setTextColor:[ThemeColors topicMsgTextColor:theme]];
    [self.labelDate setTextColor:[ThemeColors cellTintColor:theme]];
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)fetchContent
{
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://alerte-qualitay.toyonos.info/"]];
    
    [request setDelegate:self];
    
    [request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentComplete:)];
    [request setDidFailSelector:@selector(fetchContentFailed:)];
    
    [request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentStarted");
    
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentComplete");
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:[theRequest responseData]];
    [xmlparser setDelegate:self];
    [xmlparser parse];
    
    [self.aqTableView reloadData];
}
     
 - (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchContentFailed");
    
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
        || [elementName isEqualToString:@"pubDate"]
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
    }
    if ([elementName isEqualToString:@"item"]) {
        [marrXMLData addObject:mdictXMLPart];
    }
    mstrXMLString = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sTopicUrl = [[marrXMLData objectAtIndex:indexPath.row] valueForKey:@"link"];
    NSString *sFormattedUrl = [[sTopicUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", [k ForumURL]] withString:@""] stringByReplacingOccurrencesOfString:@"http://forum.hardware.fr" withString:@""];
    
    MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:sFormattedUrl displaySeparator:YES];
    self.messagesTableViewController = aView;
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"AQ"
                                     style: UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    [self.navigationController pushViewController:self.messagesTableViewController animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = self.aqTableView.backgroundColor = [ThemeColors greyBackgroundColor];
    self.aqTableView.separatorColor = [ThemeColors cellBorderColor];
    if (self.aqTableView.indexPathForSelectedRow) {
        [self.aqTableView deselectRowAtIndexPath:self.aqTableView.indexPathForSelectedRow animated:NO];
    }
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
 */

@end


