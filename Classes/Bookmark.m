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
}

@end
