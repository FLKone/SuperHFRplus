//
//  AddMessageViewController.m
//  HFRplus
//
//  Created by FLK on 16/08/10.
//

#import "HFRplusAppDelegate.h"
#import "AddMessageViewController.h"
#import "SmileyViewController.h"
#import "RehostImageViewController.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import <QuartzCore/QuartzCore.h>
#import "NSData+Base64.h"
#import "RegexKitLite.h"
#import "RangeOfCharacters.h"
#import "UIMenuItem+CXAImageSupport.h"
#import "ThemeManager.h"
#import "ThemeColors.h"
#import "MultisManager.h"
#import "HFRAlertView.h"
#import "EditMessageViewController.h"
#import "ASIHTTPRequest+Tools.h"
#import "RehostCollectionCell.h"
#import "SmileyCache.h"
#import "api_keys.h"

#define TOOLBAR_HEIGHT 44

@import GiphyUISDK;
@import GiphyCoreSDK;


@implementation AddMessageViewController

@synthesize delegate, textView, sBrouillon, arrayInputData, formSubmit, accessoryView, viewToolbar, smileView, viewControllerSmileys, constraintSmileyViewHeight, constraintToolbarHeight;
@synthesize viewRehostImage, viewControllerRehostImage, constraintRehostImageViewHeight, request, loadingView, lastSelectedRange, loaded;
@synthesize segmentControler, isDragging, segmentControlerPage;
@synthesize btnToolbarImage, btnToolbarGIF, btnToolbarSmiley, btnToolbarUndo, btnToolbarRedo;
@synthesize haveTitle, textFieldTitle, haveTo, textFieldTo, haveCategory, textFieldCat;
@synthesize offsetY, selectCompte, selectedCompte;
@synthesize refreshAnchor, statusMessage;

#pragma mark - View lifecycle

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        //NSLog(@"initWithNibName add");
        
        self.arrayInputData = [[NSMutableDictionary alloc] init];
        self.formSubmit = [[NSString alloc] init];
        self.refreshAnchor = [[NSString alloc] init];
        
        self.loaded = NO;
        self.isDragging = NO;
        
        self.lastSelectedRange = NSMakeRange(NSNotFound, NSNotFound);
        
        self.haveCategory = NO;
        self.haveTitle = NO;
        self.haveTo	= NO;
        
        self.offsetY = 0;
            
        self.sBrouillon = [[NSUserDefaults standardUserDefaults] stringForKey:@"brouillon"];
        if (self.sBrouillon == nil) self.sBrouillon = [[NSString alloc] init];
        self.sBrouillonUtilise = NO;
        self.title = @"Nouv. message";
    }
    return self;
}

// was webViewDidStartLoad
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"didFinishNavigation");

    NSString *jsString = @"";
    
    jsString = [jsString stringByAppendingString:@"var hammertime = $('.button').hammer({ hold_timeout: 0.000001 }); \
                hammertime.on('touchstart touchend', function(ev) {\
                if(ev.type === 'touchstart'){\
                $(this).addClass('selected');\
                }\
                if(ev.type === 'touchend'){\
                $(this).removeClass('selected');\
                window.location = 'oijlkajsdoihjlkjasdosmile://internal?query='+encodeURIComponent(this.title).replace(/\\(/g, '%28').replace(/\\)/g, '%29');\
                }\
                });"];
    
    jsString = [jsString stringByAppendingString:@"var hammertime2 = $('#smileperso img.smile').hammer({ hold_timeout: 0.000001 }); \
                hammertime2.on('touchstart touchend', function(ev) {\
                if(ev.type === 'touchstart'){\
                $(this).addClass('selected');\
                }\
                if(ev.type === 'touchend'){\
                $(this).removeClass('selected');\
                window.location = 'oijlkajsdoihjlkjasdosmile://internal?query='+encodeURIComponent(this.alt).replace(/\\(/g, '%28').replace(/\\)/g, '%29');\
                }\
                });"];
    
    [webView evaluateJavaScript:jsString completionHandler:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"smileysviewExpanded"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"smileysviewExpanded"];
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //Bouton Annuler
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Annuler" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelBarItem;
    
    //Bouton Envoyer
    UIBarButtonItem *sendBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Envoyer" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = sendBarItem;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    
    [self.segmentControlerPage setEnabled:NO forSegmentAtIndex:0];
    [self.segmentControlerPage setWidth:40.0 forSegmentAtIndex:0];
    [self.segmentControlerPage setWidth:40.0 forSegmentAtIndex:2];
    [self.segmentControlerPage setEnabled:NO forSegmentAtIndex:2];
    
    self.smileView.navigationDelegate = self;

    self.viewControllerSmileys = [[SmileyViewController alloc] initWithNibName:@"SmileyViewController" bundle:nil];
    self.viewControllerSmileys.addMessageVC = self;
    self.viewControllerSmileys.view.frame = self.viewSmileys.bounds;
    UICollectionViewFlowLayout *collectionViewFlowLayout1 = [[UICollectionViewFlowLayout alloc] init];
    UICollectionViewFlowLayout *collectionViewFlowLayout2 = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewFlowLayout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.viewControllerSmileys.collectionViewSmileysDefault.collectionViewLayout = collectionViewFlowLayout1;
    self.viewControllerSmileys.collectionViewSmileysSearch.collectionViewLayout = collectionViewFlowLayout2;
    [self.viewSmileys addSubview:self.viewControllerSmileys.view];
    [self.viewSmileys setAlpha:0];
    [self addChildViewController:self.viewControllerSmileys];

    self.viewControllerRehostImage = [[RehostImageViewController alloc] initWithNibName:@"RehostImageViewController" bundle:nil];
    self.viewControllerRehostImage.addMessageVC = self;
    self.viewControllerRehostImage.view.frame = self.viewRehostImage.bounds;
    UICollectionViewFlowLayout *collectionViewFlowLayout3 = [[UICollectionViewFlowLayout alloc] init];
    collectionViewFlowLayout3.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.viewControllerRehostImage.collectionImages.collectionViewLayout = collectionViewFlowLayout3;
    [self.viewRehostImage addSubview:self.viewControllerRehostImage.view];
    [self.viewRehostImage setAlpha:0];
    [self addChildViewController:self.viewControllerRehostImage];

    [textFieldSmileys setHidden:YES];
    
    [Giphy configureWithApiKey:API_KEY_GIPHY verificationMode:false];
}

