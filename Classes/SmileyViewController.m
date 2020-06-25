//
//  SmileyViewController.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 09/06/2020.
//

#import "SmileyViewController.h"
#import "RehostCollectionCell.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "SmileyCache.h"
#import "AddMessageViewController.h"
#import "ASIHTTPRequest+Tools.h"
#import "HTMLParser.h"
#import "HFRAlertView.h"
#import "SimpleCellView.h"

@implementation SmileyViewController

@synthesize smileyCache, collectionSmileys, textFieldSmileys, btnSmileySearch, btnSmileyDefault, btnReduce, tableViewSearch;
@synthesize arrayTmpsmileySearch, dicTopSearch, dicLastSearch, usedSearchSortedArray, request, requestSmile, bModeFullScreen;

#pragma mark -
#pragma mark View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        self.smileyCache = [SmileyCache shared];
        self.title = @"Smileys";
        
        self.bModeFullScreen = NO;
        self.dicTopSearch = [[NSMutableDictionary alloc] init];
        self.dicLastSearch = [[NSMutableDictionary alloc] init];
        self.usedSearchSortedArray = [[NSMutableArray alloc] init];
        self.arrayTmpsmileySearch = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"Fermer" style:UIBarButtonItemStyleDone target:self action:@selector(closeView)];
    [self.navigationItem setRightBarButtonItem:closeItem];
    
     // Collection Smileys defaults
    [self.collectionSmileys setHidden:NO];
    self.collectionSmileys.backgroundColor = UIColor.whiteColor;

    [self.collectionSmileys registerClass:[SmileyCollectionCell class] forCellWithReuseIdentifier:@"SmileyCollectionCellId"];

    [self.collectionSmileys  setDataSource:self];
    [self.collectionSmileys  setDelegate:self];
    
    // Dic of search smileys
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *usedSmilieys = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:TOP_SMILEYS_FILE]];
    if ([fileManager fileExistsAtPath:usedSmilieys]) {
        self.usedSearchDict = [NSMutableDictionary dictionaryWithContentsOfFile:usedSmilieys];
        self.usedSearchSortedArray = (NSMutableArray *)[[self.usedSearchDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    if (self.usedSearchDict.count > 0) {
        self.usedSearchSortedArray = (NSMutableArray *)[[self.usedSearchDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }

    
    // TableView
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    v.backgroundColor = [ThemeColors addMessageBackgroundColor:[[ThemeManager sharedManager] theme]];
    [self.tableViewSearch setTableFooterView:v];
    //[self.tableViewSearch setHidden:YES];
    [self.tableViewSearch registerNib:[UINib nibWithNibName:@"SimpleCellView" bundle:nil] forCellReuseIdentifier:@"SimpleCellId"];

    
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.backgroundColor = [UIColor whiteColor];

    Theme theme = [[ThemeManager sharedManager] theme];
    [self.btnSmileySearch  setImage:[ThemeColors tintImage:[UIImage imageNamed:@"redface"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnSmileySearch setImage:[ThemeColors tintImage:[UIImage imageNamed:@"redface"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnSmileySearch setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [self.btnSmileyDefault  setImage:[ThemeColors tintImage:[UIImage imageNamed:@"smiley"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnSmileyDefault setImage:[ThemeColors tintImage:[UIImage imageNamed:@"smiley"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnSmileyDefault setImageEdgeInsets:UIEdgeInsetsMake(7, 12, 7, 12)];
    //Image(systemName: "rectangle.expand.vertical").font(.system(size: 16, weight: .medium))
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"rectangle.expand"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"rectangle.expand"] withTheme:theme] forState:UIControlStateHighlighted];
    //[self.btnReduce setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];

    [self.btnSmileyDefault addTarget:self action:@selector(actionSmileysDefaults:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnReduce addTarget:self action:@selector(actionReduce:) forControlEvents:UIControlEventTouchUpInside];

    self.tableViewSearch.backgroundColor = [ThemeColors addMessageBackgroundColor:[[ThemeManager sharedManager] theme]];
    [self.tableViewSearch reloadData];
    [self.tableViewSearch setAlpha:0];

    [[ThemeManager sharedManager] applyThemeToTextField:self.textFieldSmileys];
    self.textFieldSmileys.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
    self.textFieldSmileys.returnKeyType = UIReturnKeyDone;
    
    [self.spinnerSmileySearch setHidesWhenStopped:YES];

    // Default view displayed at startup
    [self changeDisplayMode:DisplayModeEnumSmileysDefault animate:NO];
}

- (void) changeDisplayMode:(DisplayModeEnum)newMode animate:(BOOL)bAnimate
{
    if (bAnimate) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
    }
    
    if (newMode == self.displayMode) {
        return;
    }
    
    switch (newMode) {
        case DisplayModeEnumSmileysDefault:
            [self.collectionSmileys setAlpha:1];
            [self.tableViewSearch setAlpha:0];
            [self.textFieldSmileys resignFirstResponder];
            break;
        case DisplayModeEnumSmileysSearch:
            NSLog(@"56 Display collection");

            [self.collectionSmileys setAlpha:1];
            [self.tableViewSearch setAlpha:0];
            [self.collectionSmileys reloadData];
            [self.textFieldSmileys resignFirstResponder];
            break;
        case DisplayModeEnumTableSearch:
            [self.collectionSmileys setAlpha:0];
            [self.tableViewSearch reloadData];
            [self.tableViewSearch setAlpha:1];
            break;

        default:
            break;
    }
    
    if (bAnimate) {
        [UIView commitAnimations];
    }
    self.displayMode = newMode;
}

#pragma mark - Collection management

static CGFloat fCellSize = 0.7;
static CGFloat fCellImageSize = 1;

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionSmileys) {
        CGRect f = self.collectionSmileys.frame;
        SmileyCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SmileyCollectionCellId" forIndexPath:indexPath];
        UIImage* image = nil;//[UIImage imageNamed:@"19-gear"];
        if (!self.smileyCache.bSearchSmileysActivated || self.displayMode == DisplayModeEnumSmileysDefault) {
             // Default smileys
            image = [UIImage imageNamed:self.smileyCache.dicCommonSmileys[indexPath.row][@"resource"]];
        }
        else {
            UIImage* tmpImage = [self.smileyCache getImageForIndex:(int)indexPath.row];
            if (tmpImage != nil) {
                image = tmpImage;
            }
        }
        
        CGFloat ch = cell.bounds.size.height;
        CGFloat cw = cell.bounds.size.width;
        CGFloat w = image.size.width*fCellImageSize;
        CGFloat h = image.size.height*fCellImageSize;
        
        if (cell.smileyImage == nil) {
            cell.smileyImage = [[UIImageView alloc] initWithFrame:CGRectMake(cw/2-w/2, ch/2-h/2, w, h)];
            [cell addSubview:cell.smileyImage];
        }
        else {
            cell.smileyImage.frame = CGRectMake(cw/2-w/2, ch/2-h/2, w, h);
        }
        [cell.smileyImage setImage:image];

        cell.smileyImage.clipsToBounds = NO;
        cell.smileyImage.layer.masksToBounds = true;
        cell.layer.borderColor = [ThemeColors cellBorderColor].CGColor;
        cell.layer.backgroundColor = [UIColor whiteColor].CGColor;
        cell.layer.borderWidth = 1.0f;
        cell.layer.cornerRadius = 3;
        cell.layer.masksToBounds = true;
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SmileyCollectionCell *cell = (SmileyCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (!self.smileyCache.bSearchSmileysActivated) {
        NSString* sCode = self.smileyCache.dicCommonSmileys[indexPath.row][@"code"];
        [self didSelectSmile:sCode];
    }
    else {
        NSString* sCode = [self.smileyCache getSmileyCodeForIndex:(int)indexPath.row];
        [self didSelectSmile:sCode];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!self.smileyCache.bSearchSmileysActivated) {
        return self.smileyCache.dicCommonSmileys.count;
    }
    else {
        return self.smileyCache.arrCurrentSmileyArray.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(70*fCellSize, 50*fCellSize);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0;
}

#pragma mark - Table view management

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Recherches les plus fréquentes";
            break;
        case 1:
            return @"Dernières recherches";
            break;
        default:
            return @"Recherches les plus fréquentes";
            break;
    }
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewSearch) {
        NSLog(@"table rect: %@", NSStringFromCGRect(self.tableViewSearch.frame));
        SimpleCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCellId"];
        int iResults = 0;
        switch (indexPath.row) {
            case 0:
                cell.labelText.text = @"chance";
                iResults = 35;
                break;
            case 1:
                cell.labelText.text = @"love";
                iResults = 935;
                break;
            case 2:
                cell.labelText.text = @"sadfrog";
                iResults = 148;
                break;
        }
        
        // Format badge
        if (iResults > 0) {
            cell.labelBadge.text = [NSString stringWithFormat:@"%d", iResults];
            UIColor* c = [ThemeColors tintColorWithAlpha:0.5];
            cell.labelBadge.backgroundColor = [ThemeColors tintColorWithAlpha:0.2];
            cell.labelBadge.textColor = [ThemeColors tintColorWithAlpha:1];// [UIColor whiteColor];
            cell.labelBadge.clipsToBounds = YES;
            NSLog(@"Rect: %@", NSStringFromCGRect(cell.labelBadge.frame));
            cell.labelBadge.layer.cornerRadius = cell.labelBadge.frame.size.height / 2;
        } else {
            cell.labelBadge.backgroundColor = [UIColor clearColor];
            cell.labelBadge.textColor = [UIColor clearColor];
            cell.labelBadge.text = @"";
        }

        cell.backgroundColor = [UIColor systemPinkColor];
        //[[ThemeManager sharedManager] applyThemeToCell:cell];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;

    header.textLabel.font = [UIFont boldSystemFontOfSize:13];
    /*CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;*/
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewSearch) {
        self.textFieldSmileys.text = @"sadfrog"; //[self.usedSearchSortedArray objectAtIndex:indexPath.row];
        [self textFieldShouldReturn:self.textFieldSmileys];
        [self.tableViewSearch deselectRowAtIndexPath:self.tableViewSearch.indexPathForSelectedRow animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: implement search deletion
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    if (bModeFullScreen) {
        NSLog(@"SMILEYS :::: Keyboard will show");

        NSDictionary *userInfo = [notification userInfo];
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect convertedKeyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];

        CGRect safeAreaFrame = CGRectInset(self.view.safeAreaLayoutGuide.layoutFrame, 0, -self.additionalSafeAreaInsets.bottom);
        CGRect intersection = CGRectIntersection(safeAreaFrame, convertedKeyboardRect);

        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];

        // Animate the resize of the text view's frame in sync with the keyboard's appearance.
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
        [self.view layoutIfNeeded];
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //NSLog(@"keyboardWillHide ADD");
    NSLog(@"SMILEYS :::: Keyboard will hide");
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];

    CGRect safeAreaFrame = CGRectInset(self.view.safeAreaLayoutGuide.layoutFrame, 0, -self.additionalSafeAreaInsets.bottom);
    CGRect intersection = CGRectIntersection(safeAreaFrame, convertedKeyboardRect);

    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
    [self.view layoutIfNeeded];
    [UIView commitAnimations];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.textFieldSmileys) {
        [self changeDisplayMode:DisplayModeEnumTableSearch animate:YES];
        /*
         if (self.usedSearchDict.count > 0) {
             [self textFieldSmileChange:self.textFieldSmileys]; //on affiche les recherches
             [self.tableViewSearch reloadData];
             
             [UIView beginAnimations:nil context:nil];
             [UIView setAnimationDuration:0.2];
             [self.tableViewSearch setHidden:NO];
             [UIView commitAnimations];
         }
         
        /*
         if (self.bSearchSmileysAvailable) {
             self.bSearchSmileysActivated = YES;
             [self.collectionSmileys reloadData];
             [self.collectionSmileys setHidden:NO];
             [btnCollectionSmileysEnlarge setHidden:NO];
             [btnCollectionSmileysClose setHidden:NO];
         }*/

     }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.textFieldSmileys) {
        if (self.textFieldSmileys.text.length < 3) {
            /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Saisir 3 caractères minimum !"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];*/
        }
        else {
            [self.spinnerSmileySearch startAnimating];
            [self performSelectorInBackground:@selector(fetchSmileys) withObject:nil];
        }
    }
    return NO;
    
}
/*- (BOOL)textFieldShouldClear:(UITextField *)textField
 {
    NSLog(@"textFieldShouldClear %@", textField.text);
 
    
    return YES;
 
 }*/

-(IBAction)textFieldSmileChange:(id)sender
{
    
    if ([(UITextField *)sender text].length > 0) {
        NSString* sText = [(UITextField *)sender text];
        sText = [sText stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        sText = [sText stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        @try {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF contains[c] '%@'", sText]];
            self.usedSearchSortedArray = (NSMutableArray *)[[self.usedSearchDict allKeys] filteredArrayUsingPredicate:predicate];
            [self.tableViewSearch reloadData];
        }
        @catch (NSException* exception) {
            NSLog(@"exception %@", exception);
            [HFRAlertView DisplayOKAlertViewWithTitle:@"Erreur de saisie !" andMessage:[NSString stringWithFormat:@"%@", [exception reason]]];
            [(UITextField *)sender setText:@""];
        }
        //NSLog(@"usedSearchSortedArray %@", usedSearchSortedArray);
    }
    else {
        self.usedSearchSortedArray = (NSMutableArray *)[[self.usedSearchDict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [self.tableViewSearch reloadData];
        //NSLog(@"usedSearchSortedArray %@", usedSearchSortedArray);
    }
    /*
    if (self.usedSearchSortedArray.count == 0) {
        [self.tableViewSearch setHidden:YES];
    }
    else {
        [self.tableViewSearch setHidden:NO];
    }*/
}

#pragma mark - Data lifecycle

- (void)fetchSmileys
{
    // Stop loading smileys of previous request
    [[SmileyCache shared] setBStopLoadingSmileysToCache:YES];

    NSString *sTextSmileys = [NSString stringWithFormat:@"+%@", [[self.textFieldSmileys.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@" +"]];
    NSMutableArray* smileyList = [[SmileyCache shared] getSmileyListForText:sTextSmileys];
    if (smileyList) {
        self.arrayTmpsmileySearch = smileyList;
        [self performSelectorInBackground:@selector(loadSmileys) withObject:nil];
    }
    else {
        [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
        NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                         NULL,
                                                                                                         (CFStringRef)sTextSmileys,
                                                                                                         NULL,
                                                                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                         kCFStringEncodingUTF8 ));
        
        [self setRequestSmile:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/message-smi-mp-aj.php?config=hfr.inc&findsmilies=%@", [k ForumURL], encodedString]]]];
        [requestSmile setDelegate:self];
        [requestSmile setDidStartSelector:@selector(fetchSmileContentStarted:)];
        [requestSmile setDidFinishSelector:@selector(fetchSmileContentComplete:)];
        [requestSmile setDidFailSelector:@selector(fetchSmileContentFailed:)];
        [requestSmile startAsynchronous];
    }
}

- (void)fetchSmileContentStarted:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchSmileContentStarted %@", theRequest);
}

- (void)fetchSmileContentComplete:(ASIHTTPRequest *)theRequest
{
    NSLog(@"fetchSmileContentComplete %@", theRequest);
    //Traitement des smileys (to Array)
    [self.arrayTmpsmileySearch removeAllObjects]; //RaZ

    /*
    [self.segmentControlerPage setTitle:@"Smilies" forSegmentAtIndex:1];*/
    
    //NSDate *thenT = [NSDate date]; // Create a current date
    
    HTMLParser * myParser = [[HTMLParser alloc] initWithString:[theRequest safeResponseString] error:NULL];
    HTMLNode * smileNode = [myParser doc]; //Find the body tag
    NSArray * tmpImageArray =  [smileNode findChildTags:@"img"];
    for (HTMLNode * imgNode in tmpImageArray) { //Loop through all the tags
        [self.arrayTmpsmileySearch addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[imgNode getAttributeNamed:@"src"], [imgNode getAttributeNamed:@"alt"], nil] forKeys:[NSArray arrayWithObjects:@"source", @"code", nil]]];
    }

    if (self.arrayTmpsmileySearch.count == 0) {
        [HFRAlertView DisplayOKAlertViewWithTitle:nil andMessage:@"Aucun résultat !"];
        return;
    }
    
    [self performSelectorOnMainThread:@selector(displaySmileys) withObject:nil waitUntilDone:YES];
    [self performSelectorInBackground:@selector(loadSmileys) withObject:nil];
}

- (void) displaySmileys {
    [self.collectionSmileys reloadData];
    [self changeDisplayMode:DisplayModeEnumSmileysSearch animate:NO];
}

- (void) loadSmileys {
    [[SmileyCache shared] handleSmileyArray:self.arrayTmpsmileySearch forCollection:self.collectionSmileys];
}

- (void)fetchSmileContentFailed:(ASIHTTPRequest *)theRequest
{
    [self.spinnerSmileySearch stopAnimating];
    [self cancelFetchContent];
}

- (void)cancelFetchContent
{
    [self.request cancel];
    [self setRequest:nil];
    
}

#pragma mark - Action events

- (void) didSelectSmile:(NSString *)smile
{
    if (self.textFieldSmileys.text.length >= 3) {
        NSNumber *val;
        if ((val = [self.dicTopSearch valueForKey:self.textFieldSmileys.text])) {
            [self.dicTopSearch setObject:[NSNumber numberWithInt:[val intValue]+1] forKey:self.textFieldSmileys.text];
        }
        else {
            [self.dicTopSearch setObject:[NSNumber numberWithInt:1] forKey:self.textFieldSmileys.text];
        }
        
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *usedSmilieys = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:TOP_SMILEYS_FILE]];
        
        [self.dicTopSearch writeToFile:usedSmilieys atomically:YES];
    }

    
    smile = [NSString stringWithFormat:@" %@ ", smile]; // ajout des espaces avant/aprés le smiley.

    // Update main textField
    AddMessageViewController* vcAddMessage = (AddMessageViewController*)self.parentViewController;
    NSRange range = [vcAddMessage lastSelectedRange];
    if ([vcAddMessage.textView isFirstResponder]) {
        range = vcAddMessage.textView.selectedRange;
    }
    if (!range.location) {
        range = NSMakeRange(0, 0);
    }
    NSMutableString *text = [vcAddMessage.textView.text mutableCopy];
    if (text.length < range.location) {
        range.location = text.length;
    }
    [text insertString:smile atIndex:range.location];
    range.location += [smile length];
    range.length = 0;
    [vcAddMessage setLastSelectedRange:range];
    vcAddMessage.textView.text = text;
    vcAddMessage.textView.selectedRange = range;
    [vcAddMessage textViewDidChange:vcAddMessage.textView];
    
    if (self.bModeFullScreen) {
        [self.addMessageVC actionHideSmileys];
    }
}

- (void)actionReduce:(id)sender {
    [self.addMessageVC actionExpandCompressSmiley];
    NSString* sImageName = @"rectangle.expand";
    if (self.bModeFullScreen) {
        sImageName = @"rectangle.compress";
    }
    Theme theme = [[ThemeManager sharedManager] theme];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:sImageName] withTheme:theme] forState:UIControlStateNormal];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:sImageName] withTheme:theme] forState:UIControlStateHighlighted];

}

- (void)actionSmileysDefaults:(id)sender {
    [self changeDisplayMode:DisplayModeEnumSmileysDefault animate:NO];
}


@end
