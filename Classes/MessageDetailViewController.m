//
//  MessageDetailViewController.m
//  HFRplus
//
//  Created by FLK on 10/07/10.
//

#import "HFRplusAppDelegate.h"

#import "MessageDetailViewController.h"
#import "MessagesTableViewController.h"
#import "RangeOfCharacters.h"
#import "ASIHTTPRequest.h"
#import "RegexKitLite.h"

#import "LinkItem.h"
#import "ThemeManager.h"
#import "ThemeColors.h"

@implementation MessageDetailViewController
@synthesize messageView, messageAuthor, messageDate, authorAvatar, messageTitle, messageTitleString, messageAvatar;
@synthesize pageNumber, curMsg, arrayData;
@synthesize parent, defaultTintColor, messagesTableViewController;
@synthesize toolbarBtn, quoteBtn, editBtn, actionBtn, arrayAction, styleAlert;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		//NSLog(@"initWithNibName");
		
		self.arrayAction = [[NSMutableArray alloc] init];
		
		self.actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																  target:self 
                                                                       action:@selector(ActionList:)];
		self.actionBtn.style = UIBarButtonItemStyleBordered;
		
		
		self.quoteBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
																target:self 
																action:@selector(QuoteMessage)];
		self.quoteBtn.style = UIBarButtonItemStyleBordered;

		self.editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
																target:self 
																action:@selector(EditMessage)];
		self.editBtn.style = UIBarButtonItemStyleBordered;
		
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.actionBtn.tintColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];
            self.quoteBtn.tintColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];
            self.editBtn.tintColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];
        }

    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView;
	
	// Before we show this view make sure the segmentedControl matches the nav bar style
	//if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent ||
	//	self.navigationController.navigationBar.barStyle == UIBarStyleBlackOpaque)
    

    
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //segmentedControl.tintColor = defaultTintColor;
    }
    else {
        if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            segmentedControl.tintColor = [UIColor colorWithRed:144/255.f green:152/255.f blue:159/255.f alpha:0.51];
        }


    }
    self.messageView.opaque = NO;
    self.messageView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [ThemeColors addMessageBackgroundColor:[[ThemeManager sharedManager] theme]];
}

