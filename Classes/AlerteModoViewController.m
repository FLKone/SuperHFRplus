//
//  AlerteModoViewController.m
//  HFRplus
//
//  Created by FLK on 04/09/2015.
//
//

#import "AlerteModoViewController.h"
#import "HFRplusAppDelegate.h"
#import "HTMLParser.h"
#import "ASIFormDataRequest.h"
#import "RangeOfCharacters.h"
#import "ThemeManager.h"
#import "ThemeColors.h"
#import "HFRAlertView.h"
#import "ASIHTTPRequest+Tools.h"

@implementation AlerteModoViewController
@synthesize textView, delegate, url;
@synthesize request, loadingView, accessoryView, arrayInputData, formSubmit;

NSString *const PLACEHOLDER = @"Attention : le message que vous écrivez ici sera envoyé directement chez les modérateurs via message privé ou e-mail.\n\nCe formulaire est destiné UNIQUEMENT à demander aux modérateurs de venir sur le sujet lorsqu'il y a un problème.\n\nIl ne sert pas à appeler à l'aide parce que personne ne répond à vos questions.\nIl ne sert pas non plus à ajouter un message sur le sujet, pour cela il y a le menu 'Répondre' (s'il est absent c'est que le sujet a été cloturé).";


#pragma mark -
#pragma mark Download

- (void)cancelFetchContent
{
    [request cancel];
}

- (void)fetchContent
{
    //NSLog(@"======== fetchContent");
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMini];
    
    [self setRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.url lowercaseString]]]];
    [request setDelegate:self];
    
    [request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentComplete:)];
    [request setDidFailSelector:@selector(fetchContentFailed:)];
    
    [self.accessoryView setHidden:YES];
    [self.loadingView setHidden:NO];
    
    [request startAsynchronous];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
    //started
}

- (void)fetchContentComplete:(ASIHTTPRequest *)theRequest
{
    
    [self.arrayInputData removeAllObjects];
    
    [self loadDataInTableView:[request safeResponseData]];
    
    [self.accessoryView setHidden:NO];
    [self.loadingView setHidden:YES];
    
    [self setupResponder];
    //NSLog(@"======== fetchContentComplete");
    
}

- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    [self.loadingView setHidden:YES];
    
    // Popup retry
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ooops !" message:[theRequest.error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) { }];
    UIAlertAction* actionRetry = [UIAlertAction actionWithTitle:@"Réessayer" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) { [self fetchContent]; }];
    [alert addAction:actionCancel];
    [alert addAction:actionRetry];
    
    [self presentViewController:alert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}


#pragma mark -
#pragma mark View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        self.url = [[NSString alloc] init];
        self.arrayInputData = [[NSMutableDictionary alloc] init];
        self.formSubmit = [[NSString alloc] init];
        
        self.title = @"Alerte Modération";

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //Bouton Annuler
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Annuler" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelBarItem;
    
    //Bouton Envoyer
    UIBarButtonItem *sendBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Envoyer" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = sendBarItem;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    

    self.textView.text = PLACEHOLDER;
    self.textView.textColor = [UIColor lightGrayColor];
    
    self.textView.backgroundColor = [ThemeColors greyBackgroundColor];
    self.textView.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
    [self.navigationController.navigationBar setTranslucent:NO];


    
    [self fetchContent];
}

-(void)setupResponder {
   // [self.textView becomeFirstResponder];
}

-(void)loadDataInTableView:(NSData *)contentData {
    NSLog(@"loadDataInTableView");
    
    NSError * error = nil;
    HTMLParser * myParser = [[HTMLParser alloc] initWithData:contentData error:&error];
    
    HTMLNode * bodyNode = [myParser body]; //Find the body tag
//    [self.textView setText:rawContentsOfNode([bodyNode _node], [myParser _doc])];
    
    //Check si pas déjà alerté
    HTMLNode * messagesNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO]; //Get all the <img alt="" />
    
    if ([messagesNode findChildTag:@"a"] || [messagesNode findChildTag:@"input"]) {
        // Post déjà alerté
        [HFRAlertView  DisplayOKAlertViewWithTitle:[[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] andMessage:nil handlerOK:^(UIAlertAction * action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
            [self.delegate alertModoViewControllerDidFinish:self];
        }];
    }
    else {
        HTMLNode * fastAnswerNode = [bodyNode findChildWithAttribute:@"action" matchingName:@"modo.php" allowPartial:YES];
        
        NSArray *temporaryAllInputArray = [fastAnswerNode findChildTags:@"input"];
        
        for (HTMLNode * inputallNode in temporaryAllInputArray) { //Loop through all the tags
            NSLog(@"inputallNode: %@ - value: %@", [inputallNode getAttributeNamed:@"name"], [inputallNode getAttributeNamed:@"value"]);
            
            if ([inputallNode getAttributeNamed:@"value"] && [inputallNode getAttributeNamed:@"name"]) {
                [self.arrayInputData setObject:[inputallNode getAttributeNamed:@"value"] forKey:[inputallNode getAttributeNamed:@"name"]];
            }
        }
        
        NSString *newSubmitForm = [[NSString alloc] initWithFormat:@"%@/user/%@", [k ForumURL], [fastAnswerNode getAttributeNamed:@"action"]];
        [self setFormSubmit:newSubmitForm];
    }
}
#pragma mark -
#pragma mark Action

