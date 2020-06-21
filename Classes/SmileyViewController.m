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
@synthesize smileyArray, usedSearchDict, usedSearchSortedArray, request, requestSmile, bModeFullScreen;

#pragma mark -
#pragma mark View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        self.smileyCache = [SmileyCache shared];
        self.title = @"Smileys";
        
        self.bModeFullScreen = YES;
        self.usedSearchDict = [[NSMutableDictionary alloc] init];
        self.usedSearchSortedArray = [[NSMutableArray alloc] init];
        self.smileyArray = [[NSMutableArray alloc] init];
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
    NSString *usedSmilieys = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:USED_SMILEYS_FILE]];
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
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"fullscreen"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"fullscreen"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnReduce setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];

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
            cell.smileyCode = self.smileyCache.dicCommonSmileys[indexPath.row][@"code"];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.collectionSmileys) {
        SmileyCollectionCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (!self.smileyCache.bSearchSmileysActivated) {
            //[self.smileyCache didSelectSmile:cell.smileyCode];
        }
        else {
            //[self didSelectSmile:@"totoz"];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionSmileys) {
        if (!self.smileyCache.bSearchSmileysActivated) {
            return self.smileyCache.dicCommonSmileys.count;
        }
        else {
            return self.smileyArray.count;
        }
    }
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.collectionSmileys) {
        //return CGSizeMake(w, 50);
        return CGSizeMake(70*fCellSize, 50*fCellSize);
    }
    return CGSizeMake(60, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.collectionSmileys) {
        return UIEdgeInsetsMake(2, 2, 0, 0);
    }
    else {
        return UIEdgeInsetsMake(0, 2, 0, 0);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.collectionSmileys) {
        return 1.0;
    }
    else {
        return 1.0;
    }
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
    //NSLog(@"keyboardWillShow ADD %@", notification);

    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];

    CGRect safeAreaFrame = CGRectInset(self.view.safeAreaLayoutGuide.layoutFrame, 0, -self.additionalSafeAreaInsets.bottom);
    CGRect intersection = CGRectIntersection(safeAreaFrame, convertedKeyboardRect);

//    self.bottomGuide.constant = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardRect);
  //  [self.accessoryView setNeedsUpdateConstraints];

    //NSLog(@"Bottom Constant %@", NSStringFromCGRect(intersection));

    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
    [self.view layoutIfNeeded];
    //[self.accessoryView updateConstraintsIfNeeded];

    [UIView commitAnimations];

}

