//
//  TabBarController.m
//  HFRplus
//
//  Created by FLK on 17/09/10.
//

#import "TabBarController.h"
#import "HFRplusAppDelegate.h"
#import "FavoritesTableViewController.h"
#import "HFRMPViewController.h"
#import "ForumsTableViewController.h"
#import "HFRTabBar.h"
#import "ThemeColors.h"
#import "ThemeManager.h"



@implementation TabBarController

-(void)viewDidLoad {
	[super viewDidLoad];
	
	//NSLog(@"TBC viewDidLoad %@", self.tabBar);
    self.title = @"Menu";

    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        UITabBarItem *tabBarItem1 = [self.tabBar.items objectAtIndex:0];
        UITabBarItem *tabBarItem2 = [self.tabBar.items objectAtIndex:1];
        UITabBarItem *tabBarItem3 = [self.tabBar.items objectAtIndex:2];
        UITabBarItem *tabBarItem4 = [self.tabBar.items objectAtIndex:3];
        
        [tabBarItem1 setImage:[UIImage imageNamed:@"44-shoebox"]];
        [tabBarItem2 setImage:[UIImage imageNamed:@"28-star"]];
        [tabBarItem3 setImage:[UIImage imageNamed:@"18-envelope.png"]];
        [tabBarItem4 setImage:[UIImage imageNamed:@"19-gear.png"]];
        
    } else {
        for (int i=0; i<4; i++) {
            UITabBarItem *tabBarItem = [self.tabBar.items objectAtIndex:i];
            tabBarItem.selectedImage = [[UIImage imageNamed:[ThemeColors tabBarItemSelectedImageAtIndex:i]]
                                        imageWithRenderingMode:[ThemeColors tabBarItemSelectedImageRendering] ];
            tabBarItem.image = [[UIImage imageNamed:[ThemeColors tabBarItemUnselectedImageAtIndex:i]]
                                imageWithRenderingMode:[ThemeColors tabBarItemUnselectedImageRendering]];
            switch (i) {
                case 0: tabBarItem.title = @"Catégories"; break;
                case 1: tabBarItem.title = @"Favoris"; break;
                case 2: tabBarItem.title = @"Messages"; break;
                case 3: tabBarItem.title = @"Réglages"; break;
            }
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tab = [defaults stringForKey:@"default_tab"];
    
    if (tab) {
        [self setSelectedIndex:[tab intValue]];
    }
    
    
    if([((HFRNavigationController *)self.viewControllers[0]).topViewController isKindOfClass:[ForumsTableViewController class]]){
        ((ForumsTableViewController *)((HFRNavigationController *)self.viewControllers[0]).topViewController).reloadOnAppear = YES;
    }
    
}

-(UITraitCollection *)traitCollection
{
    //NSLog(@"traitCollection");
    UITraitCollection
    *realTraits = [super traitCollection],
    *lieTrait = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UITraitCollection traitCollectionWithTraitsFromCollections:@[realTraits, lieTrait]];
    } else {
        return [UITraitCollection traitCollectionWithTraitsFromCollections:@[realTraits]];
    }
}

-(void)setThemeFromNotification:(NSNotification *)notification{
    [self setTheme:[[ThemeManager sharedManager] theme]];
}

