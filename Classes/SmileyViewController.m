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

@implementation SmileyViewController

@synthesize collectionSmileys, textFieldSmileys, btnSmileySearch, btnSmileyDefault, btnSmileyFavorites, btnReduce;


#pragma mark -
#pragma mark View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        //NSLog(@"initWithNibName add");
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Collection Smileys defaults
    [self.collectionSmileys setHidden:YES];
    self.collectionSmileys.backgroundColor = UIColor.clearColor;

    [self.collectionSmileys registerClass:[SmileyCollectionCell class] forCellWithReuseIdentifier:@"SmileyCollectionCellId"];

    [self.collectionSmileys  setDataSource:self];
    [self.collectionSmileys  setDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.backgroundColor = [UIColor whiteColor];

    Theme theme = [[ThemeManager sharedManager] theme];
    [self.btnSmileySearch  setImage:[ThemeColors tintImage:[UIImage imageNamed:@"06-magnify"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnSmileySearch setImage:[ThemeColors tintImage:[UIImage imageNamed:@"06-magnify"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnSmileySearch setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.btnSmileyDefault  setImage:[ThemeColors tintImage:[UIImage imageNamed:@"redface"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnSmileyDefault setImage:[ThemeColors tintImage:[UIImage imageNamed:@"redface"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnSmileyDefault setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.btnSmileyFavorites setImage:[ThemeColors tintImage:[UIImage imageNamed:@"favorites_on"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnSmileyFavorites setImage:[ThemeColors tintImage:[UIImage imageNamed:@"favorites_on"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnSmileyFavorites setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"10-arrows-in"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"10-arrows-in"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnReduce setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];

    
    //[self.navigationController.navigationBar setTranslucent:NO];
}

#pragma mark - Collection management

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (collectionView == self.collectionSmileys) {
        SmileyCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SmileyCollectionCellId" forIndexPath:indexPath];
        UIImage* image = nil;//[UIImage imageNamed:@"19-gear"];
        if (!self.bSearchSmileysActivated) {
             // Default smileys
            image = [UIImage imageNamed:self.dicCommonSmileys[indexPath.row][@"resource"]];
            cell.smileyCode = self.dicCommonSmileys[indexPath.row][@"code"];
        }
        else {
            UIImage* tmpImage = [[SmileyCache shared] getImageForIndex:(int)indexPath.row];
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
    else {
        RehostCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RehostCollectionCellId" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            [cell configureWithIcon:[UIImage imageNamed:@"Camera-32"] border:15];
            cell.layer.borderWidth = 1.0f;
            cell.layer.borderColor = [ThemeColors tintColor].CGColor;
        } else {
            [cell configureWithRehostImage:[rehostImagesSortedArray objectAtIndex:indexPath.row - 1]];
        }
        cell.layer.cornerRadius = 5;
        cell.layer.masksToBounds = true;

        return cell;
    }*/
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /*if (collectionView == self.collectionSmileys) {
        SmileyCollectionCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (!self.bSearchSmileysActivated) {
            [self didSelectSmile:cell.smileyCode];
        }
        else {
            [self didSelectSmile:@"totoz"];
        }
    }*/
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
    /*
    if (collectionView == self.collectionSmileys) {
        if (!self.bSearchSmileysActivated) {
            return self.dicCommonSmileys.count;
        }
        else {
            return self.smileyArray.count;
        }
    }
    else {
        return self.rehostImagesSortedArray.count + 1;
    }
     */
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (collectionView == self.collectionSmileys) {
        //return CGSizeMake(w, 50);
        return CGSizeMake(70*fCellSize, 50*fCellSize);
    }
    else {
        return CGSizeMake(60, 60);
    }*/
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


@end
