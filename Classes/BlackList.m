//
//  BlackList.m
//  HFRplus
//
//  Created by FLK on 28/08/2015.
//
//

#import "BlackList.h"
#import "HFRplusAppDelegate.h"
#import "MPStorage.h"

@implementation BlackList
@synthesize listBlackList, listWhiteList;

static BlackList *_shared = nil;    // static instance variable

+ (BlackList *)shared {
    if (_shared == nil) {
        _shared = [[super allocWithZone:NULL] init];
    }
    return _shared;
}

- (id)init {
    if ( (self = [super init]) ) {
        // your custom initialization
        self.listBlackList = [[NSMutableArray alloc] init];
        self.listWhiteList = [[NSMutableArray alloc] init];
        // load local storage data
        [self load];
        // update with MPstorage data when available
        [[MPStorage shared] loadBlackListAsynchronous];
    }
    return self;
}

- (void)addToBlackList:(NSString *)pseudo andSave:(BOOL)bSave {
    [self removeFromBlackList:pseudo andSave:NO]; // Security to avoid pseudo duplication
    [self.listBlackList addObject:[NSDictionary dictionaryWithObjectsAndKeys:pseudo, @"word", @"", @"alias", [NSNumber numberWithInt:kTerminator], @"mode", nil]];
    if (bSave) {
        [self save];
        [[MPStorage shared] saveBlackListAsynchronous:self.listBlackList];
    }
}

- (void)addToWhiteList:(NSString *)pseudo {
    [self removeFromWhiteList:pseudo]; // Security to avoid pseudo duplication
    [self.listWhiteList addObject:[NSDictionary dictionaryWithObjectsAndKeys:pseudo, @"word", @"", @"alias", [NSNumber numberWithInt:kTerminator], @"mode", nil]];
    [self save];
}

- (bool)removeFromBlackList:(NSString*)pseudo andSave:(BOOL)bSave {
    int idx = [self findIndexFor:pseudo in:listBlackList];
    if (idx >= 0) {
        BOOL b = [self removeAt:idx in:listBlackList];
        if (bSave) {
            [self save];
            [[MPStorage shared] saveBlackListAsynchronous:self.listBlackList];
        }
        return b;
    }
    
    return false;
}

- (bool)removeFromWhiteList:(NSString*)pseudo andSave:(BOOL)bSave {
    int idx = [self findIndexFor:pseudo in:listWhiteList];
    if (idx >= 0) {
        return [self removeAt:idx in:listWhiteList];
    }
    
    return false;
}

- (bool)removeAt:(int)index in:(NSMutableArray *)list {
    if ([list count] > index) {
        [list removeObjectAtIndex:index];
        return true;
    }
    return false;

}

- (NSArray *)getAllBlackList {
    return self.listBlackList;
}

- (NSArray *)getAllWhiteList {
    return self.listWhiteList;
}

- (bool)isBL:(NSString*)pseudo {
    if ([self findIndexFor:pseudo in:listBlackList] >= 0) {
        return true;
    }
    
    return false;
}

- (bool)isWL:(NSString*)pseudo {
    if ([self findIndexFor:pseudo in:listWhiteList] >= 0) {
        return true;
    }
    
    return false;
}

- (int)findIndexFor:(NSString *)pseudo in:(NSArray *)list {
    int i = 0;

    NSString* pseudolower = [[pseudo stringByReplacingOccurrencesOfString:@"\u200B" withString:@""] lowercaseString];
    for (NSDictionary *dc in list) {
        NSString* pseudoBLlower = [[[dc valueForKey:@"word"] stringByReplacingOccurrencesOfString:@"\u200B" withString:@""] lowercaseString];
        if ([pseudolower isEqualToString:pseudoBLlower]) {
            return i;
        }
        i++;
    }

    return -1;
}

- (NSString *) stringToHex:(NSString *)str
{
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        // [hexString [NSString stringWithFormat:@"%02x", chars[i]]]; /*previous input*/
        [hexString appendFormat:@"%02x", chars[i]]; /*EDITED PER COMMENT BELOW*/
    }
    free(chars);
    
    return hexString;
}

- (void)save {
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *blackList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:BLACKLIST_FILE]];
    NSString *whiteList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:WHITELIST_FILE]];

    [self.listBlackList writeToFile:blackList atomically:YES];
    [self.listWhiteList writeToFile:whiteList atomically:YES];
    
    // MPStorage : start asynchronous request for MP blacklist save
    
}

- (void)load {
    // In worse case, take what is present in cache
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *blackList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:BLACKLIST_FILE]];
    NSString *whiteList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:WHITELIST_FILE]];


    if ([fileManager fileExistsAtPath:blackList]) {
        self.listBlackList = [NSMutableArray arrayWithContentsOfFile:blackList];
    }
    else {
        [self.listBlackList removeAllObjects];
    }

    if ([fileManager fileExistsAtPath:whiteList]) {
        self.listWhiteList = [NSMutableArray arrayWithContentsOfFile:whiteList];
    }
    else {
        [self.listWhiteList removeAllObjects];
    }
    
    // MPStorage : start asynchronous request for MP blacklist load
    
}


// singleton methods
+ (id)allocWithZone:(NSZone *)zone {
    return [self shared];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
