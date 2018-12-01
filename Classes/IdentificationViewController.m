//
//  IdentificationViewController.m
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import "HFRplusAppDelegate.h"
#import "IdentificationViewController.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "Constants.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "MultisManager.h"


@implementation IdentificationViewController
@synthesize delegate;
@synthesize pseudoField, passField, logView, password;



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

-(void)log:(id)newLog {
    return;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSS"];
    NSDate *todaysDate;
    todaysDate = [NSDate date];

    [self.logView setText:[NSString stringWithFormat:@"%@\n~~~ %@ %@", self.logView.text, [formatter stringFromDate:todaysDate], newLog]];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //NSLog(@"viewDidLoad");
    self.title = @"Identification";
    [self log:@"viewDidLoad"];

    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //Bouton Finish
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Annuler" style:UIBarButtonItemStyleDone target:self action:@selector(finish)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.passField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setThemeColors:[[ThemeManager sharedManager] theme]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [pseudoField becomeFirstResponder];
}

-(void)setThemeColors:(Theme)theme{
    
    self.view.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    pseudoField.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    pseudoField.textColor = [ThemeColors textColor:theme];
    pseudoField.layer.borderColor = [[ThemeColors cellBorderColor:theme] CGColor];
    pseudoField.layer.borderWidth = 1.0f;
    pseudoField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Pseudo" attributes:@{NSForegroundColorAttributeName:[ThemeColors cellBorderColor:theme]}];
    passField.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    passField.textColor = [ThemeColors textColor:theme];
    passField.layer.borderColor = [[ThemeColors cellBorderColor:theme] CGColor];
    passField.layer.borderWidth = 1.0f;
    passField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Mot de passe" attributes:@{NSForegroundColorAttributeName:[ThemeColors cellBorderColor:theme]}];
    titleLabel.textColor = [ThemeColors cellTextColor:theme];
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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.pseudoField = nil;
    self.passField = nil;
    
}


- (void)dealloc {
    //NSLog(@"dealloc IVC");
    [self viewDidUnload];
    
    self.delegate = nil;
    
}
/*
 - (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField.tag == 1 && textField.text.length > 0) {
 [textField resignFirstResponder];
 [[textField.superview viewWithTag:2] becomeFirstResponder];
	}
	
	return YES;
 
 }
 */
-(IBAction)done:(id)sender {
    if ([sender isEqual:pseudoField] && pseudoField.text.length > 0) {
        //NSLog(@"pseudoField");
        [pseudoField resignFirstResponder];
        [passField becomeFirstResponder];
    }
    if ([sender isEqual:passField] && passField.text.length > 0 && pseudoField.text.length > 0) {
        //NSLog(@"passField");
        [passField resignFirstResponder];
        
        [self connexion];
    }
}

-(IBAction)connexion {
    [self log:@"Auth: Removing Cookies"];

    // remove cookie before auth
    NSHTTPCookieStorage *cookShared = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookShared cookies];

    for (NSHTTPCookie *aCookie in cookies) {
        //NSLog(@"%@", aCookie);

        [cookShared deleteCookie:aCookie];
    }
    
    [pseudoField resignFirstResponder];
    [passField resignFirstResponder];
    
    if (passField.text.length == 0 || pseudoField.text.length == 0) {
        return;
    }
    
    //NSLog(@"connexion");
    ASIFormDataRequest  *request =
    [[ASIFormDataRequest alloc]  initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [k ForumURL], @"/login_validation.php?config=hfr.inc"]]];
    [request setStringEncoding:NSUTF8StringEncoding];

    [request addPostValue:pseudoField.text forKey:@"pseudo"];
    [request addPostValue:password forKey:@"password"];

    
    [request addPostValue:@"send" forKey:@"action"];

    [request addPostValue:@"Se connecter" forKey:@"login"];
    [self log:@"Auth: Sending Request"];

    [request startSynchronous];

    if (request) {
        [self log:@"Auth: Request Headers"];
        [self log:[request requestHeaders]];
        [self log:@"Auth: Request Post Body"];
        [self log:[[NSString alloc] initWithData:[request postBody] encoding:NSUTF8StringEncoding]];

        [self log:@"Auth: Request sent"];

        if ([request error]) {
            //NSLog(@"localizedDescription %@", [[request error] localizedDescription]);
            //NSLog(@"responseString %@", [request responseString]);
        } else if ([request responseString]) {
            //NSLog(@"responseString %@", [request responseString]);
            //NSLog(@"responseString %@", [request responseHeaders]);

            [self log:@"Request: OK"];

            [self log:@"Response: Headers"];
            [self log:[request responseHeaders]];

            [self log:@"Response: RAW"];
            [self log:[request responseString]];


            NSArray * urlArray = [[request responseString] arrayOfCaptureComponentsMatchedByRegex:@"<meta http-equiv=\"Refresh\" content=\"1; url=login_redirection.php([^\"]*)\" />"];
            
            //NSLog(@"%d", urlArray.count);
            if (urlArray.count > 0) {
                //NSLog(@"connexion OK");
                
                [self checkLogin];
            }
            else {
                //NSLog(@"connexion KO");
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Le pseudo que vous avez saisi n'a pas été trouvé ou votre mot de passe est incorrect.\nVeuillez réessayer."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                
            }
            
        }
    }
}


