//
//  FilterPostsQuotes.m
//  SuperHFRplus
//
//  Created by ezzz on 05/04/2020.
//

#import "FilterPostsQuotes.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"
#import "RegexKitLite.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"
#import "ParseMessagesOperation.h"
#import "FavoritesTableViewController.h"
#import "MessagesTableViewController.h"
#import "HFRAlertView.h"

@implementation FilterPostsQuotes

@synthesize topic, request, arrData, iLastPageLoaded, bIsFinished, progressView, alertProgress, favoriteVC, messagesTableVC, bShowPostsRequired, stopRequired;

//static FilterPostsQuotes *_shared = nil;    // static instance variable

// --------------------------------------------------------------------------------
#pragma mark Init methods
// --------------------------------------------------------------------------------

/*
+ (FilterPostsQuotes *)shared {
    if (_shared == nil) {
        _shared = [[super allocWithZone:NULL] init];
    }
    return _shared;
}*/



#pragma mark Main method

- (void)checkPostsAndQuotesForTopic:(Topic *)topic andVC:(FavoritesTableViewController*) vc{
    self.favoriteVC = vc;
    self.messagesTableVC = nil;
    [self addProgressBar:vc];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchContentForTopic:topic];
    });
}

- (void)checkNextPostsAndQuotesWithVC:(MessagesTableViewController*) vc {
    self.messagesTableVC = vc;
    [self addProgressBar:vc];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchContentForTopic:self.topic startPage:self.iLastPageLoaded + 1];
    });
}

#pragma mark Work methods

- (void)fetchContentForTopic:(Topic*)topic {
    [self fetchContentForTopic:topic startPage:0];
}

- (void)fetchContentForTopic:(Topic*)topic startPage:(int)iStartPage {
    self.topic = topic;
    [ASIHTTPRequest setDefaultTimeOutSeconds:kTimeoutMaxi];
    self.arrData = [[NSMutableArray alloc] init];
    self.bShowPostsRequired = NO;
    self.stopRequired = NO;
    int iPageToLoad = topic.curTopicPage;
    if (iStartPage > 0) {
        iPageToLoad = iStartPage;
    }
    self.iStartPage = iPageToLoad;
    int iNbPagesLoaded = 0;
    while (iPageToLoad <= topic.maxTopicPage) {
        NSLog(@"Loading Topic page %d", iPageToLoad);
    
        NSString* sURL = [NSString stringWithFormat:@"https://forum.hardware.fr%@", [topic getURLforPage:iPageToLoad]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sURL]];
        [request setShouldRedirect:YES];
        [request setDelegate:self];
        [request setUseCookiePersistence:NO];
        [request setRequestCookies:[[NSMutableArray alloc]init]];
        [request startSynchronous];
        if (request) {
            if ([request error]) {
                NSLog(@"error: %@", [[request error] localizedDescription]);
                return;
            }
            
            if ([request responseData]) {
                ParseMessagesOperation *parser = [[ParseMessagesOperation alloc] initWithData:[request responseData] index:0 reverse:NO delegate:nil];
                NSError * error = nil;
                HTMLParser *myParser = [[HTMLParser alloc] initWithData:[request responseData] error:&error];
                [parser parseData:myParser filterPostsQuotes:YES topicUrl:topic.aURL topicPage:iPageToLoad];
                self.arrData = [self.arrData arrayByAddingObjectsFromArray:parser.workingArray];
            }
        }
        if (self.arrData.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray* arrActions = [self.alertProgress actions];
                [arrActions[0] setEnabled:YES];
            });
        }
        float fProgress = ((float)iNbPagesLoaded)/(topic.maxTopicPage - iStartPage);
        NSString* sMessage = @"Aucun post trouvé";
        if (self.arrData.count == 1) {
            sMessage = @"1 post trouvé";
        }
        else if (self.arrData.count > 1) {
            sMessage = [NSString stringWithFormat:@"%ld posts trouvés", (long)self.arrData.count];
        }
        //sMessage = [NSString stringWithFormat:@"n%@", (unsigned long)iPageToLoad, sMessage];
        [self updateProgressBarWithPercent:fProgress andMessage:sMessage];
        
        if (self.arrData.count >= 40 || self.bShowPostsRequired || self.stopRequired) {
            break;
        }
        else {
            iPageToLoad++;
            iNbPagesLoaded++;
        }
    }
    self.iLastPageLoaded = iPageToLoad;
    if (iPageToLoad == topic.maxTopicPage) {
        self.bIsFinished = NO;
    }
    if (!self.stopRequired && (self.arrData.count >= 40 || self.bShowPostsRequired || (self.arrData.count > 1 && bIsFinished))) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.alertProgress dismissViewControllerAnimated:NO completion:nil];
            NSArray* arrActions = [self.alertProgress actions];
            [arrActions[0] setEnabled:NO];
            if (self.messagesTableVC) {
                [self displayNextPosts];
            }
            else {
                [self displayPosts:topic];
            }
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView.progress = 1.0;
            [self.alertProgress setTitle:@"Résultat"];
            //[self dismissViewControllerAnimated:YES completion:nil];
            //[self.offlineTableView reloadData];
        });
    }
}

