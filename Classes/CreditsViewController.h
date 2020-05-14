//
//  CreditsViewController.h
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import <UIKit/UIKit.h>


@interface CreditsViewController : UIViewController <UIWebViewDelegate> {
	UIWebView* myWebView;
}
@property (nonatomic, strong) IBOutlet UIWebView* myWebView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filename:(NSString *)filename;

@end