- (void)checkLogin {
    //NSLog(@"checkLogin");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/editprofil.php?config=hfr.inc&page=5", [k ForumURL]]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setUseCookiePersistence:YES];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"requestFinished");

    // Use when fetching text data
    NSString *responseString = [request responseString];
    //NSLog(@"finish %@", [request responseString]);

    NSString *regularExpressionString = @".*<td class=\"profilCase2\"><b>Avatar&nbsp;:</b></td>.*";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularExpressionString];
    BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:responseString];

    if (myStringMatchesRegEx) {
        //NSLog(@"finish OK");

        //OK
        // Generate Compte
        // Get avatar
        NSError * error = nil;
        HTMLParser *myParser = [[HTMLParser alloc] initWithString:[request responseString] error:&error];
        HTMLNode * bodyNode = [myParser body]; //Find the body tag
        HTMLNode * hashNode = [bodyNode findChildWithAttribute:@"name" matchingName:@"hash_check" allowPartial:NO];
        NSString *hash =  [hashNode getAttributeNamed:@"value"];
        HTMLNode * profilCase3Node = [bodyNode findChildWithAttribute:@"class" matchingName:@"profilCase3" allowPartial:NO];
        HTMLNode * avatarNode = [profilCase3Node findChildTag:@"img"];
        NSString *avatarURL = @"";
        if (avatarNode) {
           NSLog(@"There is an avatar");
            avatarURL = [avatarNode getAttributeNamed:@"src"];
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                [[MultisManager sharedManager] addCompteWithPseudo:pseudoField.text andCookies:request.responseCookies andAvatar:data andHash:hash];
                [self finishOK];
            }];
        }else{
            [[MultisManager sharedManager] addCompteWithPseudo:pseudoField.text andCookies:request.responseCookies andAvatar:nil andHash:hash];
            [self finishOK];
        }
       
    }
    else {
        //KO need to LOG IN

        //NSLog(@"finish KO");
        [self finish];
    }

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
}



- (void)finishOK {
    [self.delegate identificationViewControllerDidFinishOK:self];
}
- (void)finish {
    [self.delegate identificationViewControllerDidFinish:self];	
}

- (IBAction)goToCreate {
    [[HFRplusAppDelegate sharedAppDelegate] openURL:@"https://forum.hardware.fr/inscription.php"];
}


#pragma mark hidePassword

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if(textField == passField){
        if(!password){
            password = @"";
        }
        NSString *pass = password;
        if (range.length + range.location > [pass length]) {
            return NO;
        }
        pass = [pass stringByReplacingCharactersInRange:range withString:string];
        password = nil;
        password = [NSString stringWithString:pass];
        
        [self hideTextInTextField];
        
        return NO;
    }else{
        return YES;
    }
    
}


- (void)hideTextInTextField
{
    NSUInteger lenght = [password length];
    NSString *string = @"";
   
    
    for (int i = 0; i < lenght; i++)
    {
        string = [string stringByAppendingString:@"●"];
    }
     passField.text = string;
}

@end
