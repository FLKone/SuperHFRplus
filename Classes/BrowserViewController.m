//
//  BrowserViewController.m
//  HFRplus
//
//  Created by FLK on 19/06/11.
//

#import "BrowserViewController.h"
#import "HFRplusAppDelegate.h"
#import "RangeOfCharacters.h"
#import <WebKit/WebKit.h>

@implementation BrowserViewController
@synthesize delegate, currentUrl, fullBrowser, myModernWebView, needDismiss;

#pragma mark - WKWebView delegate methods
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"decidePolicyForNavigationAction = %@", navigationAction.request.URL);
    
    if ([[navigationAction.request.URL scheme] isEqualToString:@"itmss"]) {
        [self setNeedDismiss:YES];
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
 
    decisionHandler(WKNavigationActionPolicyAllow);
}


- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

- (void)webView:(WKWebView *)localWebView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)localWebView didFinishNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [localWebView evaluateJavaScript:[NSString stringWithFormat:@"document.title"] completionHandler:^(id response, NSError *error) {
        if (![self.title isEqualToString:response]) {
            self.title = response;
        }
    }];
}

- (void) dismissManually {
    NSLog(@"viewWillAppear %d", self.needDismiss);

    if (self.needDismiss) {
        NSLog(@"NEED DISMISS");
        self.needDismiss = NO;
        [self.myModernWebView evaluateJavaScript:@"document.body.innerHTML" completionHandler:^(id result, NSError *error) {
            //NSLog(@"result %@", result);
            NSString *innerHTML = [NSString stringWithFormat:@"%@", result];
            if (innerHTML.length == 0) {
                [self dismissModalViewControllerAnimated:YES];
            }
        }];
    }
             
    self.needDismiss = NO;
}

- (id)initWithURL:(NSString *)theURL {
    self = [super init];
    if (self) {
        // Custom initialization
        self.currentUrl = [NSString stringWithString:theURL];
        self.fullBrowser = NO;
    }
    return self;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)cancel {
    [self viewDidUnload];
    
    if (self.fullBrowser && [(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController respondsToSelector:@selector(MoveRightToLeft)]) {
        [(SplitViewController *)[HFRplusAppDelegate sharedAppDelegate].window.rootViewController MoveLeftToRight];
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
        //[self.delegate browserViewControllerDidFinish:self];
    }
}

- (void)navPlus {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [[HFRplusAppDelegate sharedAppDelegate].splitViewController respondsToSelector:@selector(MoveRightToLeft:)])
    {
        if ([[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {
            [((BrowserViewController *)[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController).myModernWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.myModernWebView.URL.absoluteString]]];
        }
        else {
            [[HFRplusAppDelegate sharedAppDelegate].splitViewController MoveRightToLeft:self.myModernWebView.URL.absoluteString];
        }
        [self cancel];
    }
}

- (void)reload {
    [self.myModernWebView reload];
}

- (void)goBack {
    [self.myModernWebView goBack];
}

- (void)goForward {
    [self.myModernWebView goForward];
}

#pragma mark - View lifecycle
- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    view.backgroundColor = [UIColor whiteColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
    
    myModernWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    myModernWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    myModernWebView.navigationDelegate = self;
    myModernWebView.allowsBackForwardNavigationGestures = YES;
    myModernWebView.UIDelegate = self;
    [self.view addSubview:myModernWebView];
    
    CGRect toolbarFrame = self.view.frame;
    toolbarFrame.size.height = 44;
    toolbarFrame.origin.y = self.view.frame.size.height - 44;
    toolbarFrame.origin.x = 0;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    
    UIBarButtonItem *systemItem1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowback"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];

    UIBarButtonItem *systemItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrowforward"] style:UIBarButtonItemStyleBordered target:self action:@selector(goForward)];

    //Use this to put space in between your toolbox buttons
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                              target:nil
                                                                              action:nil];
    
    //Add buttons to the array
    NSArray *items = [NSArray arrayWithObjects: systemItem1, flexItem, systemItem2, nil];
    //add array of buttons to toolbar
    [toolbar setItems:items animated:NO];
    
    [self.view addSubview:toolbar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = [NSURL URLWithString:self.currentUrl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissManually) name:UIApplicationDidBecomeActiveNotification object:nil];
    self.needDismiss = NO;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //[request setValue:@"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C25 Safari/419.3" forHTTPHeaderField:@"User-Agent"];
    
    [self.myModernWebView loadRequest:request];

    // Do any additional setup after loading the view from its nib.

    if (!self.fullBrowser) {
        // close
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = doneButton;
    }
    
    // reload
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    self.navigationItem.rightBarButtonItem = segmentBarItem;
	
    NSMutableArray *myButtonArray = [[NSMutableArray alloc] initWithObjects:segmentBarItem, nil];
    
    if (self.fullBrowser) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        [myButtonArray addObject:doneButton];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UIBarButtonItem *navPButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Navigateur✚", nil) style:UIBarButtonItemStylePlain target:self action:@selector(navPlus)];
        [myButtonArray addObject:navPButton];
    }
    
	self.navigationItem.rightBarButtonItems = myButtonArray;
    
    [[self.myModernWebView scrollView] setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    [[self.myModernWebView scrollView] setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    self.myModernWebView.navigationDelegate = self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
    
	if (![enabled isEqualToString:@"none"]) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

@end