-(void)setTheme:(Theme)theme{
  [self.tabBar setTranslucent:NO];
    //if ([[UITabBar appearance] respondsToSelector:@selector(setTranslucent:)]) {
      //  [[UITabBar appearance] setTranslucent:NO];
    //}

    if(!self.bgView){
        self.bgView = [[UIImageView alloc] initWithImage:[ThemeColors imageFromColor:[UIColor clearColor]]];
        [self.tabBar addSubview:self.bgView];
        [self.tabBar sendSubviewToBack:self.bgView];

    }
    
    if(!self.bgOverlayView){
        self.bgOverlayView = [[UIImageView alloc] init];
        [self.tabBar addSubview:self.bgOverlayView];
        [self.tabBar sendSubviewToBack:self.bgOverlayView];
        [self.tabBar sendSubviewToBack:self.bgView];
    }
    
    if(!self.bgOverlayViewBis){
        self.bgOverlayViewBis = [[UIImageView alloc] init];
        [self.tabBar addSubview:self.bgOverlayViewBis];
        [self.tabBar sendSubviewToBack:self.bgOverlayView];
        [self.tabBar sendSubviewToBack:self.bgOverlayViewBis];
        [self.tabBar sendSubviewToBack:self.bgView];
    }
    
    self.bgView.frame = CGRectMake(0, 0, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    [self.bgView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    self.bgOverlayView.frame = CGRectMake(0, 0, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    [self.bgOverlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    self.bgOverlayViewBis.frame = CGRectMake(0, self.tabBar.frame.size.height - 3.f, self.tabBar.frame.size.width, 3.f);
    [self.bgOverlayViewBis setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];

    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
        self.bgOverlayViewBis.image =  [ThemeColors imageFromColor:[UIColor clearColor]];
        self.bgOverlayView.image =  [ThemeColors imageFromColor:[UIColor clearColor]];
    }else{
        UIImage *navBG =[[UIImage animatedImageNamed:@"snow" duration:1.f]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeTile];
        
        UIImage *tab_snow = [UIImage imageNamed:@"tab_snow"];
        UIImage *tiledImage = [tab_snow resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeTile];
        self.bgOverlayViewBis.image = tiledImage;
        self.bgOverlayView.image = navBG;
    }
    
    self.bgView.image =[ThemeColors imageFromColor:[ThemeColors tabBackgroundColor:theme]];
    self.tabBar.tintColor = [ThemeColors tintColor:theme];
    
    if([self.childViewControllers count] > 0){
        for (int i=0; i<[self.childViewControllers count]; i++) {
            UINavigationController *nvc = (UINavigationController *)[self.childViewControllers objectAtIndex:i];
            nvc.navigationBar.barStyle = [ThemeColors barStyle:theme];
        }
    }
    
    for (int i=0; i<4; i++) {
        UITabBarItem *tabBarItem = [self.tabBar.items objectAtIndex:i];
        tabBarItem.selectedImage = [[UIImage imageNamed:[ThemeColors tabBarItemSelectedImageAtIndex:i]]
                                    imageWithRenderingMode:[ThemeColors tabBarItemSelectedImageRendering] ];
        tabBarItem.image = [[UIImage imageNamed:[ThemeColors tabBarItemUnselectedImageAtIndex:i]]
                            imageWithRenderingMode:[ThemeColors tabBarItemUnselectedImageRendering]];
        switch (i) {
            case 0: tabBarItem.title = @"Catégories"; break;
            case 1: tabBarItem.title = @"Favoris"; break;
            case 2: tabBarItem.title = @"Messages"; break;
            case 3: tabBarItem.title = @"Réglages"; break;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setThemeFromNotification:)
                                            name:kThemeChangedNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self setTheme:[[ThemeManager sharedManager] theme]];
}

- (BOOL)tabBarController:(UITabBarController * _Nonnull)tabBarController shouldSelectViewController:(UIViewController * _Nonnull)viewController {

    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nv = (UINavigationController *)viewController;
//      NSLog(@"curtab %lu", (unsigned long)tabBarController.selectedIndex);
//      NSLog("class top : %@ !!!", [nv.topViewController class]);
        
        //actualisation si tap sur l'onglet
        if (tabBarController.selectedIndex == 0 && [nv.topViewController isKindOfClass:[ForumsTableViewController class]]) {
            [(ForumsTableViewController *)nv.topViewController reload];
        }
        
        if (tabBarController.selectedIndex == 1 && [nv.topViewController isKindOfClass:[FavoritesTableViewController class]]) {
            [(FavoritesTableViewController *)nv.topViewController reload];
        }
        
        if (tabBarController.selectedIndex == 2 && [nv.topViewController isKindOfClass:[HFRMPViewController class]]) {
            [(HFRMPViewController *)nv.topViewController fetchContent];
        }

    }
    return YES;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    
    // Unsure why WKWebView calls this controller - instead of it's own parent controller
    if (self.presentedViewController) {
        NSLog(@"PRESENTED %@", self.presentedViewController);
        [self.presentedViewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    } else {
        [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}


/*
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	NSLog(@"didSelectViewController %@", viewController);
	
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nv = (UINavigationController *)viewController;
        if ([nv.topViewController isKindOfClass:[FavoritesTableViewController class]]) {
            NSLog("favprotes !!!");
        }
    }

}
*/
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	// Get user preference
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *enabled = [defaults stringForKey:@"landscape_mode"];
		
	if ([enabled isEqualToString:@"all"]) {
		return YES;
	} else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	
}

/* for iOS6 support */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    //NSLog(@"supportedInterfaceOrientations");
    
	if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"landscape_mode"] isEqualToString:@"all"]) {
        //NSLog(@"All");
        
		return UIInterfaceOrientationMaskAll;
	} else {
        //NSLog(@"Portrait");
        
		return UIInterfaceOrientationMaskPortrait;
	}
}


- (BOOL)shouldAutorotate
{
    //NSLog(@"shouldAutorotate");

    return YES;
}

-(void)popAllToRoot:(BOOL)includingSelectedIndex {
    //not selectedIndex
    long nbTab = self.viewControllers.count;
    
    for (int i = 0; i < nbTab; i++) {
        if (includingSelectedIndex || (!includingSelectedIndex && i != self.selectedIndex)) {
            [(UINavigationController *)self.viewControllers[i] popToRootViewControllerAnimated:NO];
        }
    }
}



@end
