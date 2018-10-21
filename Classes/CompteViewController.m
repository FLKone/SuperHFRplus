//
//  CompteViewController.m
//  HFRplus
//
//  Created by FLK on 12/08/10.
//

#import "CompteViewController.h"
#import "CompteTableViewCell.h"
#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"
#import "IdentificationViewController.h"
#import "SuperHFRplusSwift-Swift.h"
#import "HFRplusAppDelegate.h"
#import "RangeOfCharacters.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "MultisManager.h"
#import "Constants.h"



@implementation CompteViewController
@synthesize comptesTableView;

NSArray* comptes;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Compte(s)";
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    UIBarButtonItem *addBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCompte)];
    self.navigationItem.rightBarButtonItem = addBarItem;
    
    comptesTableView.delegate = self;
    comptesTableView.dataSource = self;

    
}

-(void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    Theme theme = [[ThemeManager sharedManager] theme];
    [self setThemeColors:theme];
    [self refreshComptes];
    if([comptes count] < 1){
        [self addCompte];
    }
}

-(void)setThemeColors:(Theme)theme{
    if ([self.view respondsToSelector:@selector(setTintColor:)]) {
        self.view.tintColor = [ThemeColors tintColor:theme];
    }

    self.view.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.view.backgroundColor = comptesTableView.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    comptesTableView.separatorColor = [ThemeColors cellBorderColor:theme];
    
    
//    self.loginView.backgroundColor = [ThemeColors greyBackgroundColor:theme];
//    self.compteView.backgroundColor = [ThemeColors greyBackgroundColor:theme];
//    self.loadingLabel.textColor = [ThemeColors cellTextColor:theme];
//    [self.loadingIndicator setColor:[ThemeColors cellTextColor:theme]];
}

-(void)refreshComptes {
    NSLog(@"CompteViewController : refreshComptes");
    comptes = [[MultisManager sharedManager] getComtpes];
    [comptesTableView reloadData];
    
}

-(void)addCompte {
    NSLog(@"CompteViewController : addCompte");
        // Create the root view controller for the navigation controller
        // The new view controller configures a Cancel and Done button for the
        // navigation bar.
        AuthViewController *authController = [[AuthViewController alloc] initWithNibName:@"IdentificationViewController"
                                                                                  bundle:nil];
        //IdentificationViewController *identificationController = [[IdentificationViewController alloc]
          //                                                        initWithNibName:@"IdentificationViewController" bundle:nil];
        authController.delegate = self;
        authController.view.backgroundColor = [ThemeColors greyBackgroundColor:[[ThemeManager sharedManager] theme]];
    
        // Create the navigation controller and present it modally.
        HFRNavigationController *navigationController = [[HFRNavigationController alloc]
                                                        initWithRootViewController:authController];
    
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigationController animated:YES completion:nil];
        //[self presentModalViewController:navigationController animated:YES];    
}

#pragma mark IdentificationViewControllerDelegate

- (void)identificationViewControllerDidFinish:(IdentificationViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
    [[HFRplusAppDelegate sharedAppDelegate] login];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginChangedNotification object:nil];
    [self refreshComptes];
}

- (void)identificationViewControllerDidFinishOK:(IdentificationViewController *)controller {
    [self dismissModalViewControllerAnimated:YES];
    [[HFRplusAppDelegate sharedAppDelegate] login];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginChangedNotification object:nil];
    [self refreshComptes];
}

#pragma mark UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [comptes count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CompteTableViewCellIdentifier = @"CompteTableViewCell";
    
    CompteTableViewCell *cell = (CompteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CompteTableViewCellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CompteTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *compte = [comptes objectAtIndex:indexPath.row];
    NSString *pseudo = [compte objectForKey:PSEUDO_KEY];
    [cell.pseudoLabel setText:pseudo];
    NSString *avatarURL = [compte objectForKey:AVATAR_KEY];
    [cell setAvatar:avatarURL];
    [cell setExpiracy:[compte objectForKey:COOKIES_KEY]];
    BOOL isMain = [[compte objectForKey:MAIN_KEY] boolValue];
    [cell setMained:isMain];
    [cell applyTheme];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[MultisManager sharedManager] setPseudoAsMain:[[comptes objectAtIndex:indexPath.row] objectForKey:PSEUDO_KEY]];
     [self refreshComptes];
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[MultisManager sharedManager] deletePseudoAtIndex:indexPath.row];
        [self refreshComptes];
        NSLog(@"DELETE");
        
    }
}



//
//- (IBAction)logout {
//    //NSLog(@"logout");
//
//    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *cookies = [cookShared cookies];
//
//    for (NSHTTPCookie *aCookie in cookies) {
//        //NSLog(@"%@", aCookie);
//
//        [cookShared deleteCookie:aCookie];
//    }
//
//    //NSLog(@"logout: %@", [request responseString]);
//    [self.compteView setHidden:YES];
//    [self.loginView setHidden:NO];
//
//    [[HFRplusAppDelegate sharedAppDelegate] logout];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginChangedNotification object:nil];
//}
//
//- (IBAction)login {
//
//
//    // Create the root view controller for the navigation controller
//    // The new view controller configures a Cancel and Done button for the
//    // navigation bar.
//    AuthViewController *authController = [[AuthViewController alloc] initWithNibName:@"IdentificationViewController"
//                                                                              bundle:nil];
//    //IdentificationViewController *identificationController = [[IdentificationViewController alloc]
//      //                                                        initWithNibName:@"IdentificationViewController" bundle:nil];
//    authController.delegate = self;
//    authController.view.backgroundColor = [ThemeColors greyBackgroundColor:[[ThemeManager sharedManager] theme]];
//
//    // Create the navigation controller and present it modally.
//    HFRNavigationController *navigationController = [[HFRNavigationController alloc]
//                                                    initWithRootViewController:authController];
//
//    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentViewController:navigationController animated:YES completion:nil];
//    //[self presentModalViewController:navigationController animated:YES];
//    [self.loginView setHidden:YES];
//
//    // The navigation controller is now owned by the current view controller
//    // and the root view controller is owned by the navigation controller,
//    // so both objects should be released to prevent over-retention.
//}
//

//
//- (IBAction)goToProfil {
//    [[HFRplusAppDelegate sharedAppDelegate] openURL:[NSString stringWithString:[NSString stringWithFormat:@"%@/user/editprofil.php", [k ForumURL]]]];
//}
//
//- (void)viewDidUnload {
//    //NSLog(@"viewDidUnload");
//
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//    self.compteView = nil;
//    self.loginView = nil;
//    self.profilBtn = nil;
//}


- (void)dealloc {
    //NSLog(@"dealloc CVC");
    [self viewDidUnload];
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
    //    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
