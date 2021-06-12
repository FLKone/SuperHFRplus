//
//  HFRplusAppDelegate.m
//  HFRplus
//
//  Created by FLK on 18/08/10.
//  updated Branch
//

#import "HFRplusAppDelegate.h"
#import "UIAlertViewURL.h"

#import "HFRMPViewController.h"
#import "FavoritesTableViewController.h"
#import "OldFavoritesTableViewController.h"
#import "ForumsTableViewController.h"

#import "MKStoreManager.h"
#import "BrowserViewController.h"

#import "ThemeColors.h"
#import "ThemeManager.h"
#import "OfflineStorage.h"

#import "MultisManager.h"
#import "MPStorage.h"
#import "BlackList.h"

#import <SafariServices/SafariServices.h>
#import <BackgroundTasks/BackgroundTasks.h>
#import <UserNotifications/UserNotifications.h>
#import "HTMLParser.h"

#define NOTIFICATION_BACKGROUND_REFRESH YES
#define BACKGROUND_MAINTENANCE          YES

@implementation HFRplusAppDelegate

@synthesize window;
@synthesize rootController;
@synthesize splitViewController;
@synthesize detailNavigationController;

@synthesize forumsNavController;
@synthesize favoritesNavController;
@synthesize messagesNavController;
@synthesize searchNavController;

@synthesize isLoggedIn;
@synthesize statusChanged;

@synthesize hash_check, internetReach;

//@synthesize periodicMaintenanceOperation; //ioQueue,

#pragma mark -
#pragma mark Application lifecycle

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    NSLog(@"reachabilityChanged:");
    
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
}

- (BOOL)legacy_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    NSLog(@"didFinishLaunchingWithOptions");

    //self.hash_check = [[NSString alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];

/*
#ifdef CONFIGURATION_Release
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    if ([bundleIdentifier isEqualToString:@"hfrplus.red"]) {
        [Crittercism enableWithAppID:kTestFlightAPIRE];
        
        //[TestFlight takeOff:kTestFlightAPIRE];
    }
    else
    {
        [Crittercism enableWithAppID:kTestFlightAPI];

        //[TestFlight takeOff:kTestFlightAPI];
        //[MKStoreManager sharedManager];

    }
#else
    //NSLog(@"DEBUUUUUGGGGG");
#endif
    */
    [self registerDefaultsFromSettingsBundle];
    [[OfflineStorage shared] copyAllRequiredResourcesFromBundleToCache];
    
    NSString *version = [NSString stringWithFormat:@"HFR+ %@ (%@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];

    NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
                                  version, @"version", nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
        
        
    //UserAgent
    /*
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"Mozilla/5.0 (HFRplus) AppleWebKit (KHTML, like Gecko)",
                                @"UserAgent", nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    */
    
    // Override point for customization after application launch.
        
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];

    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    rootController.customizableViewControllers = nil;

    // Start up window
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { 
        //[splitViewController view].backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgbigiPad"]];

        splitViewController.delegate = splitViewController;
        [window setRootViewController:splitViewController];

    } else {
        [window setRootViewController:rootController];
    }
        
    [window makeKeyAndVisible];

    if (BACKGROUND_MAINTENANCE) {
        periodicMaintenanceTimer = [NSTimer scheduledTimerWithTimeInterval:60*10
                                                                    target:self
                                                                  selector:@selector(periodicMaintenance)
                                                                  userInfo:nil
                                                                   repeats:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThemeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setThemeFromNotification:) //note the ":" - should take an NSNotification as parameter
                                                 name:kThemeChangedNotification
                                               object:nil];
    
    [[MultisManager sharedManager] updateAllAccounts];
    
    // Blacklist : init blacklist / lovelist lists
    [BlackList shared];

    // MPStorage : Update Blacklist from MPStorage
    [[MPStorage shared] initOrResetMP:[[MultisManager sharedManager] getCurrentPseudo]];

    [self setTheme:[[ThemeManager sharedManager] theme]];
    [[ThemeManager sharedManager] refreshTheme];

    
    // Register background fetch
