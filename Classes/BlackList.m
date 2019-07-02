//
//  BlackList.m
//  HFRplus
//
//  Created by FLK on 28/08/2015.
//
//

#import "BlackList.h"
#import "HFRplusAppDelegate.h"

@implementation BlackList
@synthesize list;

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
        self.list = [[NSMutableArray alloc] init];
        [self load];
    }
    return self;
}

- (NSString *)description {
    NSString *tmp = [NSString stringWithFormat:@"List: "];
    
    for (NSDictionary *dc in self.list) {
        tmp = [tmp stringByAppendingFormat:@"\n%@ - %@ - %d", [dc objectForKey:@"word"], [dc objectForKey:@"alias"], [[dc valueForKey:@"mode"] integerValue]];
    }
    
    return tmp;
}

- (void)addDictionnary:(NSDictionary *)dico {
    [self.list addObject:dico];
    [self save];

}

- (void)add:(NSString *)word {
    [self addDictionnary:[NSDictionary dictionaryWithObjectsAndKeys:word, @"word", @"", @"alias", [NSNumber numberWithInt:kTerminator], @"mode", nil]];
}

- (bool)removeWord:(NSString*)word {
    
    int idx = [self findIndexFor:word];
    if (idx >= 0) {
        return [self removeAt:idx];
    }
    
    return false;

}
- (bool)removeAt:(int)index {
    
    if ([self.list count] > index) {
        [self.list removeObjectAtIndex:index];
        [self save];
        return true;
    }
    return false;

}
- (NSArray *)getAll {
    return self.list;
}
- (bool)isBL:(NSString*)word {
    
    if ([self findIndexFor:word] >= 0) {
        return true;
    }
    
    return false;
}

-(int)findIndexFor:(NSString *)pseudo {
    int i = 0;
    //NSLog(@"BL1 pseudo<%@><%@>", pseudo, [self stringToHex:pseudo]);
    NSString* pseudolower = [[pseudo stringByReplacingOccurrencesOfString:@"\u200B" withString:@""] lowercaseString];

    for (NSDictionary *dc in self.list) {
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
    
    [self.list writeToFile:blackList atomically:YES];
}

- (void)load {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *blackList = [[NSString alloc] initWithString:[directory stringByAppendingPathComponent:BLACKLIST_FILE]];
    
    if ([fileManager fileExistsAtPath:blackList]) {
        self.list = [NSMutableArray arrayWithContentsOfFile:blackList];
    }
    else {
        [self.list removeAllObjects];
    }
}


// singleton methods
+ (id)allocWithZone:(NSZone *)zone {
    return [self shared];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}
/*
- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  // denotes an object that cannot be released
}

- (oneway void)release {
    // do nothing - we aren't releasing the singleton object.
}

- (id)autorelease {
    return self;
}
*/


@end
