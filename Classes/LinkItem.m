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

@implementation LinkItem

@synthesize postID, lastPageUrl, lastPostUrl, viewed, name, url, flagUrl, typeFlag, rep, dicoHTML, messageDate, imageUI, textViewMsg, messageNode, messageAuteur;
@synthesize urlQuote, urlAlert, urlEdit, urlProfil, addFlagUrl, quoteJS, MPUrl, isDel, isBL;

@synthesize quotedNB, quotedLINK, editedTime;

-(NSString *)toHTML:(int)index egoQuote:(BOOL)egoQuote
{
    //NSLog(@"toHTML index %d", index);

    // Get current own pseudo
    MultisManager *manager = [MultisManager sharedManager];
    NSDictionary *mainCompte = [manager getMainCompte];
    NSString *currentPseudo = [mainCompte objectForKey:PSEUDO_KEY];
    NSString *currentPseudoLowercase = [[mainCompte objectForKey:PSEUDO_KEY] lowercaseString];

    
	NSString *tempHTML = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"templatev2" ofType:@"htm"] encoding:NSUTF8StringEncoding error:NULL];

	tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	
	if([self isDel]){
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message del"];
	}

	if ([[self name] isEqualToString:@"Modération"]) {
		tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message mode "];
	} else if (egoQuote == YES && [[[self name] lowercaseString] isEqualToString:currentPseudoLowercase]) {
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message me"];
    }
    
    if([self isBL]){
        tempHTML = [tempHTML stringByReplacingOccurrencesOfString:@"class=\"message" withString:@"class=\"message hfrbl"];
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
     
    // Good site for debugging regex: https://regex101.com
    // Search for own quotes
    if (egoQuote == YES) {
        currentPseudo = [NSRegularExpression escapedPatternForString:currentPseudo];
        myRawContent = [myRawContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"class=\"Topic\">%@ a écrit :<\\/a>", currentPseudoLowercase] withString:[NSString stringWithFormat:@"class=\"Topic\">%@ a écrit :</a>", currentPseudoLowercase] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myRawContent length])];
        NSString* pseudoWrote = [NSString stringWithFormat:@"class=\"Topic\">%@ a écrit :</a>", currentPseudoLowercase];
        myRawContent = [myRawContent stringByReplacingOccurrencesOfString:pseudoWrote withString:pseudoWrote options:NSCaseInsensitiveSearch range:NSMakeRange(0, [myRawContent length])];
        NSString *regExQuoted = [NSString stringWithFormat:@"<table class=\"citation\">(<tr class=\"[^\"]+\">[^\"]+<b class=\"[^\"]+\"><a href=\"[^\"]+\" class=\"Topic\">)(%@)( a écrit :<\\/a>)", currentPseudoLowercase];
        myRawContent = [myRawContent stringByReplacingOccurrencesOfRegex:regExQuoted
                                     withString:[NSString stringWithFormat:@"<table class=\"citation_me_quoted\">$1%@$3", currentPseudo]];
    }
    myRawContent = [myRawContent stringByReplacingOccurrencesOfString:@"---------------" withString:@""];
    
    
    
	
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
	//NSLog(@"%@", tempHTML);

	return tempHTML;
}

@end
