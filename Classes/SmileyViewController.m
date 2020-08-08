//
//  SmileyViewController.m
//  SuperHFRplus
//
//  Created by ezzz on 09/06/2020.
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
#import "UILabel+Boldify.h"

#if !defined(MIN)
    #define MIN(A,B)    ((A) < (B) ? (A) : (B))
#endif

@implementation SmileySearch
@synthesize sSearchText, nSearchNumber, nSmileysResultNumber, dLastSearch;
@end

@implementation SmileyViewController

@synthesize smileyCache, collectionSmileys, textFieldSmileys, btnSmileySearch, btnSmileyDefault, btnReduce, tableViewSearch;
@synthesize arrayTmpsmileySearch, arrSearch, arrTopSearchSorted, arrLastSearchSorted, arrTopSearchSortedFiltered, arrLastSearchSortedFiltered, request, requestSmile, bModeFullScreen, bActivateSmileySearchTable;

#pragma mark -
#pragma mark View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        self.smileyCache = [SmileyCache shared];
        self.title = @"Smileys";
        
        self.bModeFullScreen = NO;
        self.bActivateSmileySearchTable = NO;

        self.arrSearch = [[NSMutableArray alloc] init];
        self.arrTopSearchSorted = [[NSMutableArray alloc] init];
        self.arrLastSearchSorted = [[NSMutableArray alloc] init];
        self.arrTopSearchSortedFiltered = [[NSMutableArray alloc] init];
        self.arrLastSearchSortedFiltered = [[NSMutableArray alloc] init];
        
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
    NSString *searchFile = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:SEARCH_SMILEYS_FILE]];
    /* TODO: uncomment
     if ([fileManager fileExistsAtPath:directory]) {
        self.arrSearch = [NSMutableArray arrayWithContentsOfFile:searchFile];
    }
    else {*/
    SmileySearch* ss = [[SmileySearch alloc] init];
    ss.nSearchNumber = [NSNumber numberWithInt:4];
    ss.dLastSearch = [NSDate dateWithTimeIntervalSince1970:0];
    ss.sSearchText = @"rien";
    SmileySearch* ss1 = [[SmileySearch alloc] init];
    ss1.nSearchNumber = [NSNumber numberWithInt:3];
    ss1.dLastSearch = [NSDate dateWithTimeIntervalSince1970:10];
    ss1.sSearchText = @"sadfog";
    SmileySearch* ss2 = [[SmileySearch alloc] init];
    ss2.nSearchNumber = [NSNumber numberWithInt:2];
    ss2.dLastSearch = [NSDate dateWithTimeIntervalSince1970:20];
    ss2.sSearchText = @"love";
    SmileySearch* ss3 = [[SmileySearch alloc] init];
    ss3.nSearchNumber = [NSNumber numberWithInt:1];
    ss3.dLastSearch = [NSDate dateWithTimeIntervalSince1970:30];
    ss3.sSearchText = @"chance";
    [self.arrSearch addObject:ss];
    [self.arrSearch addObject:ss1];
    [self.arrSearch addObject:ss2];
    [self.arrSearch addObject:ss3];
        
    [self updateSearchArraySorted];

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
    self.textFieldSmileys.returnKeyType = UIReturnKeySearch;
    [self.textFieldSmileys addTarget:self action:@selector(actionSmileysSearch:) forControlEvents:UIControlEventPrimaryActionTriggered];

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
            [self.collectionSmileys reloadData];
            break;
        case DisplayModeEnumSmileysSearch:
            [self.collectionSmileys setAlpha:1];
            [self.tableViewSearch setAlpha:0];
            [self.collectionSmileys reloadData];
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

static CGFloat fCellSizeDefault = 0.7*0.85;
static CGFloat fCellSizeSearch = 1*0.85;
static CGFloat fCellImageSize = 1;