- (IBAction)cancel {
    if ([self.textView text].length > 0 && ![self.textView.text isEqualToString:PLACEHOLDER]) {
        [HFRAlertView DisplayOKCancelAlertViewWithTitle:@"Attention !" andMessage:@"Vous allez perdre le contenu de votre alerte" handlerOK: ^(UIAlertAction * action ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
            [self.delegate alertModoViewControllerDidFinish:self];
        } handlerCancel:nil baseController:self];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
        [self.delegate alertModoViewControllerDidFinish:self];
    }

}

- (IBAction)done {
    //NSLog(@"done %@", self.formSubmit);
    
    ASIFormDataRequest  *arequest =
    [[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:self.formSubmit]];
    //delete
    NSString *key;
    for (key in self.arrayInputData) {
        //NSLog(@"POST: %@ : %@", key, [self.arrayInputData objectForKey:key]);
        [arequest setPostValue:[self.arrayInputData objectForKey:key] forKey:key];
    }
    
    NSString* txtTW = [[textView text] removeEmoji];
    txtTW = [txtTW stringByReplacingOccurrencesOfString:@"\n" withString:@"\r\n"];
    
    [arequest setPostValue:txtTW forKey:@"raison"];
    [arequest startSynchronous];
    
    if (arequest) {
        if ([arequest error]) {
            // Popup erreur
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ooops !"  message:[[arequest error] localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Retour" style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * action) { }];
            [alert addAction:actionCancel];
            [self presentViewController:alert animated:YES completion:nil];
            [[ThemeManager sharedManager] applyThemeToAlertController:alert];
        }
        else if ([arequest safeResponseString])
        {
            NSError * error = nil;
            HTMLParser *myParser = [[HTMLParser alloc] initWithString:[arequest safeResponseString] error:&error];
            HTMLNode * bodyNode = [myParser body]; //Find the body tag
            HTMLNode * messagesNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO]; //Get all the <img alt="" />
            
            [HFRAlertView DisplayAlertViewWithTitle:@"Hooray !" andMessage:[[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forDuration:(long)1 completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
                [self.delegate alertModoViewControllerDidFinishOK:self];
            }];
        }
    }
}

#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 777) {
        if (buttonIndex == 1) {
            [self fetchContent];
        }
        else {
            [self cancel];
        }
    }
    else if (buttonIndex == 1 && alertView.tag == 666) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
        [self.delegate alertModoViewControllerDidFinish:self];
    }
    else if (alertView.tag == 990) {
        NSLog(@"990");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
        [self.delegate alertModoViewControllerDidFinish:self];
    }
}

#pragma mark -
#pragma mark UITextView Delegate
- (void)textViewDidChange:(UITextView *)ftextView {
    
    if ([ftextView text].length > 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:PLACEHOLDER]) {
         textView.text = @"";
         textView.textColor = [ThemeColors cellTextColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = PLACEHOLDER;
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}


#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    //NSLog(@"keyboardWillShow ADD %@", notification);
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
//    NSLog(@"currentFrame %@", NSStringFromCGRect(accessoryView.frame));
//    NSLog(@"currentFrame %@", NSStringFromCGRect(newTextViewFrame));
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.accessoryView.frame = newTextViewFrame;
    
    [UIView commitAnimations];
    //[self.scrollViewer setContentSize:CGSizeMake(self.textView.frame.size.width, MAX(self.textView.frame.size.height, newTextViewFrame.size.height - segmentControler.frame.size.height - 5))];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    //NSLog(@"keyboardWillHide ADD");
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.accessoryView.frame = self.view.bounds;
    
    [UIView commitAnimations];
    //[self.scrollViewer setContentSize:CGSizeMake(self.textView.frame.size.width, MAX(self.textView.frame.size.height, self.view.bounds.size.height - segmentControler.frame.size.height - 5))];
    
}


#pragma mark -
#pragma mark Orientation
/* for iOS6 support */
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


#pragma mark -
#pragma mark Memory

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    self.loadingView = nil;
    
    self.textView.delegate = nil;
    self.textView = nil;
    
    self.accessoryView = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewDidUnload];
}

- (void)dealloc {
    //NSLog(@"dealloc ADD");
    
    [self.textView resignFirstResponder];
    [self viewDidUnload];
    
    [request setDelegate:nil];
    [request cancel];
    
    self.delegate = nil;
    
    
    
        
}

@end