-(void)setupData
{
	//NSLog(@"curmsg");
	//NSLog(@"curmsg %d - arraydata %d", curMsg, arrayData.count);
	

    
	if (curMsg > 0) {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:YES forSegmentAtIndex:0];

	}
	else {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:0];

	}

	
	if(curMsg < arrayData.count - 1)
	{
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:YES forSegmentAtIndex:1];

	}
	else {
		[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:1];
		
	}
    
    [[self.parent messagesWebView] evaluateJavaScript:[NSString stringWithFormat:@"window.scrollTo(0,document.getElementById('%@').offsetTop);", [(LinkItem*)[arrayData objectAtIndex:curMsg] postID]] completionHandler:nil];

    NSString *myRawContent = [[arrayData objectAtIndex:curMsg] dicoHTML];
    if ([[arrayData objectAtIndex:curMsg] quotedNB]) {
        myRawContent = [myRawContent stringByAppendingString:[NSString stringWithFormat:@"<a class=\"quotedhfrlink\" href=\"%@\">%@</a>", [[arrayData objectAtIndex:curMsg] quotedLINK], [[arrayData objectAtIndex:curMsg] quotedNB]]];
    }
    if ([[arrayData objectAtIndex:curMsg] editedTime ]) {
        myRawContent = [myRawContent stringByAppendingString:[NSString stringWithFormat:@"<br/><p class=\"editedhfrlink\">édité par %@</p>", [[arrayData objectAtIndex:curMsg] editedTime]]];
    }
    
    myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"---------------" withString:@""];
    
    // Add link to img
    //External Images
    NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";
    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
                                                          withString:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"$1\" alt=\"$1\" longdesc=\"\">"];
    
    NSString *customFontSize = [self userTextSizeDidChange];
   
    NSString *doubleSmileysCSS = @"";
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_smileys"] isEqualToString:@"double"]) {
        doubleSmileysCSS = @".smileycustom {max-height:45px;}";
    }

    
    Theme theme = [[ThemeManager sharedManager] theme];
    
    // Default value for light theme
    NSString *sAvatarImageFile = @"url(avatar_male_gray_on_light_48x48.png)";
    NSString *sLoadInfoImageFile = @"url(loadinfo.gif)";
    NSString* sBorderHeader = @"none";
    
    // Modified in theme Dark or OLED
    switch (theme) {
        case ThemeDark:
            sAvatarImageFile = @"url(avatar_male_gray_on_dark_48x48.png)";
            sLoadInfoImageFile = @"url(loadinfo-white@2x.gif)";
            // For OLED only
            // sBorderHeader = @"1px solid #505050";
            break;
        case ThemeLight:
            break;
    }
    
    NSString* sCssStyle = @"style-liste.css";
    /*
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"theme_style"] == 1) {
        sCssStyle = @"style-liste-light.css";
    }*/

	NSString *HTMLString = [NSString stringWithFormat:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\
        <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" lang=\"fr\">\
        <head>\
        <meta name='viewport' content='initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=0' />\
        <script type='text/javascript' src='jquery-2.1.1.min.js'></script>\
        <link type='text/css' rel='stylesheet' href='%@' id='light-styles'/>\
        <style type='text/css'>\
        %@\
        </style>\
        <style id='smileys_double' type='text/css'>\
        %@\
        </style>\
        </head><body class='iosversion'><div class='bunselected maxmessage' id='qsdoiqjsdkjhqkjhqsdqdilkjqsd2'><div class='message' id='1'><div class='content'><div class='right'>%@</div></div></div></div></body></html><script type='text/javascript'>\
        document.addEventListener('DOMContentLoaded', loadedML);\
        function loadedML() { document.location.href = 'oijlkajsdoihjlkjasdoloaded://loaded'; };\
        function HLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bselected'; } function UHLtxt() { var el = document.getElementById('qsdoiqjsdkjhqkjhqsdqdilkjqsd');el.className='bunselected'; } function swap_spoiler_states(obj){var div=obj.getElementsByTagName('div');if(div[0]){if(div[0].style.visibility==\"visible\"){div[0].style.visibility='hidden';}else if(div[0].style.visibility==\"hidden\"||!div[0].style.visibility){div[0].style.visibility='visible';}}};\
                    $('img').error(function(){var failingSrc = $(this).attr('src');if(failingSrc.indexOf('https://reho.st')>-1){$(this).attr('src', 'photoDefaultClic.png')}else{$(this).attr('src', 'photoDefaultfailmini.png');}});\
            document.documentElement.style.setProperty('--color-action', '%@');\
            document.documentElement.style.setProperty('--color-action-disabled', '%@');\
            document.documentElement.style.setProperty('--color-message-background', '%@');\
            document.documentElement.style.setProperty('--color-message-modo-background', '%@');\
            document.documentElement.style.setProperty('--color-message-header-me-background', '%@');\
            document.documentElement.style.setProperty('--color-message-mequoted-background', '%@');\
            document.documentElement.style.setProperty('--color-message-mequoted-borderleft', '%@');\
            document.documentElement.style.setProperty('--color-message-mequoted-borderother', '%@');\
            document.documentElement.style.setProperty('--color-message-header-love-background', '%@');\
            document.documentElement.style.setProperty('--color-message-quoted-love-background', '%@');\
            document.documentElement.style.setProperty('--color-message-quoted-love-borderleft', '%@');\
            document.documentElement.style.setProperty('--color-message-quoted-love-borderother', '%@');\
            document.documentElement.style.setProperty('--color-message-quoted-bl-background', '%@');\
            document.documentElement.style.setProperty('--color-message-header-bl-background', '%@');\
            document.documentElement.style.setProperty('--color-separator-new-message', '%@');\
            document.documentElement.style.setProperty('--color-text', '%@');\
            document.documentElement.style.setProperty('--color-text2', '%@');\
            document.documentElement.style.setProperty('--color-background-bars', '%@');\
            document.documentElement.style.setProperty('--color-searchintra-nextresults', '%@');\
            document.documentElement.style.setProperty('--imagefile-avatar', '%@');\
            document.documentElement.style.setProperty('--imagefile-loadinfo', '%@');\
            document.documentElement.style.setProperty('--color-border-quotation', '%@');\
            document.documentElement.style.setProperty('--color-border-avatar', '%@');\
            document.documentElement.style.setProperty('--color-text-pseudo', '%@');\
            document.documentElement.style.setProperty('--color-text-pseudo-bl', '%@');\
            document.documentElement.style.setProperty('--border-header', '%@');\
            </script>",
                            sCssStyle, customFontSize, doubleSmileysCSS, myRawContent,
                            [ThemeColors hexFromUIColor:[ThemeColors tintColor:theme]], //--color-action
                            [ThemeColors hexFromUIColor:[ThemeColors tintColorDisabled:theme]], //--color-action-disabled
                            [ThemeColors hexFromUIColor:[ThemeColors messageBackgroundColor:theme]], //--color-message-background
                            [ThemeColors hexFromUIColor:[ThemeColors messageModoBackgroundColor:theme]], //--color-message-background
                            [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.1], // -color-message-header-me-background
                            [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.03], // color-message-mequoted-background
                            [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:1],  //--color-message-mequoted-borderleft
                            [ThemeColors rgbaFromUIColor:[ThemeColors tintColor:theme] withAlpha:0.1],  //--color-message-mequoted-borderother
                            /*[ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.7], //--color-message-background
                             [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.8], // --color-message-header-me-background
                             [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0 addSaturation:0.6],  //--color-message-mequoted-borderleft
                             [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0],  //--color-message-mequoted-borderother*/
                            [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.4], //--color-message-header-love-background
                            [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.3], // --color-message-header-me-background
                            [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:1.0 addSaturation:1 addBrightness:1],  //--color-message-mequoted-borderleft
                            [ThemeColors rgbaFromUIColor:[ThemeColors loveColor] withAlpha:0.1 addSaturation:1], //--color-message-mequoted-borderother
                            [ThemeColors rgbaFromUIColor:[ThemeColors textColor:theme] withAlpha:0.05],  //--color-message-quoted-bl-background
                            [ThemeColors rgbaFromUIColor:[ThemeColors textFieldBackgroundColor:theme] withAlpha:0.7],  //--color-message-header-bl-background
                            [ThemeColors rgbaFromUIColor:[ThemeColors textColorPseudo:theme] withAlpha:0.5],  //--color-separator-new-message
                            [ThemeColors hexFromUIColor:[ThemeColors textColor:theme]], //--color-text
                            [ThemeColors hexFromUIColor:[ThemeColors textColor2:theme]], //--color-text2
                            [ThemeColors hexFromUIColor:[ThemeColors textFieldBackgroundColor:theme]], //--color-background-bars
                            [ThemeColors rgbaFromUIColor:[ThemeColors textFieldBackgroundColor:theme] withAlpha:0.9], //--color-searchintra-nextresults
                            sAvatarImageFile,
                            sLoadInfoImageFile,
                            [ThemeColors getColorBorderQuotation:theme],
                            [ThemeColors hexFromUIColor:[ThemeColors getColorBorderAvatar:theme]],
                            [ThemeColors hexFromUIColor:[ThemeColors textColorPseudo:theme]],
                            [ThemeColors rgbaFromUIColor:[ThemeColors textColorPseudo:theme] withAlpha:0.5],
                            sBorderHeader];

	HTMLString = [HTMLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	//HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"href=\"/forum2.php?" withString:@"href=\"http://forum.hardware.fr/forum2.php?"];
	//HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"href=\"/hfr/" withString:@"href=\"http://forum.hardware.fr/hfr/"];
	
	//Custom Internal Images
	NSString *regEx2 = @"<img src=\"http://forum-images.hardware.fr/([^\"]+)\" alt=\"\\[[^\"]+\" title=\"[^\"]+\">";			
	HTMLString = [HTMLString stringByReplacingOccurrencesOfRegex:regEx2
														  withString:@"<img class=\"smileycustom\" src=\"https://forum-images.hardware.fr/$1\" />"];

    NSString *regEx22 = @"<img src=\"https://forum-images.hardware.fr/([^\"]+)\" alt=\"\\[[^\"]+\" title=\"[^\"]+\">";
    HTMLString = [HTMLString stringByReplacingOccurrencesOfRegex:regEx22
                                                      withString:@"<img class=\"smileycustom\" src=\"https://forum-images.hardware.fr/$1\" />"];

	//Native Internal Images
	NSString *regEx0 = @"<img src=\"http://forum-images.hardware.fr/[^\"]+/([^/]+)\" alt=\"[^\"]+\" title=\"[^\"]+\">";			
	HTMLString = [HTMLString stringByReplacingOccurrencesOfRegex:regEx0
														  withString:@"|NATIVE-$1-98787687687697|"];

    NSString *regEx02 = @"<img src=\"https://forum-images.hardware.fr/[^\"]+/([^/]+)\" alt=\"[^\"]+\" title=\"[^\"]+\">";
    HTMLString = [HTMLString stringByReplacingOccurrencesOfRegex:regEx02
                                                      withString:@"|NATIVE-$1-98787687687697|"];

	//Replace Internal Images with Bundle://
	NSString *regEx4 = @"\\|NATIVE-([^-]+)-98787687687697\\|";			
	HTMLString = [HTMLString stringByReplacingOccurrencesOfRegex:regEx4
														  withString:@"<img src='$1' />"];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            HTMLString = [HTMLString stringByReplacingOccurrencesOfString:@"iosversion" withString:@"ios7"];
    }
	
	//NSLog(@"HTMLString: %@", HTMLString);
	
	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSURL *baseURL = [NSURL fileURLWithPath:path];
	
	//NSLog(@"baseURL: %@", baseURL);
    
	[messageView loadHTMLString:HTMLString baseURL:baseURL];
	
	[messageView setUserInteractionEnabled:YES];
	
	//[HTMLString release];
	
	[messageDate setText:(NSString *)[[arrayData objectAtIndex:curMsg] messageDate]];
	[messageAuthor setText:[[arrayData objectAtIndex:curMsg] name]];

	//NSLog(@"avat: %@", [[arrayData objectAtIndex:curMsg] imageUrl]);

	//NSString* imageURL = @"http://theurl.com/image.gif";

	
	if ([[arrayData objectAtIndex:curMsg] imageUI]) {

		[authorAvatar setImage:[UIImage imageWithContentsOfFile:[[arrayData objectAtIndex:curMsg] imageUI]]];

		
	}
	else {
		[authorAvatar setImage:[UIImage imageNamed:@"avatar_male_gray_on_light_48x48"]];
	}
	
	//Btn Quote & Edit
	[self.arrayAction removeAllObjects];

	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                              target:nil
                                                                              action:nil];
    fixedItem.width = 10;
    
	if([[arrayData objectAtIndex:curMsg] urlEdit]){
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, editBtn, fixedItem, actionBtn, nil] animated:NO];
		
	}
	else if([[arrayData objectAtIndex:curMsg] urlQuote]){
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, quoteBtn, fixedItem, actionBtn, nil] animated:NO];
	}
	else {
		[toolbarBtn setItems:[NSArray arrayWithObjects: flexItem, actionBtn, nil] animated:NO];
	}
	
	if(self.parent.navigationItem.rightBarButtonItem.enabled) {
		quoteBtn.enabled = YES;		
	}
	else {
		quoteBtn.enabled = NO;	
		if([[arrayData objectAtIndex:curMsg] urlEdit]){
			actionBtn.enabled = NO;
		}
		else {
			actionBtn.enabled = YES;
		}

	}

	
}