- (NSString*) getBrouillonExtract {
    int BROUILON_EXTRACT_LENGTH = 60;
    NSString *first20Char = nil;
    NSRange r1 = [self.sBrouillon rangeOfString:@"[quotemsg="];
    NSRange r2 = [self.sBrouillon rangeOfString:@"[/quotemsg]"];
    if (r1.location != NSNotFound && r2.location != NSNotFound) { // Test is quoted message to remove first quote
        if (r2.location + r2.length + BROUILON_EXTRACT_LENGTH <= self.sBrouillon.length ) {
            first20Char = [self.sBrouillon substringWithRange:NSMakeRange(r2.location + r2.length, BROUILON_EXTRACT_LENGTH)];
            first20Char = [first20Char stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            first20Char = [NSString stringWithFormat:@"[quotemsg(...)\n%@(...)",first20Char];
        }
        else {
            first20Char = [self.sBrouillon substringWithRange:NSMakeRange(r2.location + r2.length, self.sBrouillon.length - r2.location - r2.length )];
            first20Char = [first20Char stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            first20Char = [NSString stringWithFormat:@"[quotemsg(...)\n%@",first20Char];
        }
    }
    else
    {
        if (self.sBrouillon.length > BROUILON_EXTRACT_LENGTH) {
            first20Char = [self.sBrouillon substringToIndex:BROUILON_EXTRACT_LENGTH];
            first20Char = [first20Char stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            first20Char = [NSString stringWithFormat:@"%@(...)",first20Char];
        }
        else {
            first20Char = self.sBrouillon;
            first20Char = [first20Char stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    first20Char = [NSString stringWithFormat:@"\"%@\"",first20Char];
    return first20Char;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)initData { //- (void)viewDidLoad {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString *tempHTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"smileybase" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
    
    tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7"];
    
    [self.smileView loadHTMLString:[tempHTML stringByReplacingOccurrencesOfString:@"%SMILEYCUSTOM%"
                                                                       withString:[NSString stringWithFormat:@"<div id='smileperso'>%@</div>",
                                                                                   self.smileyCustom]] baseURL:baseURL];
    
    
    self.formSubmit = [NSString stringWithFormat:@"%@/bddpost.php", [k ForumURL]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(smileyReceived:) name:@"smileyReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReceived:) name:@"imageReceived" object:nil];
    
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // MULTIS
    MultisManager *manager = [MultisManager sharedManager];
    NSDictionary *mainCompte = [manager getMainCompte];
    [self onSelectedCompteChange:mainCompte];
    selectCompte.layer.cornerRadius = selectCompte.frame.size.width / 2;
    selectCompte.clipsToBounds = YES;
    selectCompte.layer.borderWidth = 1.0f;
    selectCompte.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [selectCompte addTarget:self action:@selector(selectCompteFn:) forControlEvents:UIControlEventTouchUpInside];
    selectCompte.enabled = ![[arrayInputData objectForKey:@"cat"] isEqualToString:@"prive"]; // Disable account switching for MP
    selectCompte.hidden = [[[MultisManager sharedManager] getComtpes] count] < 2;
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:@"SHOW"];
    
    [super viewWillAppear:animated];
    
    if(self.lastSelectedRange.location != NSNotFound)
    {
        self.textView.selectedRange = lastSelectedRange;
    }
    
    self.view.backgroundColor = self.loadingView.backgroundColor = self.accessoryView.backgroundColor = self.textView.backgroundColor = [ThemeColors addMessageBackgroundColor:[[ThemeManager sharedManager] theme]];
    self.loadingViewLabel.textColor = [ThemeColors cellTextColor:[[ThemeManager sharedManager] theme]];
    self.loadingViewIndicator.activityIndicatorViewStyle = [ThemeColors activityIndicatorViewStyle];
    self.textView.textColor = [ThemeColors textColor:[[ThemeManager sharedManager] theme]];
    NSInteger iSizeTextReply = [[NSUserDefaults standardUserDefaults] integerForKey:@"size_text_reply"];
    [self.textView setFont:[UIFont systemFontOfSize:iSizeTextReply]];

    if (self.segmentControler.tintColor == [UIColor whiteColor]) {

    } else {
        [self segmentToBlue];
    }
    
    Theme theme = [[ThemeManager sharedManager] theme];
    [self.btnToolbarImage  setImage:[ThemeColors tintImage:[UIImage imageNamed:@"photogallery2"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnToolbarImage setImage:[ThemeColors tintImage:[UIImage imageNamed:@"photogallery2"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnToolbarGIF  setImage:[ThemeColors tintImage:[UIImage imageNamed:@"gif"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnToolbarGIF setImage:[ThemeColors tintImage:[UIImage imageNamed:@"gif"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnToolbarSmiley setImage:[ThemeColors tintImage:[UIImage imageNamed:@"redface"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnToolbarSmiley setImage:[ThemeColors tintImage:[UIImage imageNamed:@"redface"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnToolbarUndo setImage:[ThemeColors tintImage:[UIImage imageNamed:@"undo-redo"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnToolbarUndo setImage:[ThemeColors tintImage:[UIImage imageNamed:@"undo-redo"] withTheme:theme] forState:UIControlStateHighlighted];
    [self.btnToolbarRedo setImage:[ThemeColors tintImage:[UIImage imageNamed:@"undo"] withTheme:theme] forState:UIControlStateNormal];
    [self.btnToolbarRedo setImage:[ThemeColors tintImage:[UIImage imageNamed:@"undo"] withTheme:theme] forState:UIControlStateHighlighted];

    [self.btnToolbarImage addTarget:self action:@selector(actionImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnToolbarGIF addTarget:self action:@selector(actionGIF:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnToolbarSmiley addTarget:self action:@selector(actionSmiley:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnToolbarUndo addTarget:self action:@selector(actionUndo:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnToolbarRedo addTarget:self action:@selector(actionRedo:) forControlEvents:UIControlEventTouchUpInside];
    [self enableDisableUndoButton];

    self.textView.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
    self.textFieldTitle.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
    self.textFieldTo.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
    self.textFieldCat.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
    [self.navigationController.navigationBar setTranslucent:NO];

    self.selectCompte.layer.borderColor = [ThemeColors tintColor:theme].CGColor;

    [self.viewControllerSmileys updateTheme];
    [self.viewControllerRehostImage updateTheme];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.sBrouillonUtilise = NO;
    // Popup brouillon (partout sauf en mode edition)
    if (self.sBrouillon && self.sBrouillon.length > 0) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Utiliser le brouillon ?" message:[self getBrouillonExtract]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* actionYes = [UIAlertAction actionWithTitle:@"Oui" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self.textView setText:self.sBrouillon];
                                                              self.sBrouillonUtilise = YES;
                                                              [self.navigationItem.rightBarButtonItem setEnabled:YES];
                                                          }];
        UIAlertAction* actionNo = [UIAlertAction actionWithTitle:@"Non" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) { }];
        UIAlertAction* actionDel = [UIAlertAction actionWithTitle:@"Supprimer" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) { [self modifyBrouillon:@""]; }];
        
        [alert addAction:actionYes];
        [alert addAction:actionNo];
        [alert addAction:actionDel];

        [self presentViewController:alert animated:YES completion:nil];
        [[ThemeManager sharedManager] applyThemeToAlertController:alert];
    }
}


#pragma mark - ScrollView delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewWillBeginDragging");
    self.isDragging = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"scrollViewDidEndDragging");
    if (!decelerate) {
        self.isDragging = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll");
    //self.scrollViewer.contentOffset = CGPointMake(self.scrollViewer.contentOffset.x, self.scrollViewer.contentOffset.y + 20);
    if (![self.textView isFirstResponder] && !self.isDragging) {
        //	//NSLog(@"contentOffset 1");
        self.textView.contentOffset = CGPointMake(0, self.offsetY);
    }
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewWillBeginDecelerating");
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidEndDecelerating");
    self.isDragging = NO;
    
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
    //NSLog(@"scrollViewDidEndScrollingAnimation");
    
    //[self.textView scrollRangeToVisible:self.textView.selectedRange];
    if (![self.textView isFirstResponder] && !self.isDragging) {
        //NSLog(@"contentOffset 2");
        
        self.textView.contentOffset = CGPointMake(0, self.offsetY);
    }
    
    
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)textViewDidChange:(UITextView *)ftextView
{
    if ([ftextView text].length > 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }
    
    CGRect line = [ftextView caretRectForPosition:ftextView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( ftextView.contentOffset.y + ftextView.bounds.size.height - ftextView.contentInset.bottom - ftextView.contentInset.top ) + self.offsetY;
    
    if ( overflow > 0 ) {
        //NSLog(@"overflow %f", overflow);
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = ftextView.contentOffset;
        
        //NSLog(@"offset %@", NSStringFromCGPoint(offset));
        offset.y += overflow + 7; // leave 7 pixels margin
        
        
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [ftextView setContentOffset:offset];
        }];
    }
    
    [self enableDisableUndoButton];
}

-(void)setupResponder {
    if (self.haveTo && ![[textFieldTo text] length]) {
        self.textFieldTo.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
        [self.textFieldTo becomeFirstResponder];
        self.btnToolbarUndo.enabled = false;
        self.btnToolbarUndo.enabled = false;
    }
    else if (self.haveTitle) {
        self.textFieldTitle.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
        [self.textFieldTitle becomeFirstResponder];
        self.btnToolbarUndo.enabled = false;
        self.btnToolbarUndo.enabled = false;
    }
    else {
        self.textView.keyboardAppearance = [ThemeColors keyboardAppearance:[[ThemeManager sharedManager] theme]];
        [self.textView becomeFirstResponder];
        [self enableDisableUndoButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    //NSLog(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}


- (IBAction)cancel {
    if (self.viewControllerRehostImage.bModeFullScreen && self.viewControllerRehostImage.tableViewImages.alpha == 1 && ![self.textView isFirstResponder]) {
        [self actionHideRehostImage];
    } else if (self.viewControllerSmileys.tableViewSearch.alpha == 1 && ![self.textView isFirstResponder]) {
        [self actionHideSmileys];
    }  else if (![self.textView isFirstResponder] && self.viewControllerSmileys.bModeFullScreen && (self.viewControllerSmileys.collectionViewSmileysSearch.alpha == 1 || self.viewControllerSmileys.collectionViewSmileysDefault.alpha == 1)) {
        [self actionHideSmileys];
    } else if ([self.textView text].length > 0 && !self.isDeleteMode) {
        NSString *alertTitle = @"Enregistrer le texte comme brouillons ?";
        NSString *messageBrouillon=nil;
        BOOL remplacerBrouillon = NO;
        if (self.sBrouillon.length > 0) {
            alertTitle = @"Remplacer le brouillon ?";
            messageBrouillon = [self getBrouillonExtract];
            remplacerBrouillon = YES;
        }
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
                                                                       message:messageBrouillon
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Oui" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self modifyBrouillon:[self.textView text]];
                                                                  [self finishMe];
                                                              }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"Non" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                if (!remplacerBrouillon) [self modifyBrouillon:@""];
                                                                  [self finishMe];
                                                              }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 [self.textView becomeFirstResponder];
                                                             }];

        [alert addAction:yesAction];
        [alert addAction:noAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:^{}];
        [[ThemeManager sharedManager] applyThemeToAlertController:alert];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
        [self.delegate addMessageViewControllerDidFinish:self];
    }
}

- (void)modifyBrouillon:(NSString*) sNewText {
    self.sBrouillon = sNewText;
    [[NSUserDefaults standardUserDefaults] setObject:sNewText forKey:@"brouillon"];
}

-(void)resignAll {
    [self.textView endEditing:YES];
    [self.textFieldTitle endEditing:YES];
    [self.textFieldTo endEditing:YES];
    [self.view endEditing:YES];
}

-(void)finishMe {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
    [self.delegate addMessageViewControllerDidFinish:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 666) {
        [self finishMe];
    }
    else if (buttonIndex == 0 && alertView.tag == 666) {
        [self.textView becomeFirstResponder];
    }
}

-(bool)isDeleteMode {
    NSLog(@"IS DELETE? IN");
    return NO;
}

- (IBAction)done {
    NSLog(@"formSubmit:%@", self.formSubmit);
    
    ASIFormDataRequest  *arequest =
    [[ASIFormDataRequest  alloc]  initWithURL:[NSURL URLWithString:self.formSubmit]];
    //delete
    NSString *key;
    for (key in self.arrayInputData) {
        if ([key isEqualToString:@"allowvisitor"] || [key isEqualToString:@"have_sondage"] || [key isEqualToString:@"sticky"] || [key isEqualToString:@"sticky_everywhere"]) {
            if ([[self.arrayInputData objectForKey:key] isEqualToString:@"1"]) {
                [arequest setPostValue:[self.arrayInputData objectForKey:key] forKey:key];
                NSLog(@"POST: >%@< : >%@<", key, [self.arrayInputData objectForKey:key]);
            }
        }
        else if ([key isEqualToString:@"delete"]) {
            if ([self isDeleteMode]) {
                [arequest setPostValue:@"1" forKey:key];
            }
        }
        else if ([key isEqualToString:@"pseudo"]) {
                [arequest setPostValue:[selectedCompte objectForKey:PSEUDO_DISPLAY_KEY] forKey:@"pseudo"];
                NSLog(@"POST: >%@< : >%@<", @"pseudo", [selectedCompte objectForKey:PSEUDO_DISPLAY_KEY]);
        }else if ([key isEqualToString:@"hash_check"]) {
            if([selectedCompte objectForKey:HASH_KEY]){
                [arequest setPostValue:[selectedCompte objectForKey:HASH_KEY] forKey:@"hash_check"];
                NSLog(@"POST: >%@< : >%@<", @"hash_check", [selectedCompte objectForKey:HASH_KEY]);
            }else{
                [arequest setPostValue:[[HFRplusAppDelegate sharedAppDelegate] hash_check] forKey:@"hash_check"];
                NSLog(@"POST: >%@< : >%@<", @"hash_check", [[HFRplusAppDelegate sharedAppDelegate] hash_check]);

                // Set hash_check for compte
                [[MultisManager sharedManager] setHashForCompte:selectedCompte andHash:[[HFRplusAppDelegate sharedAppDelegate] hash_check]];
            }
        }
        else {
            [arequest setPostValue:[self.arrayInputData objectForKey:key] forKey:key];
            NSLog(@"POST: >%@< : >%@<", key, [self.arrayInputData objectForKey:key]);
        }
    }
    
    NSString* txtTW = [[textView text] removeEmoji];
    txtTW = [txtTW stringByReplacingOccurrencesOfString:@"\n" withString:@"\r\n"];
    
    [arequest setPostValue:txtTW forKey:@"content_form"];
    NSLog(@"POST: >%@< : >%@<", @"content_form", txtTW);
    if (self.haveTitle) {
        [arequest setPostValue:[textFieldTitle text] forKey:@"sujet"];
        NSLog(@"POST: >%@< : >%@<", @"sujet", [textFieldTitle text]);
    }
    if (self.haveCategory) {
        [arequest setPostValue:[textFieldCat text] forKey:@"subcat"];
        NSLog(@"POST: >%@< : >%@<", @"subcat", [textFieldCat text]);
    }
    if (self.haveTo) {
        [arequest setPostValue:[textFieldTo text] forKey:@"dest"];
        NSLog(@"POST: >%@< : >%@<", @"dest", [textFieldTo text]);
    }
    
    // Set selected compte cookies
    [arequest setUseCookiePersistence:NO];
    [arequest setRequestCookies:[selectedCompte objectForKey:COOKIES_KEY]];
    [arequest startSynchronous];
    
        if ([arequest error]) {
        [HFRAlertView DisplayOKAlertViewWithTitle:@"Ooops !" andMessage:@"Erreur de connexion..."];
        }
        else if ([arequest safeResponseString])
        {
        @try {
            // Set main compte cookies
            [[MultisManager sharedManager] forceCookiesForCompte:[[MultisManager sharedManager] getMainCompte]];
            
            NSError * error = nil;
            HTMLParser *myParser = [[HTMLParser alloc] initWithString:[arequest safeResponseString] error:&error];
            HTMLNode * bodyNode = [myParser body]; //Find the body tag
            HTMLNode * messagesNode = [bodyNode findChildWithAttribute:@"class" matchingName:@"hop" allowPartial:NO]; //Get all the <img alt="" />
            
            if ([messagesNode findChildTag:@"a"] || [messagesNode findChildTag:@"input"]) {
                [HFRAlertView DisplayOKAlertViewWithTitle:[[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] andMessage:nil];
            }
            else {
                // On efface automatiquement le brouillon quand il a été utilisé et que le post du message est OK
                if (self.sBrouillonUtilise) {
                    [self modifyBrouillon:@""];
                }
                
                [self resignAll];
                self.statusMessage = [[messagesNode contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [self setRefreshAnchor:@""];
                NSArray * urlArray;

                // On regarde si on doit pas positionner le scroll sur un topic
                if ([self isDeleteMode]) {
                    //recup de l'ID du message supprimé pour positionner le scroll.
                    urlArray = [((QuoteMessageViewController *)self).urlQuote arrayOfCaptureComponentsMatchedByRegex:@"numreponse=([0-9]+)&"];
                }
                else {
                    urlArray = [[arequest safeResponseString] arrayOfCaptureComponentsMatchedByRegex:@"<meta http-equiv=\"Refresh\" content=\"[^#]+([^\"]*)\" />"];
                }
                
                if (urlArray.count > 0) {
                    if ([[[urlArray objectAtIndex:0] objectAtIndex:1] length] > 0) {
                        [self setRefreshAnchor:[[urlArray objectAtIndex:0] objectAtIndex:1]];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VisibilityChanged" object:nil];
                [self.delegate addMessageViewControllerDidFinishOK:self];
            }
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
            [HFRAlertView DisplayOKAlertViewWithTitle:@"Ooops !" andMessage:@"Erreur de réponse du serveur. Votre message a peut être été posté malgré tout."];
        }
        @finally {}
    }
    
}

-(void)segmentToWhite {
    self.segmentControler.tintColor = [UIColor whiteColor];
    self.segmentControlerPage.tintColor = [UIColor whiteColor];
}

-(void)segmentToBlue {
    if (@available(iOS 13.0, *)) {
        [self.segmentControler setTitleTextAttributes:@{NSForegroundColorAttributeName: [ThemeColors tintColor:[[ThemeManager sharedManager] theme]], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
        [self.segmentControler setTitleTextAttributes:@{NSForegroundColorAttributeName: [ThemeColors cellBorderColor:[[ThemeManager sharedManager] theme]], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateDisabled];
        [self.segmentControlerPage setTitleTextAttributes:@{NSForegroundColorAttributeName: [ThemeColors tintColor:[[ThemeManager sharedManager] theme]], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
        [self.segmentControlerPage setTitleTextAttributes:@{NSForegroundColorAttributeName: [ThemeColors cellBorderColor:[[ThemeManager sharedManager] theme]], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateDisabled];
        [self.segmentControler setSelectedSegmentTintColor:[ThemeColors tintColor:[[ThemeManager sharedManager] theme]]];
        [self.segmentControlerPage setSelectedSegmentTintColor:[ThemeColors tintColor:[[ThemeManager sharedManager] theme]]];
    } else {
        self.segmentControler.tintColor = self.segmentControlerPage.tintColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];
    }
}

- (void)actionImage:(id)sender
{
    NSLog(@"actionImage");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    if (self.viewSmileys.alpha == 1) {
        [self actionHideSmileys];
    }
    if (self.viewRehostImage.alpha == 0) {
        bool bExpanded = [[NSUserDefaults standardUserDefaults] boolForKey:@"rehostimageviewExpanded"];
        if (self.viewControllerRehostImage.bModeFullScreen != bExpanded) {
            [self actionExpandCompressRehostImage];
        }
        if (self.viewControllerRehostImage.bModeFullScreen) {
            [self.view endEditing:YES];
        }
        [self.viewRehostImage setAlpha:1];
        [self updateExpandCompressRehostImage];
        [UIView commitAnimations];
    }
    else {
        [self actionHideRehostImage];
    }
}

- (void)actionHideRehostImage
{
    NSLog(@"actionHideSmileys");

    // Memorize last state
    [[NSUserDefaults standardUserDefaults] setBool:self.viewControllerRehostImage.bModeFullScreen forKey:@"rehostimageviewExpanded"];
    // Minimize before hidden
    self.viewControllerRehostImage.bModeFullScreen = NO;
    [self.viewRehostImage setAlpha:0];
    [self updateExpandCompressRehostImage];
    [UIView commitAnimations];
    [self.textView becomeFirstResponder];
}

- (void)actionExpandCompressRehostImage
{
    NSLog(@"actionExpandCompressSmiley");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    self.viewControllerRehostImage.bModeFullScreen = !self.viewControllerRehostImage.bModeFullScreen;
    if (self.viewControllerRehostImage.bModeFullScreen) {
        [self.view endEditing:YES];
        [self.viewControllerRehostImage.tableViewImages setAlpha:1];
        [self.viewControllerRehostImage.collectionImages setAlpha:0];
        [viewToolbar setHidden:YES];
        self.constraintToolbarHeight.constant = 0;
    }
    [self updateExpandCompressRehostImage];
    if (!self.viewControllerRehostImage.bModeFullScreen) {
        [self.viewControllerRehostImage.tableViewImages setAlpha:0];
        [self.viewControllerRehostImage.collectionImages setAlpha:1];
        [viewToolbar setHidden:NO];
        self.constraintToolbarHeight.constant = TOOLBAR_HEIGHT;
        [self.textView becomeFirstResponder];
    }
    [UIView commitAnimations];
}

- (void)updateExpandCompressRehostImage
{
    NSLog(@"updateExpandCompressRehostImage");
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[self.viewControllerRehostImage.collectionImages collectionViewLayout];
    if (self.viewControllerRehostImage.bModeFullScreen) {
        CGRect rectS = self.viewRehostImage.frame;
        CGFloat f = rectS.size.height + rectS.origin.y;
        self.constraintRehostImageViewHeight.constant = f + TOOLBAR_HEIGHT;
        self.constraintToolbarHeight.constant = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    else {
        [viewToolbar setHidden:NO];
        self.constraintToolbarHeight.constant = TOOLBAR_HEIGHT;
        self.constraintRehostImageViewHeight.constant = [self.viewControllerRehostImage getDisplayHeight];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    [self.viewControllerRehostImage updateExpandButton];
}

- (void)actionGIF:(id)sender
{
    self.giphyViewController = [[GiphyViewController alloc] init];
    //giphy.layout = GPHGridLayoutWaterfall;
    self.giphyViewController.theme = [[GPHTheme alloc] init];
    if ([[ThemeManager sharedManager] theme] == ThemeLight) {
        self.giphyViewController.theme.type = GPHThemeTypeLight;
    }
    else {
        self.giphyViewController.theme.type = GPHThemeTypeDarkBlur;
    }
    self.giphyViewController.rating = GPHRatingTypeRatedR;
    self.giphyViewController.delegate = self;
    self.giphyViewController.showConfirmationScreen = true;
    [self.giphyViewController setMediaConfigWithTypes: [[NSMutableArray alloc] initWithObjects: @(GPHContentTypeGifs), @(GPHContentTypeRecents), nil]];
    [self presentViewController:self.giphyViewController animated:true completion:nil];
    if (self.viewSmileys.alpha == 1) {
        [self actionHideSmileys];
    }
    if (self.viewRehostImage.alpha == 1) {
        [self actionHideRehostImage];
    }
}

- (void) didSelectMediaWithGiphyViewController:(GiphyViewController *)giphyViewController media:(GPHMedia *)media
{
    NSString* sTextToAdd = [NSString stringWithFormat:@"[img]%@[/img]\n", media.images.original.gifUrl];
    NSRange range = [self lastSelectedRange];
    if ([self.textView isFirstResponder]) {
        range = self.textView.selectedRange;
    }
    if (!range.location) {
        range = NSMakeRange(0, 0);
    }
    NSMutableString *text = [self.textView.text mutableCopy];
    if (text.length < range.location) {
        range.location = text.length;
    }
    [text insertString:sTextToAdd atIndex:range.location];
    range.location += [sTextToAdd length];
    range.length = 0;
    [self setLastSelectedRange:range];
    self.textView.text = text;
    self.textView.selectedRange = range;
    [self textViewDidChange:self.textView];
    [self dismissViewControllerAnimated:self.giphyViewController completion:nil];
}

- (void) didDismissWithController:(GiphyViewController *)controller {
    NSLog(@"");
}

- (void)actionSmiley:(id)sender
{
    NSLog(@"actionSmiley");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    if (self.viewSmileys.alpha == 0) {
        if (self.viewRehostImage.alpha == 1) {
            [self actionHideRehostImage];
        }
        /*
        self.viewControllerSmileys.bModeFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:@"smileysviewExpanded"];
        if (self.viewControllerSmileys.bModeFullScreen) {
            [self.view endEditing:YES];
        }
        [self.viewSmileys setAlpha:1];
        [self updateExpandCompressSmiley];
        [UIView commitAnimations];*/
        
        bool bExpanded = [[NSUserDefaults standardUserDefaults] boolForKey:@"smileysviewExpanded"];
        if (self.viewControllerSmileys.bModeFullScreen != bExpanded) {
            [self actionExpandCompressSmiley];
        }
        if (self.viewControllerSmileys.bModeFullScreen) {
            [self.view endEditing:YES];
        }
        [self.viewSmileys setAlpha:1];
        [self updateExpandCompressSmiley];
        [UIView commitAnimations];

    }
    else {
        [self actionHideSmileys];
    }
}

- (void)actionHideSmileys
{
    // Memorize last state
    [[NSUserDefaults standardUserDefaults] setBool:self.viewControllerSmileys.bModeFullScreen forKey:@"smileysviewExpanded"];
    // Minimize before hidden
    self.viewControllerSmileys.bModeFullScreen = NO;
    [self.viewSmileys setAlpha:0];
    [self updateExpandCompressSmiley];
    [UIView commitAnimations];
    [self.textView becomeFirstResponder];
}

- (void)actionExpandCompressSmiley
{
    if (self.viewControllerSmileys.displayMode!= DisplayModeEnumTableSearch) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        self.viewControllerSmileys.bModeFullScreen = !self.viewControllerSmileys.bModeFullScreen;
        if (self.viewControllerSmileys.bModeFullScreen) {
            [self.view endEditing:YES];
        }
        [self updateExpandCompressSmiley];
        [UIView commitAnimations];
        if (!self.viewControllerSmileys.bModeFullScreen) {
            [self.textView becomeFirstResponder];
        }
    }
}

- (void)updateExpandCompressSmiley
{
    NSLog(@"updateExpandCompressSmiley");
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[self.viewControllerSmileys.collectionViewSmileysDefault collectionViewLayout];
    UICollectionViewFlowLayout *layout2 = (UICollectionViewFlowLayout *)[self.viewControllerSmileys.collectionViewSmileysSearch collectionViewLayout];
    if (self.viewControllerSmileys.displayMode == DisplayModeEnumTableSearch) {
        CGRect rectS = self.viewSmileys.frame;
        CGFloat f = rectS.size.height + rectS.origin.y;
        self.constraintSmileyViewHeight.constant = f;
        [viewToolbar setHidden:NO];
        self.constraintToolbarHeight.constant = TOOLBAR_HEIGHT;
        NSLog(@"mode DisplayModeEnumTableSearch, constraintSmileyViewHeight.constant = %f", f);
        //layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        //layout2.scrollDirection = UICollectionViewScrollDirectionVertical;
        [self.viewControllerSmileys.btnReduce setEnabled:NO];
    }
    else if (self.viewControllerSmileys.bModeFullScreen) {
        [self.viewControllerSmileys.btnReduce setEnabled:YES];

        CGRect rectS = self.viewSmileys.frame;
        CGFloat f = rectS.size.height + rectS.origin.y;
        self.constraintSmileyViewHeight.constant = f + TOOLBAR_HEIGHT;
        NSLog(@"mode viewControllerSmileys.bModeFullScreen, constraintSmileyViewHeight.constant = %f", f);
        [viewToolbar setHidden:YES];
        self.constraintToolbarHeight.constant = 0;

        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout2.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    else {
        [self.viewControllerSmileys.btnReduce setEnabled:YES];

        //self.constraintToolbarHeight.constant = 0;
        [viewToolbar setHidden:NO];
        self.constraintToolbarHeight.constant = TOOLBAR_HEIGHT;

        self.constraintSmileyViewHeight.constant = [self.viewControllerSmileys getDisplayHeight];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    [self.viewControllerSmileys updateExpandButton];
}

- (IBAction)actionUndo:(id)sender
{
    [self.textView.undoManager undo];
    [self enableDisableUndoButton];
}

- (IBAction)actionRedo:(id)sender
{
    [self.textView.undoManager redo];
    [self enableDisableUndoButton];
}

// to disable or enable the button when needed
- (void)enableDisableUndoButton
{
    if (self.textView.undoManager.canUndo) {
        self.btnToolbarUndo.enabled = true;
    } else {
        self.btnToolbarUndo.enabled = false;
    }
    if (self.textView.undoManager.canRedo) {
        self.btnToolbarRedo.enabled = true;
    } else {
        self.btnToolbarRedo.enabled = false;
    }
}

#pragma mark - TextView Mod

- (void) smileyReceived: (NSNotification *) notification {
    [self.textView.undoManager registerUndoWithTarget:self
                                    selector:@selector(undoTextFieldEdit:)
                                      object:self.textView.text];
    [self enableDisableUndoButton];

    NSMutableString *text = [textView.text mutableCopy];
    
    if (!lastSelectedRange.location) {
        lastSelectedRange = NSMakeRange(0, 0);
    }
    
    if (text.length < lastSelectedRange.location) {
        lastSelectedRange.location = text.length;
    }
    
    [text insertString:[notification object] atIndex:lastSelectedRange.location];
    
    lastSelectedRange.location += [[notification object] length];
    textView.text = text;
    
    self.loaded = YES;
    [self actionHideRehostImage];

    [self textViewDidChange:self.textView];
}

- (void) imageReceived: (NSNotification *) notification
{
    [self.textView.undoManager registerUndoWithTarget:self
                                    selector:@selector(undoTextFieldEdit:)
                                      object:self.textView.text];
    [self enableDisableUndoButton];

    NSMutableString *text = [textView.text mutableCopy];
    if (!lastSelectedRange.location) {
        lastSelectedRange = NSMakeRange(0, 0);
    }
    
    if (text.length < lastSelectedRange.location) {
        lastSelectedRange.location = text.length;
    }
    
    [text insertString:[notification object] atIndex:lastSelectedRange.location];
    
    lastSelectedRange.location += [[notification object] length];
    lastSelectedRange.location += [text length];
    lastSelectedRange.length = 0;
    
    textView.text = text;

    [self textViewDidChange:self.textView];
}

- (void)undoTextFieldEdit: (NSString*)string
{
    NSLog(@"Undoing with %@", string);
    [self.textView.undoManager registerUndoWithTarget:self
                                    selector:@selector(undoTextFieldEdit:)
                                      object:self.textView.text];
    self.textView.text = string;
}

#pragma mark - Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    //NSLog(@"textViewShouldBeginEditing");
    
    if(lastSelectedRange.location != NSNotFound)
    {
        textView.selectedRange = lastSelectedRange;
    }
    
    
    return YES;
    
    /*
     You can create the accessory view programmatically (in code), in the same nib file as the view controller's main view, or from a separate nib file. This example illustrates the latter; it means the accessory view is loaded lazily -- only if it is required.
     */
    
    if (textView.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"AccessoryView" owner:self options:nil];
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textView.inputAccessoryView = accessoryView;
        
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.accessoryView = nil;
    }
    
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    //NSLog(@"textViewShouldEndEditing");
    
    if(self.loaded)
    {
        //NSLog(@"textViewShouldEndEditing NO");
        self.loaded = NO;
        return NO;
    }
    
    self.lastSelectedRange = textView.selectedRange;
    
    [textView resignFirstResponder];
    //NSLog(@"textViewShouldEndEditing YES");
    
    return YES;
}

#pragma mark - Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    if (!self.viewControllerSmileys.bModeFullScreen || self.viewControllerSmileys.bActivateSmileySearchTable) {
        [self resizeViewWithKeyboard:notification];
    }
    if (self.viewControllerSmileys.bActivateSmileySearchTable) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [self.viewControllerSmileys changeDisplayMode:DisplayModeEnumTableSearch animate:NO];
        [self updateExpandCompressSmiley];
        [UIView commitAnimations];
        self.viewControllerSmileys.bActivateSmileySearchTable = NO;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"ADD :::: Hide");
    [self resizeViewWithKeyboard:notification];
}

- (void)resizeViewWithKeyboard:(NSNotification *)notification {
    NSLog(@"resizeViewWithKeyboard");

    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedKeyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];
    CGRect safeAreaFrame = CGRectInset(self.view.safeAreaLayoutGuide.layoutFrame, 0, -self.additionalSafeAreaInsets.bottom);
    CGRect intersection = CGRectIntersection(safeAreaFrame, convertedKeyboardRect);

    NSLog(@"### keyboardRect rect %@", NSStringFromCGRect(convertedKeyboardRect));
    NSLog(@"### safeAreaFrame rect %@", NSStringFromCGRect(safeAreaFrame));
    NSLog(@"### intersection rect %@", NSStringFromCGRect(intersection));

    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, intersection.size.height, 0);
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField != textFieldSmileys) {
        [self.btnToolbarImage setEnabled:NO];
        [self.btnToolbarGIF setEnabled:NO];
        [self.btnToolbarSmiley setEnabled:NO];
        [textFieldSmileys setEnabled:NO];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //NSLog(@"textFieldDidEndEditing %@", textField);
    
    //[segmentControler setEnabled:YES forSegmentAtIndex:0];
    //[segmentControler setEnabled:YES forSegmentAtIndex:1];
    [self.btnToolbarImage setEnabled:YES];
    [self.btnToolbarGIF setEnabled:YES];
    [self.btnToolbarSmiley setEnabled:YES];

    [textFieldSmileys setEnabled:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //NSLog(@"textFieldShouldReturn");
    
    //[textField resignFirstResponder];
    if (textField == self.textFieldTo) {
        [self.textFieldTitle becomeFirstResponder];
    }
    else if (textField == self.textFieldTitle)
    {
        [self.textView becomeFirstResponder];
    }
    //
    return NO;
    
}

#pragma mark - Multis

- (void)selectCompteFn:(id)sender {
    NSLog(@"SELECT");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choisir un compte" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    NSArray *comptes = [[MultisManager sharedManager] getComtpes];
    for (int j =0 ; j<comptes.count; j++)
    {
        NSString *titleString = [comptes[j] objectForKey:PSEUDO_DISPLAY_KEY];
        UIAlertAction * action = [UIAlertAction actionWithTitle:titleString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self onSelectCompte:j];
        }];
        [alert addAction:action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    
    
    [alert setValue:[[NSAttributedString alloc] initWithString:@"Choisir un compte"
                                                    attributes:@{
                                                                 NSForegroundColorAttributeName: [ThemeColors placeholderColor:[[ThemeManager sharedManager] theme]]
                                                                 }
                     ] forKey:@"attributedTitle"];
    

    [self presentViewController:alert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}

- (void)onSelectCompte:(int)index{
    NSArray *comptes = [[MultisManager sharedManager] getComtpes];
    [self onSelectedCompteChange:[comptes objectAtIndex:index]];
}

- (void)onSelectedCompteChange:(NSDictionary *)newSelectedCompte {
    MultisManager *manager = [MultisManager sharedManager];
    selectedCompte = newSelectedCompte;
    [selectCompte setImage:[manager getAvatarForCompte:selectedCompte] forState:UIControlStateNormal];
}
@end