- (BOOL) displayCollectionSmileysDefault
{
    return (!self.smileyCache.bSearchSmileysActivated || self.displayMode == DisplayModeEnumSmileysDefault);
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        if (collectionView == self.collectionSmileys) {
            //CGRect f = self.collectionSmileys.frame;
            SmileyCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SmileyCollectionCellId" forIndexPath:indexPath];
            UIImage* image = nil;//[UIImage imageNamed:@"19-gear"];
            if ([self displayCollectionSmileysDefault]) {
                // Default smileys
                image = [self.smileyCache getImageDefaultSmileyForIndex:(int)indexPath.row];
            }
            else {
                image = [self.smileyCache getImageForIndex:(int)indexPath.row];
            }

            CGFloat ch = cell.bounds.size.height;
            CGFloat cw = cell.bounds.size.width;
            CGFloat w = image.scale*image.size.width*fCellImageSize;
            CGFloat h = image.scale*image.size.height*fCellImageSize;
            
            if (cell.smileyImage == nil) {
                cell.smileyImage = [[UIImageView alloc] initWithFrame:CGRectMake(cw/2-w/2, ch/2-h/2, w, h)];
                [cell addSubview:cell.smileyImage];
            }
            else {
                cell.smileyImage.frame = CGRectMake(cw/2-w/2, ch/2-h/2, w, h);
            }

            NSLog(@"row %d - %@", (int)indexPath.row, NSStringFromCGRect(CGRectMake(cw/2-w/2, ch/2-h/2, w, h)));

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
    @catch (NSException * e) {
        NSLog(@"ERROR, empty cell for section %d / row %d", (int)indexPath.section, (int)indexPath.row);
    }

    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self displayCollectionSmileysDefault]) {
        // Default smileys
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
    if ([self displayCollectionSmileysDefault]) {
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
    if ([self displayCollectionSmileysDefault]) {
        return CGSizeMake(70*fCellSizeDefault, 50*fCellSizeDefault);
    }
    else {
        return CGSizeMake(70*fCellSizeSearch, 50*fCellSizeSearch);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 2, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0;
}

/*
 UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
 flowLayout.itemSize = CGSizeMake(180, 255);
 flowLayout.sectionInset = UIEdgeInsetsMake(10, 30, 0, 30);
 flowLayout.minimumInteritemSpacing = 0.0f;
 flowLayout.minimumLineSpacing = 0.0f;
 flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
 return flowLayout;
 */

- (float) getDisplayHeight {
    /*if (!self.smileyCache.bSearchSmileysActivated || self.displayMode == DisplayModeEnumSmileysDefault) {
        return 150 * fCellSizeDefault;
    }*/
    return 150 * 0.85;
}

#pragma mark - Table view management

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return MIN(3, self.arrLastSearchSorted.count); // Maximum 3 Last search
    } else {
        return MIN(10, self.arrTopSearchSortedFiltered.count);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Dernières recherches";
    } else {
        return @"Recherches les plus fréquentes";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewSearch) {
        //NSLog(@"table rect: %@", NSStringFromCGRect(self.tableViewSearch.frame));
        SimpleCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleCellId"];

        SmileySearch* s = nil;
        if (indexPath.section == 0) { // Last search
            s = [self.arrLastSearchSorted objectAtIndex:indexPath.row];
            cell.imageIcon.image = [UIImage imageNamed:@"revert"];
        }
        else {
            s = [self.arrTopSearchSortedFiltered objectAtIndex:indexPath.row];
        }
        
        int iResults = 0;
        //NSLog(@"reload: %@ / %@", s.sSearchText, self.textFieldSmileys.text);
        if (s) {
            cell.labelText.text = s.sSearchText;
            if (indexPath.section == 1) {//} && self.textFieldSmileys.text.length >= 1) {
                NSRange range = [s.sSearchText rangeOfString:self.textFieldSmileys.text];
                //NSLog(@"-> bold %@ of %@?: %@", self.textFieldSmileys.text, s.sSearchText, NSStringFromRange(range));
                [cell.labelText boldSubstring: self.textFieldSmileys.text];
            }
            iResults = [s.nSearchNumber intValue];
        }
        else {
            cell.labelText.text = @"Y a rien";

        }
        
        // Format badge
        if (iResults > 0) {
            cell.labelBadge.text = [NSString stringWithFormat:@"%d", iResults];
            cell.labelBadge.backgroundColor = [ThemeColors tintColorWithAlpha:0.1];
            cell.labelBadge.textColor = [ThemeColors tintColorWithAlpha:0.5];// [UIColor whiteColor];
            cell.labelBadge.clipsToBounds = YES;
            //NSLog(@"Rect: %@", NSStringFromCGRect(cell.labelBadge.frame));
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
        SmileySearch* s = nil;
        if (indexPath.section == 0) { // Last search
            s = [self.arrLastSearchSorted objectAtIndex:indexPath.row];
        }
        else {
            s = [self.arrTopSearchSortedFiltered objectAtIndex:indexPath.row];
        }
        if (s) {
            self.textFieldSmileys.text = s.sSearchText;
            [self fetchSmileys];
            //[self textFieldShouldReturn:self.textFieldSmileys];
            [self.tableViewSearch deselectRowAtIndexPath:self.tableViewSearch.indexPathForSelectedRow animated:NO];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: implement search deletion
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"SMILEY :::: Show ???");
    if (self.bModeFullScreen) {
        [self resizeViewWithKeyboard:notification];
    }
    /*
    if (bModeFullScreen) {
        NSDictionary *userInfo = [notification userInfo];
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect convertedKeyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];

        CGRect safeAreaFrame = CGRectInset(self.view.safeAreaLayoutGuide.layoutFrame, 0, -self.additionalSafeAreaInsets.bottom);
        CGRect intersection = CGRectIntersection(safeAreaFrame, convertedKeyboardRect);
        NSLog(@"SMILEYS (%@) :::: Keyboard rect %@", notification.name, NSStringFromCGRect(keyboardRect));
        NSLog(@"SMILEYS (%@) :::: intersection rect %@", notification.name, NSStringFromCGRect(intersection));

        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];

        // Animate the resize of the text view's frame in sync with the keyboard's appearance.
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
        [self.view layoutIfNeeded];
        [UIView commitAnimations];
    }*/
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"SMILEY :::: Hide");
    [self resizeViewWithKeyboard:notification];
/*
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
*/
}

- (void)resizeViewWithKeyboard:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];
    CGRect safeAreaFrame = CGRectInset(self.view.safeAreaLayoutGuide.layoutFrame, 0, -self.additionalSafeAreaInsets.bottom);
    CGRect intersection = CGRectIntersection(safeAreaFrame, convertedKeyboardRect);

    NSLog(@"SMILEY :::: Keyboard will show - intersection: %@", NSStringFromCGRect(intersection));
    NSLog(@"### Keyboard  rect %@", NSStringFromCGRect(keyboardRect));
    NSLog(@"### SafeFrame rect %@", NSStringFromCGRect(safeAreaFrame));

    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)showTableViewInFullScreen
{
    NSLog(@"showTableViewInFullScreen");

    /*
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    self.bActivateSmileySearchTable = NO;
    NSLog(@"textFieldDidBeginEditing :::: 1");
    if (!self.bModeFullScreen) {
        self.bModeFullScreen = YES;
        [self.addMessageVC updateExpandCompressSmiley];
        [self updateExpandButton];
    }
    [self changeDisplayMode:DisplayModeEnumTableSearch animate:NO];
    NSLog(@"textFieldDidBeginEditing :::: 2");
    [UIView commitAnimations];
     */
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing");
    if (self.smileyCache.bSearchSmileysActivated) {
        [self changeDisplayMode:DisplayModeEnumSmileysSearch animate:YES];
    } else {
        self.bActivateSmileySearchTable = YES;
    }
}



- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidEndEditing");
    /*// See if it was due to a return
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        NSLog(@"Return was pressed!");
    }*/
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.textFieldSmileys.text.length < 3) {
        return NO;/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Saisir 3 caractères minimum !"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];*/
    }
    /*
    else {
        //[self.spinnerSmileySearch startAnimating];
        [self performSelectorInBackground:@selector(fetchSmileys) withObject:nil];
    }*/

    return YES;
    
}
/*- (BOOL)textFieldShouldClear:(UITextField *)textField
 {
    NSLog(@"textFieldShouldClear %@", textField.text);
 
    
    return YES;
 
 }*/

- (void)actionSmileysSearch:(id)sender
{
    [self fetchSmileys];
}

-(IBAction)textFieldSmileChange:(id)sender
{
    if ([(UITextField *)sender text].length > 0) {
        NSString* sText = [(UITextField *)sender text];
        sText = [sText stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        sText = [sText stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        @try {
            self.arrTopSearchSortedFiltered = [self.arrTopSearchSorted filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SmileySearch* s, NSDictionary *bindings) {
                return [s.sSearchText containsString:sText];  // Return YES for each object you want in filteredArray.
            }]];
            self.arrLastSearchSortedFiltered = [self.arrLastSearchSorted filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SmileySearch* s, NSDictionary *bindings) {
                return [s.sSearchText containsString:sText];  // Return YES for each object you want in filteredArray.
            }]];

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
        self.arrTopSearchSortedFiltered = self.arrTopSearchSorted;
        self.arrLastSearchSortedFiltered = self.arrLastSearchSorted;
        [self.tableViewSearch reloadData];
        if (self.smileyCache.bSearchSmileysActivated && self.displayMode == DisplayModeEnumSmileysSearch && self.bActivateSmileySearchTable == NO) {
            [self changeDisplayMode:DisplayModeEnumTableSearch animate:NO];
            //self.bActivateSmileySearchTable = YES;
        }
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.addMessageVC updateExpandCompressSmiley];
    });
    [[SmileyCache shared] handleSmileyArray:self.arrayTmpsmileySearch forCollection:self.collectionSmileys spinner:self.spinnerSmileySearch];
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
    // Save search when smiley is selected (this confirms the search is OK)
    if (self.textFieldSmileys.text.length >= 3) {
        NSArray *arrFound = [self.arrSearch filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SmileySearch* s, NSDictionary *bindings) {
            return [s.sSearchText isEqualToString:self.textFieldSmileys.text];  // Return YES for each object you want in filteredArray.
        }]];
        if (arrFound.count > 0) {
            SmileySearch* ss = (SmileySearch*)arrFound[0];
            ss.nSearchNumber = [NSNumber numberWithInt:[ss.nSearchNumber intValue] + 1];
            ss.dLastSearch = [NSDate date];
        }
        else {
            SmileySearch* ss = [[SmileySearch alloc] init];
            ss.nSearchNumber = [NSNumber numberWithInt:[ss.nSearchNumber intValue] + 1];
            ss.dLastSearch = [NSDate date];
            ss.sSearchText = self.textFieldSmileys.text;
            [self.arrSearch addObject:ss];
        }
        
        [self updateSearchArraySorted];
        
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *file = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:SEARCH_SMILEYS_FILE]];
        [self.arrSearch writeToFile:file atomically:YES];
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
}

