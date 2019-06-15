//
//  Favorite.m
//  HFRplus
//
//  Created by FLK on 04/07/10.
//

#import "LinkItem.h"
#import "RegexKitLite.h"
#import "HFRplusAppDelegate.h"
#import "ThemeColors.h"
#import "ThemeManager.h"
#import "MultisManager.h"
#import "BlackList.h"

@implementation LinkItem

@synthesize postID, lastPageUrl, lastPostUrl, viewed, name, url, flagUrl, typeFlag, rep, dicoHTML, messageDate, imageUI, textViewMsg, messageNode, messageAuteur;
@synthesize urlQuote, urlAlert, urlEdit, urlProfil, addFlagUrl, quoteJS, MPUrl, isDel, isBL;

@synthesize quotedNB, quotedLINK, editedTime;

-(NSString *)toHTML:(int)index egoQuote:(BOOL)egoQuote
{
    //NSLog(@"toHTML index %d", index);
    BOOL bIsPostBL = NO;
    if ([[BlackList shared] isBL:[self name]]) {
        bIsPostBL = YES;
    }
    
    // Get current own pseudo
    MultisManager *manager = [MultisManager sharedManager];
    NSDictionary *mainCompte = [manager getMainCompte];
    NSString *currentPseudo = [mainCompte objectForKey:PSEUDO_DISPLAY_KEY];
    NSString *currentPseudoLowercase = [[mainCompte objectForKey:PSEUDO_DISPLAY_KEY] lowercaseString];

    
	NSString *tempHTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"templatev2" ofType:@"htm"] encoding:NSUTF8StringEncoding error:NULL];

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	
	if([self isDel]){
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message del"];
	}

	if ([[self name] isEqualToString:@"Modération"]) {
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message mode "];
	} else if (egoQuote == YES && [[[self name] lowercaseString] isEqualToString:currentPseudoLowercase]) {
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message me"];
    } else if (bIsPostBL) {
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message bl\" style=\"display:none;"];
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"header" withString:@"class=\"header bl\""];
    }

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_PSEUDO%%" withString:[self name]];
    tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%POSTID%%" withString:[self postID]];
    
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%MESSAGE_DATE%%" withString:[[self messageDate] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

	//tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_AVATAR_SRC%%" withString:@"bundle://avatar_male_gray_on_light_48x48.png"];

	if([self imageUI] != nil){
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_AVATAR_SRC%%" withString:@"background-image:url('%%AUTEUR_AVATAR_SRC%%');"];
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_AVATAR_SRC%%" withString:[self imageUI]]; //avatar_male_gray_on_light_48x48.png //imageUrl
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%no_avatar_class%%" withString:@""];
    }
	else {
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_AVATAR_SRC%%" withString:@""];        
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%no_avatar_class%%" withString:@"noavatar"];
	}

    NSString *myRawContent = [[self dicoHTML] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    /*
    if (bIsPostBL) {
        NSString *show_hide = [NSString stringWithFormat:@"var x = document.getElementById('bl_%d');if (x.style.display === 'none') {x.style.display = 'block';} else {x.style.display = 'none';}", index];
        myRawContent = [NSString stringWithFormat:@"<div class=\"blacklist_group\"><div class=\"blacklist_showhidetext\"><a target=\"_blank\" onclick=\"%@\">&#9661;</a></div><div class=\"blacklist_content\" id=\"bl_%d\">%@", show_hide, index, myRawContent];
    }*/

    myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"---------------" withString:@""];
    
    // For each BL pseudo, add the HTML div to replace classic quote
    NSLog(@"----------------> BEFORE (%d) <-----------------", index);
    NSLog(@"%@", myRawContent);
    NSLog(@"----------------> /BEFORE (%d) <-----------------", index);
    /*
    NSString *show_quote = @"<table class=\"bl_quote_group\"><tr class=\"none\"><td><b class=\"s1\"><div class=\"bl_quote_left\" style=\"float: left;\"><b>citation masquée</b></div></td><td><div class=\"bl_quote_right\" style=\"float: right;\"><a target=\"_blank\" onclick=\"%@\">&#9661;</a></div></div></td></tr></table>";
    myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"<table class=\"citation_blacklist\""
                                                           withString:[NSString stringWithFormat:@"%@<table class=\"citation_blacklist\"",show_quote]];
    */
    NSString* sShowQuoteJS = [NSString stringWithFormat:@"document.getElementById($1).style.display = ''; document.getElementById(1$1).style.display = 'none'; document.getElementById(1$1).style.display = 'none'; document.getElementById(3$1).style.display = '';"];
    NSString *sShowQuote = [NSString stringWithFormat:@"<table class=\"bl_quote_show\" id=\"1$1\"><tr class=\"none\"><td><b class=\"s1\"><div class=\"bl_quote_left\" style=\"float: left;\"><b>citation masquée</b></div></td><td><div class=\"bl_quote_right\" style=\"float: right;\"><a target=\"_blank\" onclick=\"%@\">&#9661;</a></div></div></td></tr></table>", sShowQuoteJS];
    /*
    NSString* sHideQuoteJS = [NSString stringWithFormat:@"document.getElementById($1).style.display = 'none'; document.getElementById(1$1).style.display = ''; document.getElementById(1$1).style.display = ''; document.getElementById(3$1).style.display = 'none';"];
    NSString *sHideQuote = [NSString stringWithFormat:@"<table class=\"bl_quote_hide\" id=\"3$1\" style=\"display: none;\"><tr class=\"none\"><td><b class=\"s1\"><div class=\"bl_quote_left\" style=\"float: left;\"><b>$2 a écrit:</b></div></td><td><div class=\"bl_quote_right\" style=\"float: right;\"><a target=\"_blank\" onclick=\"%@\">&#9667;</a></div></div></td></tr></table>", sHideQuoteJS];
    
    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:@"<table class=\"citation_blacklist\" id=\"([0-9]+)\" auteur=\"([^\"]+)\""
                                                          withString:[NSString stringWithFormat:@"%@%@<table class=\"citation_blacklist\" id=\"$1\"", sShowQuote, sHideQuote]];*/

    //V2
    // Add "Show quote" button
    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:@"<table class=\"citation_blacklist\" id=\"([0-9]+)\" auteur=\"([^\"]+)\""
                                                          withString:[NSString stringWithFormat:@"%@<table class=\"citation_blacklist\" id=\"$1\"", sShowQuote]];

    // Add "Hide quote" button
    NSString* sHideQuoteJS = [NSString stringWithFormat:@"document.getElementById($1).style.display = 'none'; document.getElementById(1$1).style.display = ''; document.getElementById(1$1).style.display = ''; document.getElementById(3$1).style.display = 'none';"];
    NSString *sHideQuote = [NSString stringWithFormat:@"</td><td><div class=\"bl_quote_right\" style=\"float: right;\"><a target=\"_blank\" onclick=\"%@\">&#9651;</a></div></tr><tr><td>", sHideQuoteJS];
                            //table class=\"bl_quote_hide\" id=\"3$1\" style=\"display: none;\"><tr class=\"none\"><td><b class=\"s1\"><div class=\"bl_quote_left\" style=\"float: left;\"><b>$2 a écrit:</b></div></td><td><div class=\"bl_quote_right\" style=\"float: right;\"><a target=\"_blank\" onclick=\"%@\">&#9667;</a></div></div></td></tr></table>", sHideQuoteJS];


    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:@"<p class=\"pbl\" id=\"([0-9]+)\""
                                                           withString:[NSString stringWithFormat:@"%@<p class=\"pbl\"", sHideQuote]];

    
    NSLog(@"----------------> AFTER (%d) <-----------------", index);
    NSLog(@"%@", myRawContent);
    NSLog(@"----------------> /AFTER (%d) <-----------------", index);

	
	//Custom Internal Images
	NSString *regEx2 = @"<img src=\"http://forum-images.hardware.fr/([^\"]+)\" alt=\"\\[[^\"]+\" title=\"[^\"]+\">";			
	myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx2
														withString:@"<img class=\"smileycustom\" src=\"https://forum-images.hardware.fr/$1\" />"]; //
    //Custom Internal Images
    NSString *regEx22 = @"<img src=\"https://forum-images.hardware.fr/([^\"]+)\" alt=\"\\[[^\"]+\" title=\"[^\"]+\">";
    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx22
                                                          withString:@"<img class=\"smileycustom\" src=\"https://forum-images.hardware.fr/$1\" />"]; //


	//Native Internal Images
	NSString *regEx0 = @"<img src=\"http://forum-images.hardware.fr/[^\"]+/([^/]+)\" alt=\"[^\"]+\" title=\"[^\"]+\">";			
	myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx0
														  withString:@"|NATIVE-$1-98787687687697|"];

    NSString *regEx02 = @"<img src=\"https://forum-images.hardware.fr/[^\"]+/([^/]+)\" alt=\"[^\"]+\" title=\"[^\"]+\">";
    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx02
                                                          withString:@"|NATIVE-$1-98787687687697|"];
	//Replacing Links by HREF
	//NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\">[^<]+</a>";			
	//myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
	//													  withString:@"$1"];			
	
	//myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"|EXTERNAL-98787687687697|" withString:@"<img src='image.png' />"];
	
	
	//Toyonos Images http://hfr.toyonos.info/generateurs/rofl/?s=shay&v=4&t=5
	//NSString *regExToyo = @"<img src=\"http://hfr.toyonos.info/generateurs/([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" style=\"[^\"]+\">";			
	//myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regExToyo
	//													  withString:@"<img src=\"http://hfr.toyonos.info/generateurs/$1\">"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *display = [defaults stringForKey:@"display_images"];

    
	
    //NSLog(@"display %@", display);
    
    myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"hfr-rehost.net" withString:@"reho.st"]; // changement de domaine hfr-rehost
    NSString *landscape = [ThemeColors landscapePath:[[ThemeManager sharedManager] theme]];
    
	if ([display isEqualToString:@"no"]) {
        
		//Replacing Links with IMG with custom IMG
		NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\"><img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\"></a>";			
		myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
															  withString:[NSString stringWithFormat:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"%@\" alt=\"$2\" longdesc=\"$1\">",landscape]];
		
		//External Images			
		NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";			
		myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
                                                              withString:[NSString stringWithFormat:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"%@\" alt=\"$1\" longdesc=\"\">",landscape]];
		
		
	} else if ([display isEqualToString:@"yes"]) {
		NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\"><img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\"></a>";			
		myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
															  withString:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"$2\" alt=\"$2\" longdesc=\"$1\">"];
		
		//External Images			
		NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";			
		myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
															  withString:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"$1\" alt=\"$1\" longdesc=\"\">"];
	} else if ([display isEqualToString:@"wifi"]) {
        
        NetworkStatus netStatus = [[[HFRplusAppDelegate sharedAppDelegate] internetReach] currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            case ReachableViaWWAN:
            {
                //NSLog( @"Reachable WWAN");
                //Replacing Links with IMG with custom IMG
                NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\"><img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\"></a>";			
                myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
                                                                      withString:[NSString stringWithFormat:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"%@\" alt=\"$2\" longdesc=\"$1\">",landscape]];
                
                //External Images			
                NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";			
                myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
                                                                      withString:[NSString stringWithFormat:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"%@\" alt=\"$1\" longdesc=\"\">",landscape]];
                break;
            }
            case ReachableViaWiFi:
            {
               // NSLog( @"Reachable WiFi");
                NSString *regEx3 = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"cLink\"><img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\"></a>";			
                myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx3
                                                                      withString:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"$2\" alt=\"$2\" longdesc=\"$1\">"];
                
                //External Images			
                NSString *regEx = @"<img src=\"([^\"]+)\" alt=\"[^\"]+\" title=\"[^\"]+\" onload=\"[^\"]+\" style=\"[^\"]+\">";			
                myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx
                                                                      withString:@"<img onClick=\"window.location = 'oijlkajsdoihjlkjasdoimbrows://'+this.title+'/'+encodeURIComponent(this.alt); return false;\" class=\"hfrplusimg\" title=\"%%%%ID%%%%\" src=\"$1\" alt=\"$1\" longdesc=\"\">"];
                
                break;
            }
        }
    }
	
	//Replace Internal Images with Bundle://
	NSString *regEx4 = @"\\|NATIVE-([^-]+)-98787687687697\\|";			
	myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regEx4
														  withString:@"<img src='$1' />"];
	
    //Check signature//
    NSString *display_sig = [defaults stringForKey:@"display_sig"];
    
    if (![display_sig isEqualToString:@"yes"]) {
        NSRange range = [myRawContent rangeOfString:@"<span class=\"signature\">"];
        if (range.location == NSNotFound) {
            //NSLog(@"*****No signature ******");
        } else {
            //NSLog(@"*****Signature !!! ******");
            NSString *separatorString = @"<span class=\"signature\">";
            NSString *newRC = [myRawContent componentsSeparatedByString:separatorString].firstObject;
            myRawContent = newRC;
            myRawContent = [myRawContent stringByAppendingString:@"</div>"];
        }
    }

    //NSLog(@"--------------\n%@", myRawContent);
	
    if (self.quotedNB) {
        myRawContent = [myRawContent stringByAppendingString:[NSString stringWithFormat:@"<a class=\"quotedhfrlink\" href=\"%@\">%@</a>", self.quotedLINK, self.quotedNB]];
    }
    if (self.editedTime) {
        myRawContent = [myRawContent stringByAppendingString:[NSString stringWithFormat:@"<p class=\"editedhfrlink\">édité par %@</p>", self.editedTime]];
    }
    
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%MESSAGE_CONTENT%%" withString:myRawContent];
	
    //NSLog(@"%@", tempHTML);
    tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%%%ID%%%%" withString:[NSString stringWithFormat:@"%d", index]];

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%ID%%" withString:[NSString stringWithFormat:@"%d", index]];

	
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];	
	
    if (bIsPostBL) {
        //NSString* sShowHide = [NSString stringWithFormat:@"var x = document.getElementById(%d);if (x.style.display === 'none') {x.style.display = 'block';} else {x.style.display = 'none';}", index];
        
        NSString* sHidePostJS = [NSString stringWithFormat:@"document.getElementById(%d).style.display = 'none'; document.getElementById(10%d).style.display = 'block'; document.getElementById(20%d).style.display = 'block';", index, index, index];
        NSString* sHidePostDiv = [NSString stringWithFormat: @"<div class=\"hidepost\"><a class=\"buttonshow\" target=\"_blank\" onclick=\"%@\"> &#9651; </a></div><div class=\"content\">", sHidePostJS];
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"<div class=\"content\">" withString:sHidePostDiv];
        tempHTML = [tempHTML stringByAppendingString:@"</div>"];
        
        NSString* sShowPostJS = [NSString stringWithFormat:@"document.getElementById(%d).style.display = 'block'; document.getElementById(10%d).style.display = 'none'; document.getElementById(20%d).style.display = 'none';", index, index, index];
        NSString* sShowPostDiv = [NSString stringWithFormat: @"<div class=\"message headerblacklist\" id=\"10%d\" style=\"display='block'\"><div class=\"left\"></div><div class=\"right\"><a class=\"buttonhide\" target=\"_blank\" onclick=\"%@\"> &#9661; </a></div></div><div class=\"message separator\" id=\"20%d\"></div>", index, sShowPostJS, index];
        //NSString* sShowPostDiv = [NSString stringWithFormat: @"<div class=\"message headerblacklist\" id=\"10%d\" style=\"display='block'\"><table><tr><td><div class=\"left\">message masqué</div></td><td><div class=\"right\"><a class=\"buttonhide\" target=\"_blank\" onclick=\"%@\"> &#9660; </a></div></td></tr></table></div><div class=\"message separator\" id=\"20%d\"></div>", index, sShowPostJS, index];
        tempHTML = [sShowPostDiv stringByAppendingString:tempHTML];
    }
    
    NSLog(@"----------------> OUTPUT  <---------------------");
    NSLog(@"%@", tempHTML);
    NSLog(@"----------------> /OUTPUT <---------------------");

	return tempHTML;
}

@end