// --------------------------------------------------------------------------------
#pragma mark -
#pragma mark HMI methods
// --------------------------------------------------------------------------------

- (void) addProgressBar:(UIViewController*)vc {
    self.alertProgress = [UIAlertController alertControllerWithTitle:@"Chargement..." message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* actionAfficher = [UIAlertAction actionWithTitle:@"Afficher" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.bShowPostsRequired = YES;}];
    [actionAfficher setEnabled:NO];
    [self.alertProgress addAction:actionAfficher];
    [self.alertProgress addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.stopRequired = YES;
    }]];

    UIView *alertView = self.alertProgress.view;

    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    self.progressView.progress = 0.0;
    self.progressView.translatesAutoresizingMaskIntoConstraints = false;
    [alertView addSubview:self.progressView];


    NSLayoutConstraint *bottomConstraint = [self.progressView.bottomAnchor constraintEqualToAnchor:alertView.bottomAnchor];
    [bottomConstraint setActive:YES];
    bottomConstraint.constant = -45; // How to constraint to Cancel button?

    [[self.progressView.leftAnchor constraintEqualToAnchor:alertView.leftAnchor] setActive:YES];
    [[self.progressView.rightAnchor constraintEqualToAnchor:alertView.rightAnchor] setActive:YES];

    [vc presentViewController:self.alertProgress animated:true completion:nil];
}

-(void) updateProgressBarWithPercent:(float)fPercent andMessage:(NSString*)sMessage {
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self.alertProgress setMessage:[NSString stringWithFormat:@"%@", sMessage]];
        self.progressView.progress = fPercent;
        [self.alertProgress setMessage:sMessage];
    });
}

-(void) displayPosts:(Topic*)topic {
    MessagesTableViewController *aView = [[MessagesTableViewController alloc] initWithNibName:@"MessagesTableViewController" bundle:nil andUrl:topic.aURL displaySeparator:YES];
    self.favoriteVC.messagesTableViewController = aView;

    //setup the URL
    self.favoriteVC.messagesTableViewController.filterPostsQuotes = self;
    self.favoriteVC.messagesTableViewController.topic = topic;
    self.favoriteVC.messagesTableViewController.topicName = topic.aTitle;

    //NSLog(@"push message liste");
    [self.favoriteVC pushTopic];
}

-(void) displayNextPosts {
    self.messagesTableVC.pageNumberFilterStart = self.iStartPage;
    self.messagesTableVC.pageNumberFilterEnd = self.iLastPageLoaded;
    [self.messagesTableVC manageLoadedItems:self.arrData];
    self.messagesTableVC.pageNumberFilterStart = self.iStartPage;
    self.messagesTableVC.pageNumberFilterEnd = self.iLastPageLoaded;
    [self.messagesTableVC setupScrollAndPage];
}

@end