- (void)updateExpandButton {
    NSString* sImageName = @"rectangle.expand";
    if (self.bModeFullScreen) {
        sImageName = @"rectangle.compress";
    }
    Theme theme = [[ThemeManager sharedManager] theme];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:sImageName] withTheme:theme] forState:UIControlStateNormal];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:sImageName] withTheme:theme] forState:UIControlStateHighlighted];
}

- (void) updateSearchArraySorted
{
    NSSortDescriptor *sortDescriptorNumber = [[NSSortDescriptor alloc] initWithKey: @"nSearchNumber" ascending:NO selector:@selector(compare:)];
    NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey: @"dLastSearch" ascending:NO selector:@selector(compare:)];
    self.arrTopSearchSorted = (NSMutableArray *)[self.arrSearch sortedArrayUsingDescriptors: [NSArray arrayWithObject:sortDescriptorNumber]];
    self.arrLastSearchSorted = (NSMutableArray *)[self.arrSearch sortedArrayUsingDescriptors: [NSArray arrayWithObject:sortDescriptorDate]];
    self.arrTopSearchSortedFiltered = self.arrTopSearchSorted;
    self.arrLastSearchSortedFiltered = self.arrLastSearchSorted;
}

- (void)actionSmileysDefaults:(id)sender {
    if (self.bModeFullScreen) {
        [self changeDisplayMode:DisplayModeEnumSmileysDefault animate:NO];
        [self resignFirstResponder];
    }
    else {
        BOOL bSetFirstResponder = NO;
        if (self.displayMode != DisplayModeEnumSmileysDefault) {
            bSetFirstResponder = YES;
        }
        [self changeDisplayMode:DisplayModeEnumSmileysDefault animate:NO];
        [self.addMessageVC updateExpandCompressSmiley];
        if (bSetFirstResponder) {
            [self.addMessageVC.textView becomeFirstResponder];
        }
    }
}


@end