#ifdef NOTIFICATION_BACKGROUND_REFRESH
    if (@available(iOS 13, *))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        
        [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:@"com.hfrplus.refresh_mp" usingQueue:nil
                                         launchHandler:^(__kindof BGTask * _Nonnull task) {
            //[task setTaskCompletedWithSuccess:YES];
            [self checkForNewMP:(BGAppRefreshTask *)task];
        }];
        [application setMinimumBackgroundFetchInterval:60];
        [center requestAuthorizationWithOptions: (UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
           completionHandler:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"UNUserNotificationCenter authorization granted=%@, error=%@", @(granted), error);
        }];
    }
#endif

    return YES;
}

#ifdef NOTIFICATION_BACKGROUND_REFRESH

// Called when tap on notification
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{

    NSLog(@"Notifcation tapped");
    
    // Display MP and refesh MP list
    [self.rootController setSelectedIndex:2];
    HFRNavigationController *nv = self.rootController.selectedViewController;
    [nv popToRootViewControllerAnimated:NO];
    if ([nv.topViewController isKindOfClass:[HFRMPViewController class]]) {
        [(HFRMPViewController *)nv.topViewController fetchContent];
    }
}



- (void)checkForNewMP:(BGAppRefreshTask *)task
{
    NSLog(@"Background fetch started");
    [self scheduleAppRefresh];
    NSInteger iOlfNbFailures = [[NSUserDefaults standardUserDefaults] integerForKey:@"nb_mp_failure"];
    [[NSUserDefaults standardUserDefaults] setInteger:(iOlfNbFailures+1) forKey:@"nb_mp_failure"];

    NSString *task_desc = task.description;
    [task setExpirationHandler:^{
        NSLog(@"\n\nExpired task: %@", task_desc);
    }];
    
    NSURL *url = [NSURL URLWithString:@"https://forum.hardware.fr"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.timeOutSeconds = 5;
    NSLog(@"Start request");
    [request startSynchronous];
    NSLog(@"Request done");
    if (![request error]) {
        NSLog(@"Request done with no error");
        @try {
            NSString* sResponseString  = [request responseString];
            NSError* error;
            HTMLParser *myParser = [[HTMLParser alloc] initWithString:sResponseString error:&error];
            HTMLNode *bodyNode = [myParser body]; //Find the body tag
            HTMLNode *MPNode = [bodyNode findChildOfClass:@"cCatTopic red"];
            NSString* sMPText = rawContentsOfNode([[MPNode firstChild] _node], [myParser _doc]);
            
            NSString *regExMP = @"[^.0-9]+([0-9]{1,})[^.0-9]+";
            NSString *myMPNumber = [sMPText stringByReplacingOccurrencesOfRegex:regExMP withString:@"$1"];
            
            NSInteger iNewNbMps = [myMPNumber intValue];
            NSLog(@"Unread MPs : %ld", (long)iNewNbMps);

            NSInteger iOldNbMps = [[NSUserDefaults standardUserDefaults] integerForKey:@"nb_mp"];
            NSLog(@"nb_mp : %ld", (long)iOldNbMps);
            if (iOldNbMps > 1000 || iOldNbMps < 0) {
                iOldNbMps = 0;
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"nb_mp"];
            }

            [[NSUserDefaults standardUserDefaults] setInteger:iOlfNbFailures forKey:@"nb_mp_failure"];
            [[NSUserDefaults standardUserDefaults] setInteger:iNewNbMps forKey:@"nb_mp"];
            if (iNewNbMps > iOldNbMps) {
                NSString* sNotif = @"";
                /*if ((iNewNbMps - iOldNbMps) == 1) {
                    sNotif = @"Vous avez un nouveau message privé";
                }
                else {
                    sNotif = [NSString stringWithFormat:@"Vous avez %ld nouveaux messages privés", (long)(iNewNbMps - iOldNbMps)];
                }*/
                /*if ([[[[MultisManager sharedManager] getMainCompte] objectForKey:PSEUDO_DISPLAY_KEY] isEqualToString:@"ezzz"])
                {
                    sNotif = [NSString stringWithFormat:@"Vous avez un nouveau message privé [%ld][%ld->%ld]", (long)(iOlfNbFailures), (long)iOldNbMps, (long)iNewNbMps];
                }
                else
                {*/
                sNotif = @"Vous avez un nouveau message privé";
                //}
                [self scheduleNotification:sNotif];
            }
            /* Activate this for debug
            else {
                [self scheduleNotification:@"rein du tout"];
                // Not working :(
                // [UIApplication sharedApplication].applicationIconBadgeNumber = 15;
            }*/
        }
        @catch (NSException * e) {
            NSLog(@"Error in parsing the result of the background fetch: %@", e);
        }
    }
    
    NSLog(@"Background fetch completed with task: %@", task.description);
    [task setTaskCompletedWithSuccess:TRUE];
}

