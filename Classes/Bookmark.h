//
//  Bookmark.h
//  HFRplus
//
// Created by ezzz
//
//

#import <Foundation/Foundation.h>

//Real url example
// https://forum.hardware.fr/forum2.php?config=hfr.inc&cat=14&post=115&page=394&p=1&sondage=0&owntopic=1&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t5978240
// Remade URL
// https://forum.hardware.fr/forum2.php?config=hfr.inc&cat=14&post=115&page=394&p=1&sondage=0&owntopic=0&trash=0&trash_post=0&print=0&numreponse=0&quote_only=0&new=0&nojs=0#t5978240

// Values for MPStorage
// {"bookmarks":{"list":[{"post":"115","cat":"14","author":"MilesTEG1","href":"t5978240","label":"Test","createDate":1587291544336}],

@interface Bookmark : NSObject
{
}

// Url parameter for post
@property NSString* sPost;
@property NSString* sPage;
@property NSString* sCat;
@property NSString* sP;
@property NSString* sHref;

@property NSString* sLabel;
@property NSString* sAuthorPost;
@property NSDate* dateBookmarkCreation;

- (NSString*) getUrl;

@end