- (void)keyboardWillHide:(NSNotification *)notification {
    //NSLog(@"keyboardWillHide ADD");
    
    [self keyboardWillShow:notification];

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
        self.smileyArray = smileyList;
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
    [self.smileyArray removeAllObjects]; //RaZ

    /*
    [self.segmentControlerPage setTitle:@"Smilies" forSegmentAtIndex:1];*/
    
    //NSDate *thenT = [NSDate date]; // Create a current date
    
    HTMLParser * myParser = [[HTMLParser alloc] initWithString:[theRequest safeResponseString] error:NULL];
    HTMLNode * smileNode = [myParser doc]; //Find the body tag
    NSArray * tmpImageArray =  [smileNode findChildTags:@"img"];
    for (HTMLNode * imgNode in tmpImageArray) { //Loop through all the tags
        [self.smileyArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[imgNode getAttributeNamed:@"src"], [imgNode getAttributeNamed:@"alt"], nil] forKeys:[NSArray arrayWithObjects:@"source", @"code", nil]]];
    }

    if (self.smileyArray.count == 0) {
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
    [[SmileyCache shared] handleSmileyArray:self.smileyArray forCollection:self.collectionSmileys];
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

/*
-(void)loadSmileys;
{
    @autoreleasepool {
        
        [[SmileyCache shared] handleSmileyArray:self.smileyArray forCollection:self.collectionSmileys];
        /*
        int page = self.smileyPage;
        
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"SmileCache"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
        {
            //NSLog(@"createDirectoryAtPath");
            [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
        else {
            //NSLog(@"pas createDirectoryAtPath");
        }
        
        int doubleSmileys = 1;
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_smileys"] isEqualToString:@"double"]) {
            doubleSmileys = 2;
        }
        
        int smilePerPage = 40/doubleSmileys;
        float surface = [UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].bounds.size.width;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (surface > 250000) {
                smilePerPage = roundf(55/doubleSmileys);
            }
            else if (surface > 180000) {
                smilePerPage = roundf(45/doubleSmileys);
            }
        }
        
        
        //NSLog(@"SMILEYS %f = %d", surface, smilePerPage);
        
        //i4 153600
        //i5 181760
        //i6 250125
        NSArray *localsmileyArray = [[NSArray alloc] initWithArray:self.smileyArray copyItems:true];
        
        
        int firstSmile = page * smilePerPage;
        int lastSmile = MIN([localsmileyArray count], (page + 1) * smilePerPage);
        //NSLog(@"%d to %d", firstSmile, lastSmile);
        
        int i;
        
        NSString *tmpHTML = @"";
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        
        for (i = firstSmile; i < lastSmile; i++) { //Loop through all the tags
            NSString *filename = [[[localsmileyArray objectAtIndex:i] objectForKey:@"source"] stringByReplacingOccurrencesOfString:@"http://forum-images.hardware.fr/" withString:@""];
            filename = [filename stringByReplacingOccurrencesOfString:@"https://forum-images.hardware.fr/" withString:@""];
            filename = [filename stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            filename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"-"];
            
            NSString *key = [diskCachePath stringByAppendingPathComponent:filename];
            
            //NSLog(@"url %@", [[self.smileyArray objectAtIndex:i] objectForKey:@"source"]);
            //NSLog(@"key %@", key);
            
            if (![fileManager fileExistsAtPath:key])
            {
                //NSLog(@"dl %@", key);
                
                [fileManager createFileAtPath:key contents:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[[localsmileyArray objectAtIndex:i] objectForKey:@"source"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]]] attributes:nil];
            }
            
            
            tmpHTML = [tmpHTML stringByAppendingString:[NSString stringWithFormat:@"<img class=\"smile\" src=\"%@\" alt=\"%@\"/>", key, [[localsmileyArray objectAtIndex:i] objectForKey:@"code"]]];
            
        }
        
        
        tmpHTML = [tmpHTML stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        
        [self performSelectorOnMainThread:@selector(showSmileResults:) withObject:tmpHTML waitUntilDone:YES];
        
        //Pagination
        //if (firstSmile > 0 || lastSmile < [self.smileyArray count]) {
        //NSLog(@"pagination needed");
        *
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.segmentControler setAlpha:0];
            /*[self.btnToolbarImage setHidden:NO];
            [self.btnToolbarGIF setHidden:NO];
            [self.btnToolbarSmiley setHidden:NO];
            [self.btnToolbarUndo setHidden:NO];
            [self.btnToolbarRedo setHidden:NO];*/
            /*
            [btnCollectionSmileysEnlarge setHidden:NO];
            [btnCollectionSmileysClose setHidden:NO];
*/
/*
            [self.segmentControlerPage setAlpha:1];

            if (firstSmile > 0) {
                    [self.segmentControlerPage setEnabled:YES forSegmentAtIndex:0];
            }
            else {
                [self.segmentControlerPage setEnabled:NO forSegmentAtIndex:0];
            }
            
            if (lastSmile < [localsmileyArray count]) {
                [self.segmentControlerPage setEnabled:YES forSegmentAtIndex:2];
            }
            else {
                [self.segmentControlerPage setEnabled:NO forSegmentAtIndex:2];
            }*
        });
        
        //}
        
        
    }
}*/

#pragma mark - Action events

- (void) didSelectSmile:(NSString *)smile
{
    smile = [NSString stringWithFormat:@" %@ ", smile]; // ajout des espaces avant/aprés le smiley.

    // Update smiley used
    if (self.textFieldSmileys.text.length >= 3) {
        NSNumber *val;
        if ((val = [self.usedSearchDict valueForKey:self.textFieldSmileys.text])) {
            //NSLog(@"existe %@", val);
            [self.usedSearchDict setObject:[NSNumber numberWithInt:[val intValue]+1] forKey:self.textFieldSmileys.text];
        }
        else {
            //NSLog(@"nouveau");
            [self.usedSearchDict setObject:[NSNumber numberWithInt:1] forKey:self.textFieldSmileys.text];
            
        }
        
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *usedSmilieys = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:USED_SMILEYS_FILE]];
        [self.usedSearchDict writeToFile:usedSmilieys atomically:YES];
    }
    
    /*
    NSString *jsString = @"";
    jsString = [jsString stringByAppendingString:@"$(\".selected\").each(function (i) {\
                $(this).delay(800).removeClass('selected');\
                });"];
    
    [self.smileView evaluateJavaScript:jsString completionHandler:nil];
    [self cancel];*/
}

- (IBAction)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionReduce:(id)sender {
    [self.addMessageVC actionMaximizeSmiley];
    /*
    self.bModeFullScreen = NO;
    [self dismissViewControllerAnimated:NO completion:^{
        [self.addMessageVC showPanelSmiley:YES reloadData:YES];
        [self.addMessageVC.textView becomeFirstResponder];
    }];*/
}

- (void)actionSmileysDefaults:(id)sender {
    [self changeDisplayMode:DisplayModeEnumSmileysDefault animate:NO];
}


@end
