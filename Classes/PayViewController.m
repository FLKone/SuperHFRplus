//
//  PayViewController.m
//  HFRplus
//
//  Created by FLK on 22/01/11.
//

#import "PayViewController.h"

#import "MKStoreManager.h"
#import "Constants.h"
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>

@implementation PayViewController

@synthesize resutsBtn;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Faire un don";
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
	
}

- (void)periodicCheck
{
	NSLog(@"periodicCheck");
	
	if([MKStoreManager isFeaturePurchased:@"hfrplus.don1"])
	{
		if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"hfrplus.don1"] intValue] > 1) {
			[self.resutsBtn setTitle:[NSString stringWithFormat:@"Dons effectués: %d, Merci!", [[[NSUserDefaults standardUserDefaults] valueForKey:@"hfrplus.don1"] intValue]] forState:UIControlStateNormal];

		}
		else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"hfrplus.don1"] intValue] == 1) {

			[self.resutsBtn setTitle:[NSString stringWithFormat:@"Don effectué, Merci!"] forState:UIControlStateNormal];
		}
		else {
			[self.resutsBtn setTitle:@"Aucun don effectué via l'Application" forState:UIControlStateNormal];
		}


	}
	else {
		[self.resutsBtn setTitle:@"Aucun don effectué via l'Application" forState:UIControlStateNormal];
	}
	
	
    //self.resutsBtn.titleLabel.text = @"Don(s) effectué(s): aucun";
	
	
	
	
}

- (IBAction)gotohfrplus {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://apps.flkone.com/hfrplus/"]];
    
}
- (void) viewWillAppear:(BOOL)animated
{
	NSLog(@"viewWillAppear");

    [super viewWillAppear:animated];

	periodicMaintenanceTimer = [NSTimer scheduledTimerWithTimeInterval:5
																 target:self
															   selector:@selector(periodicCheck)
															   userInfo:nil
																repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	NSLog(@"viewDidDisappear");

    [super viewDidDisappear:animated];
	
	[periodicMaintenanceTimer invalidate];
    periodicMaintenanceTimer = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (IBAction) achat {
	NSLog(@"achat");
	[[MKStoreManager sharedManager] buyFeature:@"hfrplus.don1"];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {

    resutsBtn = nil;
    [self setResutsBtn:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[periodicMaintenanceTimer invalidate];
    periodicMaintenanceTimer = nil;

}


@end
