//
//  RehostImageViewController.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 22/07/2020.
//

#import <Foundation/Foundation.h>
#import "RehostImage.h"
#import "RehostCell.h"
#import "RehostImageViewController.h"
#import "Constants.h"
#import "ThemeManager.h"
#import "ThemeColors.h"
#import "HFRUIImagePickerController.h"
#import "HFRplusAppDelegate.h"
#import "RehostImage.h"
#import "RehostCell.h"
#import "RehostCollectionCell.h"
#import "AddMessageViewController.h"

@implementation RehostImageViewController

@synthesize rehostImagesArray, rehostImagesSortedArray, bModeFullScreen;
@synthesize popover = _popover, tableViewImages, collectionImages, btnCamera, btnPhoto, btnBBCodeType, btnMaxSize, btnReduce, progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        //Smileys / Rehost
        self.rehostImagesArray = [[NSMutableArray alloc] init];
        self.rehostImagesSortedArray = [[NSMutableArray alloc] init];
        self.title = @"Photo upload";
        self.bModeFullScreen = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *rehostImages = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:REHOST_IMAGE_FILE]];
    
    if ([fileManager fileExistsAtPath:rehostImages]) {
        NSData *savedData = [NSData dataWithContentsOfFile:rehostImages];
        NSError* error;
        self.rehostImagesArray = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:savedData error:&error];
        self.rehostImagesSortedArray =  [NSMutableArray arrayWithArray:[[self.rehostImagesArray reverseObjectEnumerator] allObjects]];
        if (self.rehostImagesArray == nil) {
            self.rehostImagesArray = [[NSMutableArray alloc] init];
            self.rehostImagesSortedArray = [[NSMutableArray alloc] init];
        }
    }
    else {
        self.rehostImagesArray = [[NSMutableArray alloc] init];
        self.rehostImagesSortedArray = [[NSMutableArray alloc] init];
    }

    //Bouton Annuler
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Fermer" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = cancelBarItem;

    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString *tempHTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"smileybase" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
    
    tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7"];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgress:) name:@"uploadProgress" object:nil];
    
    // Table view images
    [self.tableViewImages setAlpha:0];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    v.backgroundColor = [ThemeColors addMessageBackgroundColor:[[ThemeManager sharedManager] theme]];
    [self.tableViewImages setTableFooterView:v];
    
    [self.btnCamera addTarget:self action:@selector(uploadNewPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPhoto addTarget:self action:@selector(uploadExistingPhoto:) forControlEvents:UIControlEventTouchUpInside];

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"rehost_use_link"] == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:bbcodeImageWithLink forKey:@"rehost_use_link"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"rehost_resize_before_upload"] == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:1200 forKey:@"rehost_resize_before_upload"];
    }

    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_use_link"] == bbcodeImageWithLink) {
        [self.btnBBCodeType setTitle:@"Image et lien" forState:UIControlStateNormal];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_use_link"] == bbcodeImageNoLink) {
        [self.btnBBCodeType setTitle:@"Image sans lien" forState:UIControlStateNormal];
    } else {
        [self.btnBBCodeType setTitle:@"Lien seul" forState:UIControlStateNormal];
    }
    [self.btnBBCodeType addTarget:self action:@selector(actionBBCodeType:) forControlEvents:UIControlEventTouchUpInside];

    [self.btnReduce addTarget:self action:@selector(actionReduce:) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger iMaxSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_resize_before_upload"];
    [self.btnMaxSize setTitle:[NSString stringWithFormat:@"%d px", (int)iMaxSize] forState:UIControlStateNormal];
    [self.btnMaxSize addTarget:self action:@selector(actionImageUploadSize:) forControlEvents:UIControlEventTouchUpInside];
    
   // Setup Image collections
    [self.collectionImages setHidden:NO];

    [self.collectionImages registerClass:[SmileyCollectionCell class] forCellWithReuseIdentifier:@"SmileyCollectionCellId"];
    [self.collectionImages registerClass:[RehostCollectionCell class] forCellWithReuseIdentifier:@"RehostCollectionCellId"];

    [self.collectionImages  setDataSource:self];
    [self.collectionImages  setDelegate:self];
    
    // Progress view
    [self.progressView setAlpha:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.btnCamera setImageEdgeInsets:UIEdgeInsetsMake(3+4, 27-1, 3+4, 12-1)];
    [self.btnPhoto setImageEdgeInsets:UIEdgeInsetsMake(4+4, 18-1, 4+4, 18-1)];

    [self updateTheme];
}