- (void)scheduleNotification:(NSString*)sTextNotif
{
    NSLog(@"Scheduling notification with text : %@", sTextNotif);
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.body = sTextNotif;
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3.0 repeats:NO];
    
    NSString* requestId = [NSUUID UUID].UUIDString;
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:requestId content:content trigger:trigger];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
        NSLog(@"Notification request error: %@", error);
    }];
}

#endif // NOTIF

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"shortcutItem %@", shortcutItem);
    BOOL handled = NO;
    /*
    if (tabBarController.selectedIndex == 0 && [nv.topViewController isKindOfClass:[ForumsTableViewController class]]) {
        [(ForumsTableViewController *)nv.topViewController reload];
    }

    if (tabBarController.selectedIndex == 1 && [nv.topViewController isKindOfClass:[FavoritesTableViewController class]]) {
        [(FavoritesTableViewController *)nv.topViewController reload];
    }

    if (tabBarController.selectedIndex == 2 && [nv.topViewController isKindOfClass:[HFRMPViewController class]]) {
        [(HFRMPViewController *)nv.topViewController fetchContent];
    }
    */
    HFRNavigationController *nv = self.rootController.selectedViewController;
    if ([shortcutItem.type isEqual: @"hfrplus.red.super.openfavorites"]) {
        [self.rootController setSelectedIndex:1];
        [nv popToRootViewControllerAnimated:NO];
        if ([nv.topViewController isKindOfClass:[FavoritesTableViewController class]]) {
            [(FavoritesTableViewController *)nv.topViewController reload];
        }
        handled = YES;
    } else if ([shortcutItem.type isEqual: @"hfrplus.red.super.openmessages"]) {
        [self.rootController setSelectedIndex:2];
        [nv popToRootViewControllerAnimated:NO];
        if ([nv.topViewController isKindOfClass:[HFRMPViewController class]]) {
            [(HFRMPViewController *)nv.topViewController fetchContent];
        }
        handled = YES;
    } else if ([shortcutItem.type isEqual: @"hfrplus.red.super.opencategories"]) {
        [self.rootController setSelectedIndex:0];
        if ([nv.topViewController isKindOfClass:[ForumsTableViewController class]]) {
            [(ForumsTableViewController *)nv.topViewController reload];
        }
        handled = YES;
    }
    completionHandler(handled);
}

-(void)setThemeFromNotification:(NSNotification *)notification{
    [self setTheme:[[ThemeManager sharedManager] theme]];
}

