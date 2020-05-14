//
//  CreditsViewController.m
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import "CreditsViewController.h"
#import "HFRplusAppDelegate.h"
#import "ThemeColors.h"
#import "ThemeManager.h"


@interface CreditsViewController ()
@property (nonatomic, strong) NSString *filename;
@end

@implementation CreditsViewController
@synthesize myWebView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filename:(NSString *)filename {
   if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
       self.filename = filename;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    self.title = [self.filename isEqualToString:@"credits"] ? @"Crédits" : @"Charte du forum";

    [super viewDidLoad];
    [self.myWebView setBackgroundColor:[UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f]];
    self.myWebView.navigationDelegate = self;
}

-(void)viewWillAppear:(BOOL)animated   {
    [super viewWillAppear:animated];
    [self setThemeColors:[[ThemeManager sharedManager] theme]];
    [self loadPage];
}

-(void)setThemeColors:(Theme)theme{
    [self.view setBackgroundColor:[ThemeColors greyBackgroundColor:theme]];
    [self.myWebView setBackgroundColor:[ThemeColors greyBackgroundColor:theme]];
    [self.myWebView setOpaque:NO];
}

-(void)loadPage {
    //v2
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.filename ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%iosversion%%" withString:@"ios7"];
    }
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%iosversion%%" withString:@""];
    
    NSString *cssString = [ThemeColors creditsCss:[[ThemeManager sharedManager] theme]];
    //NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)"; // 2
    // NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString]; // 3
    NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>";
    //[self.webView loadHTMLString:[headerString stringByAppendingString:yourHTMLString] baseURL:nil];
    htmlString =[htmlString stringByReplacingOccurrencesOfString:@"</head>" withString:[NSString stringWithFormat:@"<style>%@</style></head>", cssString]];
    [myWebView loadHTMLString:[headerString stringByAppendingString:htmlString] baseURL:baseURL];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
	//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark WebView delegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didStartProvisionalNavigation");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// was webViewDidFinishLoadDOM
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"didFinishNavigation");

    NSString *cssString = [ThemeColors creditsCss:[[ThemeManager sharedManager] theme]];
    NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)";
    NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString];
    [webView evaluateJavaScript:javascriptWithCSSString completionHandler:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
// was shouldStartLoadWithRequest
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
		NSURL *url = navigationAction.request.URL;
		NSString *urlString = url.absoluteString;
        [[HFRplusAppDelegate sharedAppDelegate] openURL:urlString];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString *cssString = [ThemeColors creditsCss:[[ThemeManager sharedManager] theme]];
    NSString *javascriptString = @"var style = document.createElement('style'); style.innerHTML = '%@'; document.head.appendChild(style)"; // 2
    NSString *javascriptWithCSSString = [NSString stringWithFormat:javascriptString, cssString]; // 3
    [webView stringByEvaluatingJavaScriptFromString:javascriptWithCSSString]; // 4
}

@end
