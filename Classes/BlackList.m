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
#import "MultisManager.h"

@implementation BlackList
@synthesize dicBlackList, listWhiteList;

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
        self.dicBlackList = [[NSMutableDictionary alloc] init];
        self.listWhiteList = [[NSMutableArray alloc] init];
        // load local storage data
        [self load];
    }
    return self;
}

- (NSInteger)addToBlackList:(NSString *)pseudo andSave:(BOOL)bSave {
    if (![self isBL:pseudo]) {
        NSInteger t1 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);
        if (bSave && [[NSUserDefaults standardUserDefaults] boolForKey:@"mpstorage_active"] && ![[MPStorage shared] addBlackListSynchronous:pseudo]) {
            return 0; // Error
        }
        NSInteger t2 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);

        NSMutableArray* listBlackList = [self getBlackListForActiveCompte];
        [listBlackList addObject:[NSDictionary dictionaryWithObjectsAndKeys:pseudo, @"word", @"", @"alias", [NSNumber numberWithInt:kTerminator], @"mode", nil]];
        if (bSave) [self save];
        NSInteger t3 = (NSInteger)round([NSDate timeIntervalSinceReferenceDate] * 1000);
        NSLog(@"Time global update black list : %d ms", (int)(t3-t1));
        return (t2-t1);
    }
    return 0;
}

- (void)addToWhiteList:(NSString *)pseudo {
    if (![self isWL:pseudo]) {
        [self.listWhiteList addObject:[NSDictionary dictionaryWithObjectsAndKeys:pseudo, @"word", @"", @"alias", [NSNumber numberWithInt:kTerminator], @"mode", nil]];
        [self save];
    }
}

- (BOOL)removeFromBlackList:(NSString*)pseudo andSave:(BOOL)bSave {
    if (bSave && [[NSUserDefaults standardUserDefaults] boolForKey:@"mpstorage_active"] && ![[MPStorage shared] removeBlackListSynchronous:pseudo]) {
        return NO;
    }
    NSMutableArray* listBlackList = [self getBlackListForActiveCompte];
    int idx = [self findIndexFor:pseudo in:listBlackList];
    if (idx >= 0) {
        BOOL b = [self removeAt:idx in:listBlackList];
        if (bSave) {
            [self save];
            return YES;
        }
        return b;
    }
    return NO;
}

- (bool)removeFromWhiteList:(NSString*)pseudo {
    int idx = [self findIndexFor:pseudo in:listWhiteList];
    if (idx >= 0) {
        if ([self removeAt:idx in:listWhiteList]) {
            [self save];
            return true;
        }
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

- (NSMutableArray*) getBlackListForActiveCompte {
    NSString* sCurrentPseudo = [[MultisManager sharedManager] getCurrentPseudo];
    if (sCurrentPseudo == nil) return [NSMutableArray array];
    if (![self.dicBlackList objectForKey:sCurrentPseudo]) {
        [self.dicBlackList setObject:[NSMutableArray array] forKey:sCurrentPseudo];
    }
    return [self.dicBlackList objectForKey:sCurrentPseudo];
}

- (void) setBlackListForActiveCompte:(NSMutableArray*)listBlackListUpdated {
    NSString* sCurrentPseudo = [[[MultisManager sharedManager] getMainCompte] objectForKey:PSEUDO_DISPLAY_KEY];
    [self.dicBlackList setObject:listBlackListUpdated forKey:sCurrentPseudo];
}

- (NSArray *)getAllWhiteList {
    return self.listWhiteList;
}

- (bool)isBL:(NSString*)pseudo {
    NSMutableArray* listBlackList = [self getBlackListForActiveCompte];
    if ([self findIndexFor:pseudo in:listBlackList] >= 0) {
        return true;
    }
    
    return false;
}

- (bool)isWL:(NSString*)pseudo {
    if ([self isBL:pseudo]) {
        return false;
    }
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
    NSString *blackList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:BLACKLISTDICO_FILE]];
    NSString *whiteList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:WHITELIST_FILE]];

    [self.dicBlackList writeToFile:blackList atomically:YES];
    [self.listWhiteList writeToFile:whiteList atomically:YES];
}

- (void)load {
    if (![[MultisManager sharedManager] getCurrentPseudo]) return;
    
    // In worse case, take what is present in cache
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *blackListDico = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:BLACKLISTDICO_FILE]];
    NSString *blackList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:BLACKLIST_FILE]];
    NSString *whiteList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:WHITELIST_FILE]];


    if ([fileManager fileExistsAtPath:blackListDico]) {
        self.dicBlackList = [NSMutableDictionary dictionaryWithContentsOfFile:blackListDico];
    }
    else if ([fileManager fileExistsAtPath:blackList]) {
        [self setBlackListForActiveCompte:[NSMutableArray arrayWithContentsOfFile:blackList]];
        [self.dicBlackList writeToFile:blackList atomically:YES];
        NSError* error;
        [fileManager removeItemAtPath:blackList error:&error]; // Remove file, as it should no more be used
    }
    else {
        [self setBlackListForActiveCompte:[NSMutableArray array]];
    }

    if ([fileManager fileExistsAtPath:whiteList]) {
        self.listWhiteList = [NSMutableArray arrayWithContentsOfFile:whiteList];
    }
    else {
        [self.listWhiteList removeAllObjects];
    }
}


// singleton methods
+ (id)allocWithZone:(NSZone *)zone {
    return [self shared];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