-(void)setTheme:(Theme)theme{
    //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"theme_noel_disabled"];

    if ([self.window respondsToSelector:@selector(setTintColor:)]) {
        self.window.tintColor = [ThemeColors tintColor:theme];
    }
    
    if ([self.window respondsToSelector:@selector(setBackgroundColor:)]) {
        self.window.backgroundColor =[ThemeColors navBackgroundColor:theme];
    }
    
    
    if ([[UITabBar appearance] respondsToSelector:@selector(setTranslucent:)]) {
        [[UITabBar appearance] setTranslucent:YES];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [ThemeColors titleTextAttributesColor:theme]}];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"theme_noel_disabled"]) {
        [[UINavigationBar appearance] setBackgroundImage:[ThemeColors imageFromColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    }else{
        UIImage *navBG =[[UIImage animatedImageNamed:@"snow" duration:1.f]
                         resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeTile];
        [[UINavigationBar appearance] setBackgroundImage:navBG forBarMetrics:UIBarMetricsDefault];
    }
    [[UINavigationBar appearance] setBarTintColor:[ThemeColors navBackgroundColor:theme]];
    
     if (@available(iOS 13.0, *)) {
         switch ([ThemeManager currentTheme]) {
             case ThemeLight:
                 self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                 break;
             case ThemeDark:
                 self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
                 break;
             default:
                self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
                 break;
         }
     }
}


- (void)registerDefaultsFromSettingsBundle {
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"InAppSettings" ofType:@"bundle"];
        
    if(!settingsBundle) {
        //NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    // Main settings, root
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.inApp.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key && [prefSpecification objectForKey:@"DefaultValue"]) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }

    // ActionsMessages settings
    NSDictionary *settings2 = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"ActionsMessages.plist"]];
    NSArray *preferences2 = [settings2 objectForKey:@"PreferenceSpecifiers"];
    for(NSDictionary *prefSpecification in preferences2) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key && [prefSpecification objectForKey:@"DefaultValue"]) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];    
}


+ (HFRplusAppDelegate *)sharedAppDelegate
{
    return (HFRplusAppDelegate *) [UIApplication sharedApplication].delegate;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    NSLog(@"applicationDidEnterBackground");
    if (@available(iOS 13, *))
    {
        [self scheduleAppRefresh];
    }
    if (BACKGROUND_MAINTENANCE) {
        [periodicMaintenanceTimer invalidate];
    }
    
    periodicMaintenanceTimer = nil;
}

- (void) scheduleAppRefresh {
    if (@available(iOS 13, *))
    {
        NSLog(@"Scheduling the app background refresh");
        
        BGAppRefreshTaskRequest *request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:@"com.hfrplus.refresh_mp"];
        [request setEarliestBeginDate:[[NSDate date] dateByAddingTimeInterval:60]];
        //request.requiresNetworkConnectivity = YES;
        
        __autoreleasing NSError *error;
        @try {
            //NSLog(@"\n\nSubmitting task request: %@", request.description);
            [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:&error];
        } @catch (NSException *exception) {
            NSLog(@"\n\nCannot submit task request: %@", exception.description);
        } @finally {
            if (error)
            {
                NSLog(@"\n\nFailed to submit task request:\n%@ (%ld)", request.description, error.code);
            } else {
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"nb_mp_failure"];
                NSLog(@"Submitted task request %@", request.description);
                // 1) Pause here
                // 2) In output, type: To debug : e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.hfrplus.refresh_mp"]
                // 3) Unpause
            }
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    NSLog(@"applicationWillEnterForeground");
    
    if (BACKGROUND_MAINTENANCE) {
        periodicMaintenanceTimer = [NSTimer scheduledTimerWithTimeInterval:60*10
                                                                    target:self
                                                                  selector:@selector(periodicMaintenance)
                                                                  userInfo:nil
                                                                   repeats:YES];
    }
    // MPStorage : Update Blacklist from MPStorage
    [[MPStorage shared] initOrResetMP:[[MultisManager sharedManager] getCurrentPseudo]];
}

- (void)periodicMaintenance
{
    if (BACKGROUND_MAINTENANCE) {
        [self performSelectorInBackground:@selector(periodicMaintenanceBack) withObject:nil];
    }
}

