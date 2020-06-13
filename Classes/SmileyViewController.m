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

@implementation SmileyViewController

@synthesize smileyCache, navigationBar, collectionSmileys, textFieldSmileys, btnSmileySearch, btnSmileyDefault, btnReduce;


#pragma mark -
#pragma mark View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        self.smileyCache = [SmileyCache shared];
        self.title = @"Smileys";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *sendBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Fermer" style:UIBarButtonItemStyleDone target:self action:@selector(closeView)];
    self.navigationBar.topItem.rightBarButtonItem = sendBarItem;
    self.navigationBar.topItem.title = @"Smileys";
    
     // Collection Smileys defaults
    [self.collectionSmileys setHidden:NO];
    self.collectionSmileys.backgroundColor = UIColor.whiteColor;

    [self.collectionSmileys registerClass:[SmileyCollectionCell class] forCellWithReuseIdentifier:@"SmileyCollectionCellId"];

    [self.collectionSmileys  setDataSource:self];
    [self.collectionSmileys  setDelegate:self];
    
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
    [self.btnSmileyDefault setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"10-arrows-in"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"10-arrows-in"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnReduce setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];

    [self.btnReduce addTarget:self action:@selector(actionReduce:) forControlEvents:UIControlEventTouchUpInside];

    
    [self.spinnerSmileySearch setHidesWhenStopped:YES];
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
        if (!self.smileyCache.bSearchSmileysActivated) {
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
        cell.layer.cornerRadius = 5;
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
            return 0;//self.smileyArray.count;
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

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow ADD %@", notification);

    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];

    CGRect safeAreaFrame = CGRectInset(self.view.safeAreaLayoutGuide.layoutFrame, 0, -self.additionalSafeAreaInsets.bottom);
    CGRect intersection = CGRectIntersection(safeAreaFrame, convertedKeyboardRect);

//    self.bottomGuide.constant = CGRectGetMaxY(self.view.bounds) - CGRectGetMinY(convertedKeyboardRect);
  //  [self.accessoryView setNeedsUpdateConstraints];

    NSLog(@"Bottom Constant %@", NSStringFromCGRect(intersection));

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

- (IBAction)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionReduce:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.addMessageVC showPanelSmiley:YES reloadData:YES];
}

@end