- (void)viewDidAppear:(BOOL)animated
{
	//NSLog(@"MDV viewDidAppear");
	
    [super viewDidAppear:animated];
	self.parent.isAnimating = NO;
	


}

- (void)viewDidDisappear:(BOOL)animated
{
	//NSLog(@"MDV viewDidDisappear");	
	
    [super viewDidDisappear:animated];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //NSLog(@"MDV viewDidLoad");
    [super viewDidLoad];

	self.styleAlert = [[UIActionSheet alloc] init];
	
	// "Segmented" control to the right
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userThemeDidChange)
                                                 name:kThemeChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(smileysSizeDidChange)
                                                 name:kSmileysSizeChangedNotification
                                               object:nil];
    
    if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userTextSizeDidChange) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
         self.toolbarBtn.frame = CGRectMake(self.toolbarBtn.frame.origin.x, self.toolbarBtn.frame.origin.y - 49, self.toolbarBtn.frame.size.width, self.toolbarBtn.frame.size.height);
         self.messageAuthor.frame = CGRectMake(self.messageAuthor.frame.origin.x, self.messageAuthor.frame.origin.y - 49, self.messageAuthor.frame.size.width, self.messageAuthor.frame.size.height);
         self.messageDate.frame = CGRectMake(self.messageDate.frame.origin.x, self.messageDate.frame.origin.y - 49, self.messageDate.frame.size.width, self.messageDate.frame.size.height);
         self.messageAvatar.frame = CGRectMake(self.messageAvatar.frame.origin.x, self.messageAvatar.frame.origin.y - 49, self.messageAvatar.frame.size.width, self.messageAvatar.frame.size.height);
    }
    
    [self.messageAuthor setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [self.messageDate setFont:[UIFont boldSystemFontOfSize:8.0f]];
    
    UISegmentedControl *segmentedControl;
    segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"upsmall7"],
                                             [UIImage imageNamed:@"downsmall7"],
                                             nil]];

	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            segmentedControl.frame = CGRectMake(0, 0, 90, 24);
        }
        else {
            segmentedControl.frame = CGRectMake(0, 0, 90, 30);
        }
    }
    else {
        segmentedControl.frame = CGRectMake(0, 0, 90, 30);
    }
    
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
	self.navigationItem.rightBarButtonItem = segmentBarItem;
	[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:0];
	[(UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView setEnabled:NO forSegmentAtIndex:1];
	
	[messageTitle setText:self.messageTitleString];	

    [self.messageView setBackgroundColor:[UIColor whiteColor]];
    self.messageView.navigationDelegate = self;
    
    [self setupData];
}
	 
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	// Get user preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
    
	if ([enabled isEqualToString:@"all"]) {
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

- (IBAction)segmentAction:(id)sender {
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	switch (segmentedControl.selectedSegmentIndex) {
		case 0:
			curMsg -=1;
			[self setupData];
			break;
		case 1:
			//down
			curMsg +=1;			
			[self setupData];
			break;
		default:
			break;
	}
	
    [(UILabel *)self.navigationItem.titleView setText:[NSString stringWithFormat:@"Page: %d — %d/%ld", self.pageNumber, curMsg + 1, (unsigned long)self.arrayData.count]];
}

-(void)QuoteMessage {
	[parent quoteMessage:[NSString stringWithFormat:@"%@%@", [k ForumURL], [[[arrayData objectAtIndex:curMsg] urlQuote] decodeSpanUrlFromString] ]];
}

-(void)EditMessage {
	[parent setEditFlagTopic:[(LinkItem*)[arrayData objectAtIndex:curMsg] postID]];
	[parent editMessage:[NSString stringWithFormat:@"%@%@", [k ForumURL], [[[arrayData objectAtIndex:curMsg] urlEdit] decodeSpanUrlFromString] ]];
}

-(void)ActionList:(id)sender {
	//Btn Quote & Edit
	[self.arrayAction removeAllObjects];

	if ([self.parent canBeFavorite]) {
		[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Ajouter aux favoris", @"actionFavoris:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
	} 
	
	if([[arrayData objectAtIndex:curMsg] urlEdit] && self.parent.navigationItem.rightBarButtonItem.enabled){
		[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Répondre", @"QuoteMessage:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
	}
	else  {
		//[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Voir le profil", @"actionProfil:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
		if([[arrayData objectAtIndex:curMsg] MPUrl]){
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Envoyer un message", @"actionMessage:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
		}
	}
	
	//"Citer ☑"@"Citer ☒"@"Citer ☐"	
	if([[arrayData objectAtIndex:curMsg] quoteJS] && self.parent.navigationItem.rightBarButtonItem.enabled) {
		NSString *components = [[[arrayData objectAtIndex:curMsg] quoteJS] substringFromIndex:7];
		components = [components stringByReplacingOccurrencesOfString:@"); return false;" withString:@""];
		components = [components stringByReplacingOccurrencesOfString:@"'" withString:@""];
		
		NSArray *quoteComponents = [components componentsSeparatedByString:@","];
		
		NSString *nameCookie = [NSString stringWithFormat:@"quotes%@-%@-%@", [quoteComponents objectAtIndex:0], [quoteComponents objectAtIndex:1], [quoteComponents objectAtIndex:2]];
		NSString *quotes = [self.parent LireCookie:nameCookie];
		
		if ([quotes rangeOfString:[NSString stringWithFormat:@"|%@", [quoteComponents objectAtIndex:3]]].location == NSNotFound) {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☐", @"actionCiter:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];	

		}
		else {
			[self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Citer ☑", @"actionCiter:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];	

		}
		
	}
    
    if (![self.parent isSearchInstra]) {
        [self.arrayAction addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Copier le lien", @"actionLink:", nil] forKeys:[NSArray arrayWithObjects:@"title", @"code", nil]]];
    }
    
    
    if ([styleAlert isVisible]) {
        [styleAlert dismissWithClickedButtonIndex:self.arrayAction.count animated:YES];
        return;
    }
    else {
        styleAlert = [[UIActionSheet alloc] init];
    }
    
	for (id tmpAction in self.arrayAction) {
		[styleAlert addButtonWithTitle:[tmpAction valueForKey:@"title"]];
	}	
	
	[styleAlert addButtonWithTitle:@"Annuler"];

	styleAlert.cancelButtonIndex = self.arrayAction.count;
	styleAlert.delegate = self;

	styleAlert.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { 
        [styleAlert showFromBarButtonItem:sender animated:YES];
    }
    else {
        UIBarButtonItem *Ubbi = (UIBarButtonItem *)sender;
        [styleAlert showFromRect:Ubbi.customView.frame inView:[[HFRplusAppDelegate sharedAppDelegate] window] animated:YES];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

	if (buttonIndex < [self.arrayAction count]) {
        [self.parent performSelectorOnMainThread:NSSelectorFromString([[self.arrayAction objectAtIndex:buttonIndex] objectForKey:@"code"]) withObject:[NSNumber numberWithInt:curMsg] waitUntilDone:NO];
        
    }
	
}

- (NSString *) userTextSizeDidChange {
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_text"] isEqualToString:@"sys"]) {

        if ([UIFontDescriptor respondsToSelector:@selector(preferredFontDescriptorWithTextStyle:)]) {
            CGFloat userFontSize = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody].pointSize;
            userFontSize = floorf(userFontSize*0.90);
            NSString *script = [NSString stringWithFormat:@"$('.message .content .right').css('cssText', 'font-size:%fpx !important');", userFontSize];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right table.code *').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            //        script = [script stringByAppendingString:[NSString stringWithFormat:@"$('.message .content .right p.editedhfrlink').css('cssText', 'font-size:%fpx !important');", floor(userFontSize*0.75)]];
            
            
            [self.messageView evaluateJavaScript:script completionHandler:nil];
            
            return [NSString stringWithFormat:@".message .content .right { font-size:%fpx !important; }", userFontSize];
            
            //NSLog(@"userFontSize %@", script);
        }
    }
    return @"";
    
}

- (NSString *) userThemeDidChange {
    
    Theme theme = [[ThemeManager sharedManager] theme];
    NSString *script = @"";
    if (theme == ThemeLight) {
        script = @"\
        document.getElementById('dark-styles').rel = document.getElementById('dark-styles-retina').rel  = 'stylesheet';\
        document.getElementById('light-styles').rel = document.getElementById('light-styles-retina').rel  = 'stylesheet';\
        document.getElementById('oled-styles').rel = document.getElementById('oled-styles-retina').rel  = 'stylesheet';\
        document.getElementById('dark-styles').disabled = document.getElementById('dark-styles-retina').disabled = true;\
        document.getElementById('oled-styles').disabled = document.getElementById('oled-styles-retina').disabled = true;\
        document.getElementById('light-styles').disabled = document.getElementById('light-styles-retina').disabled = false;";
    }
    else if (theme == ThemeDark) {
        script = @"\
        document.getElementById('dark-styles').rel = document.getElementById('dark-styles-retina').rel  = 'stylesheet';\
        document.getElementById('light-styles').rel = document.getElementById('light-styles-retina').rel  = 'stylesheet';\
        document.getElementById('oled-styles').rel = document.getElementById('oled-styles-retina').rel  = 'stylesheet';\
        document.getElementById('dark-styles').disabled = document.getElementById('dark-styles-retina').disabled = false;\
        document.getElementById('oled-styles').disabled = document.getElementById('oled-styles-retina').disabled = true;\
        document.getElementById('light-styles').disabled = document.getElementById('light-styles-retina').disabled = true;";
    } else {
        script = @"\
        document.getElementById('light-styles').rel = document.getElementById('light-styles-retina').rel  = 'stylesheet';\
        document.getElementById('dark-styles').rel = document.getElementById('dark-styles-retina').rel  = 'stylesheet';\
        document.getElementById('oled-styles').rel = document.getElementById('oled-styles-retina').rel  = 'stylesheet';\
        document.getElementById('dark-styles').disabled = document.getElementById('dark-styles-retina').disabled = true;\
        document.getElementById('oled-styles').disabled = document.getElementById('oled-styles-retina').disabled = false;\
        document.getElementById('light-styles').disabled = document.getElementById('light-styles-retina').disabled = true;";
    }
    
    [self.messageView evaluateJavaScript:script completionHandler:nil];
    
    self.actionBtn.tintColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];
    self.quoteBtn.tintColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];
    self.editBtn.tintColor = [ThemeColors tintColor:[[ThemeManager sharedManager] theme]];
    [(UILabel *)self.navigationItem.titleView setTextColor:[ThemeColors titleTextAttributesColor:[[ThemeManager sharedManager] theme]]];

    return @"";
}