- (void)periodicMaintenanceBack
{
    if (BACKGROUND_MAINTENANCE) {
        @autoreleasepool {
        
        //NSLog(@"periodicMaintenanceBack");

        // If another same maintenance operation is already sceduled, cancel it so this new operation will be executed after other
        // operations of the queue, so we can group more work together
        //[periodicMaintenanceOperation cancel];
        //self.periodicMaintenanceOperation = nil;

            /*NSError *error = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *URLResources = [NSArray arrayWithObject:@"NSURLCreationDateKey"];
            
            
            
            //NSArray *crashReportFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[[NSFileManager defaultManager] userLibraryURL] URLByAppendingPathComponent:@"ImageCache"] includingPropertiesForKeys:URLResources options:(NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsSubdirectoryDescendants) error:&error];

            
            */
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *diskCachePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"cache"] stringByAppendingPathComponent:@"avatars"];

            if (![fileManager fileExistsAtPath:diskCachePath])
            {
                //NSLog(@"createDirectoryAtPath");
                [fileManager createDirectoryAtPath:diskCachePath
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:NULL];
            }
            else {
                //NSLog(@"pas createDirectoryAtPath");
                
                
                NSString *directoryPath = diskCachePath;
                NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:directoryPath];
                
                NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:(-60*60*24*25)];
                //NSLog(@"yesterday %@", yesterday);
                
                for (NSString *path in directoryEnumerator) {

                    if ([[path pathExtension] isEqualToString:@"rtfd"]) {
                        // Don't enumerate this directory.
                        [directoryEnumerator skipDescendents];
                    }
                    else {
                        
                        NSDictionary *attributes = [directoryEnumerator fileAttributes];
                        NSDate *CreatedDate = [attributes objectForKey:NSFileCreationDate];

                        if ([yesterday earlierDate:CreatedDate] == CreatedDate) {
                            //NSLog(@"%@ was created %@", path, CreatedDate);
                            
                            NSError *error = nil;
                            if (![fileManager removeItemAtURL:[NSURL fileURLWithPath:[diskCachePath stringByAppendingPathComponent:path]] error:&error]) {
                                // Handle the error.
                                //NSLog(@"error %@ %@", path, error);
                            }
                            
                        }
                        else {
                            //NSLog(@"%@ was created == %@", path, CreatedDate);

                        }
                    }
                    
                }
                
                /*
                NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]
                                                     enumeratorAtURL:directoryURL
                                                     includingPropertiesForKeys:keys
                                                     options:(NSDirectoryEnumerationSkipsPackageDescendants |
                                                              NSDirectoryEnumerationSkipsHiddenFiles)
                                                     errorHandler:^(NSURL *url, NSError *error) {
                                                         // Handle the error.
                                                         // Return YES if the enumeration should continue after the error.
                                                         return YES;
                                                     }];
                
                for (NSURL *url in enumerator) {
                }
                 */
            }
            

            
        // If disk usage outrich capacity, run the cache eviction operation and if cacheInfo dictionnary is dirty, save it in an operation
            /* if (diskCacheUsage > self.diskCapacity)
        {
            self.periodicMaintenanceOperation = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(balanceDiskUsage) object:nil] autorelease];
            [ioQueue addOperation:periodicMaintenanceOperation];
        }*/
            //NSLog(@"end");
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"theme_noel_disabled"];

    // Noel
    NSDate * now = [NSDate date];
    NSDateFormatter* formatterLocal = [[NSDateFormatter alloc] init];
    [formatterLocal setDateFormat:@"dd MM yyyy - HH:mm"];
    [formatterLocal setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate* startNoelDate = [formatterLocal dateFromString:@"01 12 2020 - 00:00"];
    NSDate*   endNoelDate = [formatterLocal dateFromString:@"02 01 2021 - 00:00"];
    
    
    NSComparisonResult result1 = [now compare:startNoelDate];
    NSComparisonResult result2 = [now compare:endNoelDate];
    BOOL cestNoel = NO;
    if (result1 == NSOrderedDescending && result2 == NSOrderedAscending) {
        //C'est bientot Noel !!
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"theme_noel_period"];        
        NSObject* obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"noel_first_time"];
        if (obj == nil) {
            // La première fois on force le thème de Noel
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"theme_noel_disabled"];
            // Mais plus les suivantes
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"noel_first_time"];
            cestNoel = YES;
        }
    } else {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"theme_noel_disabled"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"theme_noel_period"];
    }
    
    
    NSLog(@"applicationDidBecomeActive");
    dispatch_after(0, dispatch_get_main_queue(), ^(void){
        [self setTheme:[[ThemeManager sharedManager] theme]];
         [[ThemeManager sharedManager] checkTheme];
         [[ThemeManager sharedManager] refreshTheme];
         if (cestNoel) {
             // Popup retry
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"C'est bientôt Noël !"
                                                                            message:@"Toute l'équipe de HFR+ vous souhaite de très bonnes fêtes de fin d'année !"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction* actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * action) { }];
             [alert addAction:actionOK];
             
             UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
             [activeVC presentViewController:alert animated:YES completion:nil];
             [[ThemeManager sharedManager] applyThemeToAlertController:alert];
             
         }
    });
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    
    
}

