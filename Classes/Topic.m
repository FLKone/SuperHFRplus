//
//  Topic.m
//  HFRplus
//
//  Created by FLK on 19/08/10.
//

#import "Topic.h"
#import "RangeOfCharacters.h"
#import "RegexKitLite.h"


@implementation Topic

@synthesize _aTitle;
@synthesize aURL;

@synthesize aRepCount;
@synthesize isViewed;

@synthesize aURLOfFlag;
@synthesize aTypeOfFlag;

@synthesize aURLOfLastPost;
@synthesize aURLOfLastPage;

@synthesize aDateOfLastPost;
@synthesize dDateOfLastPost;
@synthesize aAuthorOfLastPost;

@synthesize aAuthorOrInter;

@synthesize maxTopicPage, curTopicPage, aURLOfFirstPage;

@synthesize postID, catID, isPoll, isSticky, isSuperFavorite, isClosed;


- (id)init {
	self = [super init];
	if (self) {
        _aTitle = [NSString stringWithFormat:@""];
        self.aURL = [NSString string];

        self.aURLOfFirstPage = [NSString string];
        
        self.aURLOfFlag = [NSString string];
        self.aTypeOfFlag = [NSString string];
        
        self.aURLOfLastPost = [NSString string];
        self.aURLOfLastPage = [NSString string];
        
        self.aDateOfLastPost = [NSString string];
        self.dDateOfLastPost = [NSDate alloc];
        self.aAuthorOfLastPost = [NSString string];
        
        self.aAuthorOrInter = [NSString string];
        self.isPoll = NO;
        self.isSticky = NO;
        self.isSuperFavorite = NO;
        self.isClosed = NO;
	}
	return self;
}

- (NSString*) getURLforPage:(int)iPage {
    NSString *regexString  = @".*page=([^&]+).*";
    NSRange   matchedRange;// = NSMakeRange(NSNotFound, 0UL);
    NSRange   searchRange = NSMakeRange(0, self.aURL.length);
    NSError  *error2        = NULL;
    //int numPage;
    
    matchedRange = [self.aURL rangeOfRegex:regexString options:RKLNoOptions inRange:searchRange capture:1L error:&error2];
    NSString * ret = [self.aURL stringByReplacingCharactersInRange:matchedRange withString:[NSString stringWithFormat:@"%d", iPage]];
    ret = [ret stringByRemovingAnchor];
    return ret;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%d %@", self.postID, self.aTitle];
}

- (void)setATitle:(NSString *)n {
    _aTitle = [n filterTU];


}
//Getter method
- (NSString*) aTitle {
    //NSLog(@"Returning name: %@", _aTitle);
    return _aTitle;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSLog(@"encodeWithCoder", self);
    
    [encoder encodeObject:_aTitle forKey:@"aTitle"];
    [encoder encodeObject:aURL forKey:@"aURL"];
    [encoder encodeObject:[NSNumber numberWithInt:aRepCount] forKey:@"aRepCount"];
    [encoder encodeObject:aURLOfFirstPage forKey:@"aURLOfFirstPage"];
    [encoder encodeObject:aURLOfFlag forKey:@"aURLOfFlag"];
    [encoder encodeObject:aTypeOfFlag forKey:@"aTypeOfFlag"];
    [encoder encodeObject:aURLOfLastPost forKey:@"aURLOfLastPost"];
    [encoder encodeObject:aURLOfLastPage forKey:@"aURLOfLastPage"];
    [encoder encodeObject:aDateOfLastPost forKey:@"aDateOfLastPost"];
    [encoder encodeObject:dDateOfLastPost forKey:@"dDateOfLastPost"];
    [encoder encodeObject:aAuthorOfLastPost forKey:@"aAuthorOfLastPost"];
    [encoder encodeObject:aAuthorOrInter forKey:@"aAuthorOrInter"];
    [encoder encodeObject:[NSNumber numberWithInt:maxTopicPage] forKey:@"maxTopicPage"];
    [encoder encodeObject:[NSNumber numberWithInt:curTopicPage] forKey:@"curTopicPage"];
    [encoder encodeObject:[NSNumber numberWithInt:postID] forKey:@"postID"];
    [encoder encodeObject:[NSNumber numberWithInt:catID] forKey:@"catID"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {
        _aTitle = [decoder decodeObjectForKey:@"aTitle"];
        aURL = [decoder decodeObjectForKey:@"aURL"];
        aRepCount = [[decoder decodeObjectForKey:@"aRepCount"] intValue];
        aURLOfFirstPage = [decoder decodeObjectForKey:@"aURLOfFirstPage"];
        aURLOfFlag = [decoder decodeObjectForKey:@"aURLOfFlag"];
        aTypeOfFlag = [decoder decodeObjectForKey:@"aTypeOfFlag"];
        aURLOfLastPost = [decoder decodeObjectForKey:@"aURLOfLastPost"];
        aURLOfLastPage = [decoder decodeObjectForKey:@"aURLOfLastPage"];
        aDateOfLastPost = [decoder decodeObjectForKey:@"aDateOfLastPost"];
        dDateOfLastPost = [decoder decodeObjectForKey:@"dDateOfLastPost"];
        aAuthorOfLastPost = [decoder decodeObjectForKey:@"aAuthorOfLastPost"];
        aAuthorOrInter = [decoder decodeObjectForKey:@"aAuthorOrInter"];
        maxTopicPage = [[decoder decodeObjectForKey:@"maxTopicPage"] intValue];
        curTopicPage = [[decoder decodeObjectForKey:@"curTopicPage"] intValue];
        postID = [[decoder decodeObjectForKey:@"postID"] intValue];
        catID = [[decoder decodeObjectForKey:@"catID"] intValue];
        
        //NSLog(@"initWithCoder %@", self);
    }
    return self;
}


@end

