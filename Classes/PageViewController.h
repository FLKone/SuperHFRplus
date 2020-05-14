//
//  PageViewController.h
//  HFRplus
//
//  Created by FLK on 10/10/10.
//
#import <unistd.h>
#import <UIKit/UIKit.h>

#import "RangeOfCharacters.h"
#import "RegexKitLite.h"
#import <QuartzCore/QuartzCore.h>
#import "Topic.h"

@class FilterPostsQuotes;

@interface PageViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate> {
	NSString *currentUrl;	
	int pageNumber;
	
	//Header & Footer
	int firstPageNumber;
	int lastPageNumber;
	NSString *firstPageUrl;
	NSString *lastPageUrl;
	
	//Right Toolbar Items
	NSString *nextPageUrl;
	NSString *previousPageUrl;
}

@property (nonatomic, strong) NSString *currentUrl;
@property (nonatomic, strong) Topic *currentOfflineTopic;
@property int pageNumber;
@property int pageNumberFilterStart, pageNumberFilterEnd;

@property int firstPageNumber;
@property int lastPageNumber;
@property (nonatomic, strong) NSString *firstPageUrl;
@property (nonatomic, strong) NSString *lastPageUrl;

@property (nonatomic, strong) NSString *nextPageUrl;
@property (nonatomic, strong) NSString *previousPageUrl;
@property FilterPostsQuotes* filterPostsQuotes;

-(BOOL)isModeOffline;
-(void)choosePage;
-(void)goToPage:(NSString *)pageType;
-(void)gotoPageNumber:(int)number;
-(void)fetchContent;
-(IBAction)searchSubmit:(UIBarButtonItem *)sender;
-(IBAction)filterPostsQuotesNext:(UIBarButtonItem *)sender;
-(void)fetchContent:(int)from;

-(void)nextPage:(id)sender;
-(void)previousPage:(id)sender;
-(void)firstPage:(id)sender;
-(void)lastPage:(id)sender;
-(void)firstPage;
-(void)lastPage;
-(void)lastAnswer;

@end