- (void)hidePrimaryPanelOnIpad {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad /*&& [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait*/) {
        UISplitViewController* splitViewController = [[HFRplusAppDelegate sharedAppDelegate] splitViewController];
        if (self.splitViewController.displayMode == UISplitViewControllerDisplayModePrimaryOverlay) {
            [UIView animateWithDuration:0.3 animations:^{
                splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
            } completion:^(BOOL finished){
                splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
            }];
        }
    }
}

- (void)updateMPBadgeWithString:(NSString *)badgeValue;
{
    //NSLog(@"%@ - %d", badgeValue, [badgeValue intValue]);
    [[NSUserDefaults standardUserDefaults] setInteger:[badgeValue intValue] forKey:@"nb_mp"];

    dispatch_async(dispatch_get_main_queue(),
                   ^{
        //[UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue intValue];
        int shift = 0;
        if ([[[[self rootController] tabBar] items] count] == 5) {
            shift = 1;
        }
        if ([badgeValue intValue] > 0) {
           [[[[[self rootController] tabBar] items] objectAtIndex:2 + shift] setBadgeValue:badgeValue];
       }
       else {
           [[[[[self rootController] tabBar] items] objectAtIndex:2 + shift] setBadgeValue:nil];
       }
   });
}

- (void)updatePlusBadgeWithString:(NSString *)badgeValue;
{
    dispatch_async(dispatch_get_main_queue(),
    ^{
        //[UIApplication sharedApplication].applicationIconBadgeNumber = [badgeValue intValue];
        int shift = 0;
        if ([[[[self rootController] tabBar] items] count] == 5) {
            shift = 1;
        }
        if ([badgeValue intValue] > 0) {
            [[[[[self rootController] tabBar] items] objectAtIndex:2 + shift] setBadgeValue:badgeValue];
                       }
                       else {
            [[[[[self rootController] tabBar] items] objectAtIndex:2 + shift] setBadgeValue:nil];
                       }});
}


- (void)readMPBadge;
{
    //NSLog(@"%@ - %d", badgeValue, [badgeValue intValue]);
    dispatch_async(dispatch_get_main_queue(), 
    ^{
    NSString *badgeValue = [[[[[self rootController] tabBar] items] objectAtIndex:2] badgeValue];
    
    if ( ([badgeValue intValue] - 1) > 0) {
        [self updateMPBadgeWithString:[NSString stringWithFormat:@"%d", [badgeValue intValue] - 1]];
    }
    else {
            int shift = 0;
            if ([[[[self rootController] tabBar] items] count] == 5) {
                shift = 1;
    }
            [[[[[self rootController] tabBar] items] objectAtIndex:2 + shift] setBadgeValue:nil];
            //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;

        }
    });
}


