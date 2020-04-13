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
@synthesize urlQuote, urlAlert, urlEdit, urlProfil, addFlagUrl, quoteJS, MPUrl, isDel, isBL, iPage;

@synthesize quotedNB, quotedLINK, editedTime;

-(NSString *)toHTML:(int)index isMP:(BOOL)bIsMP
{
    //NSLog(@"toHTML index %d", index);
    BOOL bIsPostBL = NO;
    if ([[BlackList shared] isBL:[self name]]) {
        bIsPostBL = YES;
    }
    
    // Get current own pseudo
    MultisManager *manager = [MultisManager sharedManager];
    NSDictionary *mainCompte = [manager getMainCompte];
    NSString *currentPseudoLowercase = [[mainCompte objectForKey:PSEUDO_DISPLAY_KEY] lowercaseString];

    
	NSString *tempHTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"templatev2" ofType:@"htm"] encoding:NSUTF8StringEncoding error:NULL];

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	
	if([self isDel]){
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message del"];
	}

	if ([[self name] isEqualToString:@"Modération"]) {
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message mode"];
	} else if ([[[self name] lowercaseString] isEqualToString:currentPseudoLowercase]) {
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message me"];
    } else if ([[BlackList shared] isWL:[self name]]) {
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message whitelist"];
    } else if (bIsPostBL) {
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message bl\" style=\"height:0px;"];
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"header" withString:@"class=\"header bl\""];
    }

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%AUTEUR_PSEUDO%%" withString:[self name]];
    tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%POSTID%%" withString:[self postID]];
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%MESSAGE_DATE%%" withString:[[self messageDate] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

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

    myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"---------------" withString:@""];
    
    // Add "Show quote" button
    NSString* sShowQuoteJS = [NSString stringWithFormat:@"document.getElementById($1).style.display = ''; document.getElementById(1$1).style.display = 'none'; document.getElementById(1$1).style.display = 'none'; document.getElementById(3$1).style.display = '';"];
    
    NSString* sTextePseudo = @"$2 a écrit :";
    NSString* sRegExpQuoteBL = @"<table class=\"citation_blacklist\" id=\"([0-9]+)\" auteur=\"([^\"]+)\"";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"blacklist_hide_pseudo"]) {
        sTextePseudo = @"Citation masquée";
        sRegExpQuoteBL = @"<table class=\"citation_blacklist\" id=\"([0-9]+)\" auteur=\"[^\"]+\"";
    }
    NSString *sShowQuote = [NSString stringWithFormat:@"<table class=\"bl_quote_show\" id=\"1$1\"><tr class=\"none\"><td><b class=\"s1\"><div class=\"bl_quote_left\" style=\"float: left;\"><b>%@</b></div></td><td><div class=\"bl_quote_right\" style=\"float: right;\"><a class=\"buttonshow\" target=\"_blank\" onclick=\"%@\">&#9660;</a></div></div></td></tr></table>", sTextePseudo, sShowQuoteJS];
    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:sRegExpQuoteBL
                                                          withString:[NSString stringWithFormat:@"%@<table class=\"citation_blacklist\" id=\"$1\"", sShowQuote]];

    // Add "Hide quote" button
    NSString* sHideQuoteJS = [NSString stringWithFormat:@"document.getElementById($1).style.display = 'none'; document.getElementById(1$1).style.display = ''; document.getElementById(1$1).style.display = ''; document.getElementById(3$1).style.display = 'none';"];
    NSString *sHideQuote = [NSString stringWithFormat:@"</td><td><div class=\"bl_quote_right\" style=\"float: right;\"><a class=\"buttonhide\" target=\"_blank\" onclick=\"%@\">&#9650;</a></div></tr><tr><td colspan=\"2\">", sHideQuoteJS];

    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:@"<p class=\"pbl\" id=\"([0-9]+)\""
                                                           withString:[NSString stringWithFormat:@"%@<p class=\"pbl\"", sHideQuote]];


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
    
    // Embedded video
    NSString *regExYT = @"<a rel=\"nofollow\" href=\"([^\"]+)\" target=\"_blank\" class=\"embedvideo\" hrefemb=\"([^\"]+)\" hreftxt=\"([^\"]+)\">([^<]+)</a>";
    //Example: <iframe width="560" height="315" src="https://www.youtube.com/embed/FMbSgh1hb6k?&autoplay=1"frameborder="0"></iframe>
    //NSString *sFrameEmbedded = @"<div class=\"embedvideo\"><iframe width=\"100%\" height=\"100%\" src=\"$2\" frameborder=\"0\"></iframe></div>";
    NSString *sFrameEmbedded = @"<div class=\"embedvideo\"><iframe src=\"$2\" frameborder=\"0\"></iframe><a href=\"$1\">$3</a></div>";
    myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regExYT
                                                          withString:sFrameEmbedded];
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *display = [defaults stringForKey:@"display_images"];

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
	
    if (self.quotedNB) {
        myRawContent = [myRawContent stringByAppendingString:[NSString stringWithFormat:@"<a class=\"quotedhfrlink\" href=\"%@\">%@</a>", self.quotedLINK, self.quotedNB]];
    }
    if (self.editedTime) {
        myRawContent = [myRawContent stringByAppendingString:[NSString stringWithFormat:@"<p class=\"editedhfrlink\">édité par %@</p>", self.editedTime]];
    }
    if (self.url) {
        NSString* sPage = @"";
        if (self.iPage > 0) {
            sPage = [NSString stringWithFormat:@" - page %d", self.iPage];
        }
        NSString* sVoirMessage = [NSString stringWithFormat:@"<a class=\"filteredpostlink\" href=\"%@\" >Voir dans le sujet non filtré%@</a>", self.url, sPage];
        myRawContent = [sVoirMessage stringByAppendingString:myRawContent];
    }

    // Improve color for keyword in cpp tag
    myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"<span style=\"color:blue\">" withString:@"<span style=\"color:var( --color-action)\">"];

    tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%MESSAGE_CONTENT%%" withString:myRawContent];

    //NSLog(@"%@", tempHTML);
    tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%%%ID%%%%" withString:[NSString stringWithFormat:@"%d", index]];

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"%%ID%%" withString:[NSString stringWithFormat:@"%d", index]];

	
	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];	
	
    // Add show/hide action on BL posts
    if (bIsPostBL) {
        NSString* sHidePostJS = [NSString stringWithFormat:@"event.stopPropagation(); document.getElementById(%d).style.height = '0px'; document.getElementById(10%d).style.display = 'block'; document.getElementById(20%d).style.display = 'block';", index, index, index];
        NSString* sHidePostDiv = [NSString stringWithFormat: @"<div class=\"hidepost\" onclick=\"%@\"><a class=\"buttonshow\"> &#9650; </a></div>", sHidePostJS];
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"<div class=\"right\"> + </div>" withString:sHidePostDiv];
        
        NSString* sShowPostJS = [NSString stringWithFormat:@"event.stopPropagation(); document.getElementById(%d).style.height = 'auto'; document.getElementById(10%d).style.display = 'none'; document.getElementById(20%d).style.display = 'none';", index, index, index];
        
        NSString* sPseudoToDisplay = name;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"blacklist_hide_pseudo"]) {
            sPseudoToDisplay = @"";
        }
        NSString* sShowPostDiv = [NSString stringWithFormat: @"<div class=\"message headerblacklist\" id=\"10%d\" style=\"display='block'\"><div class=\"blavatar\"></div><div class=\"blpseudo\">%@</div><div class=\"right\" onclick=\"%@\"><a class=\"buttonhide\"> &#9660; </a></div></div><div class=\"message separator\" id=\"20%d\"></div>", index, sPseudoToDisplay, sShowPostJS, index];
        tempHTML = [sShowPostDiv stringByAppendingString:tempHTML];
    }
    

    //NSLog(@"----------------> OUTPUT  <---------------------");
    //NSLog(@"%@", tempHTML);
    //NSLog(@"----------------> /OUTPUT <---------------------");

	return tempHTML;
}

@end
