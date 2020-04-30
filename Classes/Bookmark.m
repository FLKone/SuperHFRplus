//
//  Bookmark.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 19/04/2020.
//

#import <Foundation/Foundation.h>

#include "Bookmark.h"

@implementation Bookmark

@synthesize sPost, sNumResponse, sCat, sLabel, sAuthorPost, dateBookmarkCreation;


- (NSString*) getUrl {
    return [NSString stringWithFormat:@"/forum2.php?config=hfr.inc&cat=%@&post=%@&numreponse=%@#t%@", sCat, sPost, sNumResponse, sNumResponse];
    //return [NSString stringWithFormat:@"/forum2.php?config=hfr.inc&cat=25&post=2511&page=541&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t742844"];
    //OK return [NSString stringWithFormat:@"/forum2.php?config=hfr.inc&cat=25&post=2511&page=541&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t742844"];
}

@end