- (void)openURL:(NSString *)stringUrl
{
    //NSLog(@"stringUrl %@", stringUrl);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *web = [defaults stringForKey:@"default_web"];
    
    //NSLog(@"display %@", display);
    
    
    //Check Youtube/AppStore.
    //- http://itunes.apple.com/fr/app/idXXXXXXXX
    //- http://appstore.com/apple/keynote

    
    if ([web isEqualToString:@"internal"]) {
        if ([self.detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {
            //on load
            [((BrowserViewController *)self.detailNavigationController.topViewController).myModernWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringUrl]]];
        }
        else
        {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
                

                 NSURL *tmpURL = [NSURL URLWithString:stringUrl];
                 NSArray *imtsHost = [NSArray arrayWithObjects: @"itunes.apple.com", nil];
                 NSArray *youtubeHost = [NSArray arrayWithObjects:@"youtu.be", @"www.youtube.com", @"m.youtube.com", nil];
                 
                 if ([imtsHost indexOfObject:tmpURL.host] != NSNotFound) {
                     NSRange rangeOfScheme = [[tmpURL absoluteString] rangeOfString:[tmpURL scheme]];
                     tmpURL = [NSURL URLWithString:[[tmpURL absoluteString] stringByReplacingCharactersInRange:rangeOfScheme withString:@"itms-apps"]];
                     
                     
                     if ([[UIApplication sharedApplication] canOpenURL:tmpURL]) {
                        [[UIApplication sharedApplication] openURL:tmpURL];
                         return;
                     }
                     
                }
                else if ([youtubeHost indexOfObject:tmpURL.host] != NSNotFound) {
                    NSRange rangeOfScheme = [[tmpURL absoluteString] rangeOfString:[tmpURL scheme]];
                    tmpURL = [NSURL URLWithString:[[tmpURL absoluteString] stringByReplacingCharactersInRange:rangeOfScheme withString:@"youtube"]];


                    if ([[UIApplication sharedApplication] canOpenURL:tmpURL]) {
                        [[UIApplication sharedApplication] openURL:tmpURL];
                        return;
                    }
                 
                 }


                
                SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:stringUrl]];
                
                [self.rootController presentModalViewController:svc animated:YES];
            }
            else {
                BrowserViewController *browserViewController = [[BrowserViewController alloc] initWithURL:stringUrl];
                
                HFRNavigationController *nc = [[HFRNavigationController alloc] initWithRootViewController:browserViewController];
                
                
                nc.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [self.rootController presentModalViewController:nc animated:YES];
            }
        }
    }
    else {
        //iOS9 + Phone || Pad+Compact = pas de confirm
        NSLog(@"alerte");
        
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) ||
            (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad   && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") &&
             [[HFRplusAppDelegate sharedAppDelegate].window respondsToSelector:@selector(traitCollection)] && [HFRplusAppDelegate sharedAppDelegate].window.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact))
        {
            
            NSLog(@"compact ios 9");

            NSURL *tmpURL2 = [NSURL URLWithString:stringUrl];
            NSURL *tURL = [NSURL URLWithString:stringUrl];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *web = [defaults stringForKey:@"default_web"];
            
            if ([web isEqualToString:@"googlechrome"]) {
                NSRange rangeOfScheme = [[tmpURL2 absoluteString] rangeOfString:[tmpURL2 scheme]];
                tURL = [NSURL URLWithString:[[tmpURL2 absoluteString] stringByReplacingCharactersInRange:rangeOfScheme withString:web]];
                NSLog(@"new url for GChrome URL %@", tURL);
            }
            
            if ([[UIApplication sharedApplication] canOpenURL:tURL]) {
                NSLog(@"YES YOU CAN GChrome%@", tURL);
                [[UIApplication sharedApplication] openURL:tURL];
                return;

            }
            else {
                NSLog(@"NO YOU CANT GChrome %@", tURL);
                
                if ([[UIApplication sharedApplication] canOpenURL:tmpURL2]) {
                    NSLog(@"YES YOU CAN %@", tmpURL2);
                    [[UIApplication sharedApplication] openURL:tmpURL2];
                    return;
                }
                else {
                    NSLog(@"NO YOU CANT %@", tmpURL2);
                }
            }
            
            
                

        }
        
        //iOS9 + Pad + FullScreen = confirme (Nav+)

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            NSString *msg = [NSString stringWithFormat:@"Vous allez quitter HFR+ et être redirigé vers :\n %@\n", stringUrl];
            
            UIAlertViewURL *alert = [[UIAlertViewURL alloc] initWithTitle:@"Attention !" message:msg
                                                                 delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Confirmer", @"Navigateur✚",  nil];
            [alert setStringURL:stringUrl];
            
            [alert show];
        }
        else
        {
            NSString *msg = [NSString stringWithFormat:@"Vous allez quitter HFR+ et être redirigé vers :\n %@\n", stringUrl];
            
            UIAlertViewURL *alert = [[UIAlertViewURL alloc] initWithTitle:@"Attention !" message:msg
                                                                 delegate:self cancelButtonTitle:@"Annuler" otherButtonTitles:@"Confirmer", nil];
            [alert setStringURL:stringUrl];
            
            [alert show];
        }

    }
    

}