- (void)smileysSizeDidChange {
    NSString *script = @"document.getElementById('smileys_double').disabled = true;";
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"size_smileys"] isEqualToString:@"double"]) {
        script = @"document.getElementById('smileys_double').disabled = false;";
    }
    [self.messageView evaluateJavaScript:script completionHandler:nil];
}
#pragma mark -
#pragma mark WKWebView Delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"didFinishNavigation");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self userTextSizeDidChange];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"decidePolicyForNavigationAction = %@", navigationAction.request.URL);
    BOOL bAllow = YES;
    NSURLRequest *aRequest = navigationAction.request;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if ([[aRequest.URL scheme] isEqualToString:@"file"]) {
            if ([[[aRequest.URL pathComponents] objectAtIndex:0] isEqualToString:@"/"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {
                NSLog(@"pas la meme page / topic");
                // Navigation logic may go here. Create and push another view controller.
                
                //NSLog(@"did Select row Topics table views: %d", indexPath.row);
                
                //if (self.messagesTableViewController == nil) {
                MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""]];
                self.messagesTableViewController = aView;
                //}
                
                self.navigationItem.backBarButtonItem =
                [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                                 style: UIBarButtonItemStyleBordered
                                                target:nil
                                                action:nil];
                
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
                    self.navigationItem.backBarButtonItem.title = @" ";
                }
                
                //setup the URL
                self.messagesTableViewController.topicName = @"";
                self.messagesTableViewController.isViewed = YES;
                
                //NSLog(@"push message liste");
                [self.navigationController pushViewController:messagesTableViewController animated:YES];
            }
            
            bAllow = NO;
        }
        else if ([[aRequest.URL host] isEqualToString:@"forum.hardware.fr"] && ([[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"forum2.php"] || [[[aRequest.URL pathComponents] objectAtIndex:1] isEqualToString:@"hfr"])) {
            
            NSLog(@"%@", aRequest.URL);
            
            MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:[[[aRequest.URL absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@", [k ForumURL]] withString:@""] stringByReplacingOccurrencesOfString:@"http://forum.hardware.fr" withString:@""]];
            self.messagesTableViewController = aView;
            
            self.navigationItem.backBarButtonItem =
            [[UIBarButtonItem alloc] initWithTitle:@"Retour"
                                             style: UIBarButtonItemStyleBordered
                                            target:nil
                                            action:nil];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
                self.navigationItem.backBarButtonItem.title = @" ";
            }
            
            //setup the URL
            self.messagesTableViewController.topicName = @"";
            self.messagesTableViewController.isViewed = YES;
            
            [self.navigationController pushViewController:messagesTableViewController animated:YES];
            
            bAllow = NO;
        }
        else {
            NSURL *url = aRequest.URL;
            NSString *urlString = url.absoluteString;
            
            [[HFRplusAppDelegate sharedAppDelegate] openURL:urlString];
            bAllow = NO;
        }
    }
    else if (navigationAction.navigationType == WKNavigationTypeOther) {
        if ([[aRequest.URL scheme] isEqualToString:@"oijlkajsdoihjlkjasdoloaded"]) {
            [self userTextSizeDidChange];
            bAllow = NO;
        }
    }
    
    if (bAllow) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

#pragma mark -
#pragma mark AddMessage Delegate
- (void)addMessageViewControllerDidFinish:(AddMessageViewController *)controller {
    NSLog(@"addMessageViewControllerDidFinish");
	
	//[self setEditFlagTopic:nil];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)addMessageViewControllerDidFinishOK:(AddMessageViewController *)controller {
	NSLog(@"addMessageViewControllerDidFinishOK");
	
	[self dismissModalViewControllerAnimated:YES];
	[self.navigationController popToViewController:self animated:NO];
}
- (void)didPresentAlertView:(UIAlertView *)alertView
{
	
	NSLog(@"didPresentAlertView PT %@", alertView);
	
	if (([alertView tag] == 666)) {
		usleep(200000);
		
		[alertView dismissWithClickedButtonIndex:0 animated:YES];
	}
	
	
}

@end