- (void)updateTheme
{
    Theme theme = [[ThemeManager sharedManager] theme];
    [self.btnCamera setImage:[ThemeColors tintImage:[UIImage imageNamed:@"Camera-32"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnCamera setImage:[ThemeColors tintImage:[UIImage imageNamed:@"Camera-32"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnPhoto setImage:[ThemeColors tintImage:[UIImage imageNamed:@"Folder-32"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnPhoto setImage:[ThemeColors tintImage:[UIImage imageNamed:@"Folder-32"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"rectangle.expand"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnReduce setImage:[ThemeColors tintImage:[UIImage imageNamed:@"rectangle.expand"] withTheme:theme] forState:UIControlStateHighlighted];
    
    self.tableViewImages.backgroundColor = [ThemeColors addMessageBackgroundColor:[[ThemeManager sharedManager] theme]];
    self.collectionImages.backgroundColor = [ThemeColors addMessageBackgroundColor:[[ThemeManager sharedManager] theme]];
    self.view.backgroundColor = [ThemeColors addMessageBackgroundColor:[[ThemeManager sharedManager] theme]];
    
    [self.btnBBCodeType setTintColor:[ThemeColors tintColor]];
    [self.btnMaxSize setTintColor:[ThemeColors tintColor]];
}


- (float) getDisplayHeight {
    return 80;
}


#pragma mark - Rehost
- (void) uploadProgress: (NSNotification *) notification {
    // NSLog(@"notif %@", notification);
    
    float progressFloat = [[[notification object] valueForKey:@"progress"] floatValue];
    
    if (progressFloat > 0) {
        if (progressFloat == 2) {
            RehostImage* rehostImage = (RehostImage *)[[notification object] objectForKey:@"rehostImage"];
            
            [self.rehostImagesArray addObject:rehostImage];
            
            NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *rehostImages = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:REHOST_IMAGE_FILE]];
            
            NSData *savedData = [NSKeyedArchiver archivedDataWithRootObject:self.rehostImagesArray];
            [savedData writeToFile:rehostImages atomically:YES];
            
            self.rehostImagesSortedArray =  [NSMutableArray arrayWithArray:[[self.rehostImagesArray reverseObjectEnumerator] allObjects]];
            [self.tableViewImages reloadData];
            [self.collectionImages reloadData];
        }
        else {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.1];
            [self.progressView setHidden:NO];
            [self.progressView setAlpha:1];
            [UIView commitAnimations];
            [self.progressView setProgress:progressFloat];
            if (progressFloat == 1) {
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [self.progressView setAlpha:0];
                [UIView commitAnimations];
            }
        }
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [self.progressView setAlpha:0];
        [UIView commitAnimations];
    }
}

- (void)uploadNewPhoto:(id)sender {
    //NSLog(@"uploadNewPhoto");
    [self showImagePicker:UIImagePickerControllerSourceTypeCamera withSender:sender];
}

- (void)uploadExistingPhoto:(id)sender {
    //NSLog(@"uploadExistingPhoto");
    [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary withSender:sender];
}

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment {
    switch (segment.selectedSegmentIndex) {
        case 0:{
            [[NSUserDefaults standardUserDefaults] setInteger:bbcodeImageWithLink forKey:@"rehost_use_link"];
            break;}
        case 1:{
            [[NSUserDefaults standardUserDefaults] setInteger:bbcodeImageNoLink forKey:@"rehost_use_link"];
            break;}
        case 2:{
            [[NSUserDefaults standardUserDefaults] setInteger:bbcodeLinkOnly forKey:@"rehost_use_link"];
            break;}
    }
}

-(void)segmentedControlResizeValueDidChange:(UISegmentedControl *)segment {
    switch (segment.selectedSegmentIndex) {
        case 0:{
            [[NSUserDefaults standardUserDefaults] setInteger:1200 forKey:@"rehost_resize_before_upload"];
            break;}
        case 1:{
            [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"rehost_resize_before_upload"];
            break;}
        case 2:{
            [[NSUserDefaults standardUserDefaults] setInteger:800 forKey:@"rehost_resize_before_upload"];
            break;}
        case 3:{
            [[NSUserDefaults standardUserDefaults] setInteger:600 forKey:@"rehost_resize_before_upload"];
            break;}
        case 4:{
            [[NSUserDefaults standardUserDefaults] setInteger:400 forKey:@"rehost_resize_before_upload"];
            break;}
    }
}


- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType withSender:(UIButton *)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        HFRUIImagePickerController *picker = [[HFRUIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;

        
        if ([self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact){
            
            [self presentViewController:picker animated:YES completion:^{
                //NSLog(@"présenté");
            }];
        }
        else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.popover = nil;
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            [popover presentPopoverFromRect:sender.frame inView:[self.tableViewImages tableHeaderView] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            self.popover = popover;
        } else {
            [self presentViewController:picker animated:YES completion:^{
                //NSLog(@"présenté");
            }];
            //[self presentModalViewController:picker animated:YES];
        }
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    NSLog(@"imagePickerControllerDidCancel");
    if ([self respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
    {
        [picker dismissModalViewControllerAnimated:YES];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [_popover dismissPopoverAnimated:YES];
    }
    else
    {
        [picker dismissModalViewControllerAnimated:YES];
    }
    
    if (self.bModeFullScreen == NO) {
        // Give back focus to textview
        [self.addMessageVC.textView becomeFirstResponder];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"didFinishPickingMediaWithInfo %@", info);
    
    [self imagePickerControllerDidCancel:picker];
    
    RehostImage *rehostImage = [[RehostImage alloc] init];
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [rehostImage upload:image];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableViewImages) {
        [self.tableViewImages deselectRowAtIndexPath:self.tableViewImages.indexPathForSelectedRow animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete && tableView == self.tableViewImages)
    {
        NSLog(@"DELTE REHOST");
        RehostImage*rehostImage = [self.rehostImagesSortedArray objectAtIndex:indexPath.row];
        NSLog(@"rehostImage %@", rehostImage.nolink_full);
        
        [self.rehostImagesArray removeObjectIdenticalTo:rehostImage];
        
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *rehostImages = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:REHOST_IMAGE_FILE]];
        NSData *savedData = [NSKeyedArchiver archivedDataWithRootObject:self.rehostImagesArray];
        [savedData writeToFile:rehostImages atomically:YES];
        
        self.rehostImagesSortedArray =  [NSMutableArray arrayWithArray:[[self.rehostImagesArray reverseObjectEnumerator] allObjects]];
        
        [self.tableViewImages deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.collectionImages reloadData];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"landscape_mode"] isEqualToString:@"all"]) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [_popover dismissPopoverAnimated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for supported orientations
    // Get user preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *enabled = [defaults stringForKey:@"landscape_mode"];
    
    if (![enabled isEqualToString:@"none"]) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rehostImagesSortedArray.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"CellForRowAtIndexPath %ld", (long)indexPath.row);
    static NSString* CellRehostIdentifier = @"RehostCell";
    RehostCell *cell = (RehostCell *)[tableView dequeueReusableCellWithIdentifier:CellRehostIdentifier];
    if (cell == nil)
    {
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:CellRehostIdentifier owner:self options:nil];
    
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    [cell configureWithRehostImage:[self.rehostImagesSortedArray objectAtIndex:indexPath.row]];
    [[ThemeManager sharedManager] applyThemeToCell:cell];
    return cell;
}

#pragma mark - Collection Images

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RehostCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RehostCollectionCellId" forIndexPath:indexPath];
    [cell configureWithRehostImage:[rehostImagesSortedArray objectAtIndex:indexPath.row]];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = true;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.addMessageVC actionHideRehostImage];
    RehostImage* rehostImage = [self.rehostImagesSortedArray objectAtIndex:indexPath.row];
    [rehostImage copyToPasteBoard:bbcodeImageFull];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return rehostImagesSortedArray.count; // + 1;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(60, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 2, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0;
}


#pragma mark - UIPickerViewDelegate
/*
-(void)loadSubCat
{
    [_popover dismissPopoverAnimated:YES];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [catButton setTitle:[[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aTitle] forState:UIControlStateNormal];
    [textFieldCat setText:[[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aID]];
    
    [self dismissActionSheet];
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == myPickerView)    // don't show selection for the custom picker
    {
        // report the selection to the UI label
        //label.text = [NSString stringWithFormat:@"%@ - %d",
        //              [pickerViewArray objectAtIndex:[pickerView selectedRowInComponent:0]],
        //              [pickerView selectedRowInComponent:1]];
        
        //NSLog(@"%@", [pickerViewArray objectAtIndex:[pickerView selectedRowInComponent:0]]);
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnStr = @"";
    
    if (row == 0) {
        //NSString *returnStr = @"";
        
    }
    else {
        returnStr = @"- ";
    }
    
    
    // note: custom picker doesn't care about titles, it uses custom views
    if (pickerView == myPickerView)
    {
        if (component == 0)
        {
            returnStr = [returnStr stringByAppendingString:[[pickerViewArray objectAtIndex:row] aTitle]];
        }
    }
    
    return returnStr;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerViewArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
    //CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGRect pickerRect = CGRectMake(    0.0,
                                   40,
                                   self.view.frame.size.width,
                                   size.height);
    
    
    return pickerRect;
}
*/
-(void)dismissActionSheet {
    //[actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style   {
    
    UINavigationController *uvc = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
    return uvc;
    
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

-(void)showPicker:(id)sender
{
    /*
    [textFieldTitle resignFirstResponder];
    [textView resignFirstResponder];
    [textFieldSmileys resignFirstResponder];
    
    //NSLog(@"TT %@", [[pickerViewArray objectAtIndex:[myPickerView selectedRowInComponent:0]] aTitle]);
    
    SubCatTableViewController *subCatTableViewController = [[SubCatTableViewController alloc] initWithStyle:UITableViewStylePlain];
    subCatTableViewController.suPicker = myPickerView;
    subCatTableViewController.arrayData = pickerViewArray;
    subCatTableViewController.notification = @"CatSelected";
    
    subCatTableViewController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *pc = [subCatTableViewController popoverPresentationController];
    //pc.backgroundColor = [ThemeColors greyBackgroundColor:[[ThemeManager sharedManager] theme]];
    pc.permittedArrowDirections = UIPopoverArrowDirectionUp;
    pc.delegate = self;
    pc.sourceView = (UIButton *)sender;
    pc.sourceRect = CGRectMake(0, 0, ((UIButton *)sender).frame.size.width, 35);
    
    [self presentViewController:subCatTableViewController animated:YES completion:nil];
*/
}

#pragma mark - Action events
- (void)actionBBCodeType:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Type de bbcode" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"Image et lien" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSUserDefaults standardUserDefaults] setInteger:bbcodeImageWithLink forKey:@"rehost_use_link"];
        [self.btnBBCodeType setTitle:@"Image et lien" forState:UIControlStateNormal];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"Image sans lien" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSUserDefaults standardUserDefaults] setInteger:bbcodeImageNoLink forKey:@"rehost_use_link"];
        [self.btnBBCodeType setTitle:@"Image sans lien" forState:UIControlStateNormal];
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"Lien seul" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSUserDefaults standardUserDefaults] setInteger:bbcodeLinkOnly forKey:@"rehost_use_link"];
        [self.btnBBCodeType setTitle:@"Lien seul" forState:UIControlStateNormal];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_use_link"] == bbcodeImageWithLink) {
        [action1 setValue:@true forKey:@"checked"];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_use_link"] == bbcodeImageNoLink) {
        [action2 setValue:@true forKey:@"checked"];
    } else {
        [action3 setValue:@true forKey:@"checked"];
    }

    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}