- (void)alertView:(UIAlertViewURL *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        NSURL *tURLbase = [NSURL URLWithString:[alertView stringURL]];
        NSURL *tURL = [NSURL URLWithString:[alertView stringURL]];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *web = [defaults stringForKey:@"default_web"];
        
        if ([web isEqualToString:@"googlechrome"]) {
            NSRange rangeOfScheme = [[tURLbase absoluteString] rangeOfString:[tURLbase scheme]];
            tURL = [NSURL URLWithString:[[tURLbase absoluteString] stringByReplacingCharactersInRange:rangeOfScheme withString:web]];
            NSLog(@"tURL %@", tURL);
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:tURL]) {
            NSLog(@"YES YOU CAN %@", tURL);
            [[UIApplication sharedApplication] openURL:tURL];
        }
        else {
            NSLog(@"NO YOU CANT %@", tURL);

            [[UIApplication sharedApplication] openURL:tURLbase];
        }
        
    }
    else if (buttonIndex == 2) {
        if ([[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController isMemberOfClass:[BrowserViewController class]]) {
            //on load
            [((BrowserViewController *)[HFRplusAppDelegate sharedAppDelegate].detailNavigationController.topViewController).myModernWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[alertView stringURL]]]];
        }
        else {
            //on move/decale
            //[self cancel];
            [[HFRplusAppDelegate sharedAppDelegate].splitViewController NavPlus:[alertView stringURL]];
            
        }
    }
}

- (void)login
{
    if (![self isLoggedIn]) {
        [self setStatusChanged:YES];
    }
    [self setIsLoggedIn:YES];

}

- (void)logout
{
    if ([self isLoggedIn]) {
        
        [self setStatusChanged:YES];
        [self updateMPBadgeWithString:nil]; //reset MP Badge
        
        [self resetApp];
        
        if(favoritesNavController){
            if ([favoritesNavController respondsToSelector:@selector(visibleViewController)]) {
                FavoritesTableViewController* favVC = (FavoritesTableViewController *)[favoritesNavController visibleViewController];
                if ([favVC respondsToSelector:@selector(reset)]) {
                    [favVC reset];
                }
            }
        }
        if(messagesNavController){
            if ([messagesNavController respondsToSelector:@selector(visibleViewController)]) {
                HFRMPViewController* mpVC = (HFRMPViewController *)[messagesNavController visibleViewController];
                if ([mpVC respondsToSelector:@selector(reset)]) {
                    [mpVC reset];
                }
            }
        }
 
    }
    
    [self setIsLoggedIn:NO];    
}

- (void)resetApp {
    //NSLog(@"resetApp");
    
    [forumsNavController popToRootViewControllerAnimated:NO];
    [favoritesNavController popToRootViewControllerAnimated:NO];
    [messagesNavController popToRootViewControllerAnimated:NO];
    [searchNavController popToRootViewControllerAnimated:NO];
    
    
    UIViewController * uivc = [[UIViewController alloc] init];
    uivc.title = @"HFR+";
    
    [[[HFRplusAppDelegate sharedAppDelegate] detailNavigationController] setViewControllers:[NSMutableArray arrayWithObjects: uivc, nil] animated:NO];

}

#pragma mark - login management

- (void)checkLogin {
    //NSLog(@"checkLogin");
}

#pragma mark - Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    //NSLog(@"mem warning %@ %@", self, NSStringFromSelector(_cmd));
}

- (void)dealloc {
    if (BACKGROUND_MAINTENANCE) {
        [periodicMaintenanceTimer invalidate];
    }
    periodicMaintenanceTimer = nil;
}


@end
