//
//  CreditsViewController.h
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import <WebKit/WebKit.h>

@interface CreditsViewController : UIViewController <WKNavigationDelegate, WKUIDelegate> {
	WKWebView* myWebView;
}

@property (nonatomic, strong) IBOutlet WKWebView* myWebView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filename:(NSString *)filename;

@end