- (void)actionImageUploadSize:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Dimension maximale de l'image uploadée" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"1200 px" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSUserDefaults standardUserDefaults] setInteger:1200 forKey:@"rehost_resize_before_upload"];
        [self.btnMaxSize setTitle:[NSString stringWithFormat:@"%d px", (int)1200] forState:UIControlStateNormal];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"1000 px" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"rehost_resize_before_upload"];
        [self.btnMaxSize setTitle:[NSString stringWithFormat:@"%d px", (int)1000] forState:UIControlStateNormal];
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"800 px" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSUserDefaults standardUserDefaults] setInteger:800 forKey:@"rehost_resize_before_upload"];
        [self.btnMaxSize setTitle:[NSString stringWithFormat:@"%d px", (int)800] forState:UIControlStateNormal];
    }];
    UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"600 px" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSUserDefaults standardUserDefaults] setInteger:600 forKey:@"rehost_resize_before_upload"];
        [self.btnMaxSize setTitle:[NSString stringWithFormat:@"%d px", (int)600] forState:UIControlStateNormal];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:action4];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_resize_before_upload"] == 1200) {
        [action1 setValue:@true forKey:@"checked"];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_resize_before_upload"] == 1000) {
        [action2 setValue:@true forKey:@"checked"];
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:@"rehost_resize_before_upload"] == 800) {
        [action3 setValue:@true forKey:@"checked"];
    } else {
        [action4 setValue:@true forKey:@"checked"];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}



- (void)actionReduce:(id)sender {
    [self.addMessageVC actionExpandCompressRehostImage];
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

@end
