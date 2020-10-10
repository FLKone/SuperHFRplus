//
//  SmileyCache.m
//  SuperHFRplus
//
//
//  Created by ezzz on 2020.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest+Tools.h"
#import "SmileyCache.h"
#import "OfflineTableViewController.h"
#import "HTMLparser.h"
#import "Constants.h"
#import "UIImage+GIF.h"

#define IMAGE_CACHE_MAX_ELEMENTS 1000
#define IMAGE_CACHE_SMILEYS_DEFAULTS_MAX_ELEMENTS 50

@implementation SmileyRequest
@end

@implementation SmileyCache

@synthesize arrCurrentSmileyArray, cacheSmileys, cacheSmileysDefaults, bStopLoadingSmileysToCache, dicCommonSmileys, dicSearchSmileys, bSearchSmileysActivated;

static SmileyCache *_shared = nil;    // static instance variable

+ (SmileyCache *)shared {
    if (_shared == nil) {
        _shared = [[super allocWithZone:NULL] init];
    }
    return _shared;
}

- (id)init {
    if ( (self = [super init]) ) {
        // your custom initialization
        self.arrCurrentSmileyArray = nil;
        self.cacheSmileys = [[NSCache alloc] init];
        self.cacheSmileys.countLimit = IMAGE_CACHE_MAX_ELEMENTS;
        self.cacheSmileysDefaults = [[NSCache alloc] init];
        self.cacheSmileysDefaults.countLimit = IMAGE_CACHE_SMILEYS_DEFAULTS_MAX_ELEMENTS;
        self.bStopLoadingSmileysToCache = NO;
        self.bSearchSmileysActivated = NO;
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"commonsmile" ofType:@"plist"];
        NSMutableArray* arr = [NSMutableArray arrayWithContentsOfFile:plistPath];
        self.dicCommonSmileys = [[NSMutableArray alloc] init];
        for (int index = 0; index < arr.count; index++) {
            NSNumber* n =  arr[index][@"editor"];
            int i = [n intValue];
            if (i == 1) {
                [self.dicCommonSmileys addObject:arr[index]];
            }
            else {
                NSLog(@"index %ld not imported", (long)index);
            }
        }
    }
    return self;
}

- (void)handleSmileyArray:(NSMutableArray*)arrSmileys forCollection:(UICollectionView*)cv spinner:(UIActivityIndicatorView*)spinner
{
    self.bStopLoadingSmileysToCache = NO;
    self.bSearchSmileysActivated = YES;
    self.arrCurrentSmileyArray = [arrSmileys mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cv reloadData];
    });

    BOOL bHasbeenReloaded = NO;
    for (int i = 0; i < self.arrCurrentSmileyArray.count; i++) {
        NSString *filename = [[[self.arrCurrentSmileyArray objectAtIndex:i] objectForKey:@"source"] stringByReplacingOccurrencesOfString:@"http://forum-images.hardware.fr/" withString:@""];
        filename = [filename stringByReplacingOccurrencesOfString:@"https://forum-images.hardware.fr/" withString:@""];
        
        NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[[self.arrCurrentSmileyArray objectAtIndex:i] objectForKey:@"source"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]]];
        //UIImage *image = [UIImage imageWithData:imgData];sd_animatedGIFWithData
        if (imgData) {
            UIImage *image = [UIImage sd_animatedGIFWithData:imgData];
            [self.cacheSmileys setObject:image forKey:filename];
            NSLog(@"Image loaded in cache (%d) : %@", i, filename);
        }
        else {
            NSLog(@"Image ERROOOR loading (%d) : %@", i, filename);
        }

        // Says VC that cell can be reloaded
        dispatch_async(dispatch_get_main_queue(), ^{
            //[cv reloadData];
            NSIndexPath* ip = [NSIndexPath indexPathForRow:i inSection:0];
            NSArray *myArray = [[NSArray alloc] initWithObjects:ip, nil];
            [cv reloadItemsAtIndexPaths:myArray];
        });

        if (self.bStopLoadingSmileysToCache) {
            NSLog(@"#####################################################################################################################");
            NSLog(@"#####################################################################################################################");
            NSLog(@"############################################ STOPPED LOADING SMILEYS ################################################");
            NSLog(@"#####################################################################################################################");
            NSLog(@"#####################################################################################################################");
            break;
        }
     }
    self.bStopLoadingSmileysToCache = YES;
    NSLog(@"Finished loading all smileys");
    if (!bHasbeenReloaded) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [cv reloadData];
        });
    }
}

- (UIImage*) getImageForIndex:(int)index forCollection:(UICollectionView*)cv
{
    NSString *filename = [[[self.arrCurrentSmileyArray objectAtIndex:index] objectForKey:@"source"] stringByReplacingOccurrencesOfString:@"http://forum-images.hardware.fr/" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@"https://forum-images.hardware.fr/" withString:@""];
    
    UIImage* image = [self.cacheSmileys objectForKey:filename];

    if (image == nil && self.bStopLoadingSmileysToCache) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"Reloading image at index (%d) : %@", index, filename);
        NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[[self.arrCurrentSmileyArray objectAtIndex:index] objectForKey:@"source"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]]];
        //UIImage *image = [UIImage imageWithData:imgData];sd_animatedGIFWithData
        if (imgData) {
            UIImage* image = [UIImage sd_animatedGIFWithData:imgData];
            [self.cacheSmileys setObject:image forKey:filename];
            NSLog(@"Image loaded in cache (%d) : %@", index, filename);
        }

            // Says VC that cell can be reloaded
            dispatch_async(dispatch_get_main_queue(), ^{
                //[cv reloadData];
                NSIndexPath* ip = [NSIndexPath indexPathForRow:index inSection:0];
                NSArray *myArray = [[NSArray alloc] initWithObjects:ip, nil];
                [cv reloadItemsAtIndexPaths:myArray];
            });
        });
    }

    return image;
}

- (UIImage*) getImageDefaultSmileyForIndex:(int)index
{
    NSString *filename = [self.dicCommonSmileys[index][@"resource"] stringByReplacingOccurrencesOfString:@"http://forum-images.hardware.fr/" withString:@""];
    UIImage* image = [self.cacheSmileysDefaults objectForKey:filename];
    if (image == nil) {
        NSString *filenameShort = [filename stringByDeletingPathExtension];
        NSString* filepath = [[NSBundle mainBundle] pathForResource:filenameShort ofType:@"gif"];
        NSData* imgData = [NSData dataWithContentsOfFile:filepath];
        image = [UIImage sd_animatedGIFWithData:imgData];
        //NSLog(@"%@ size : (%f) %f x %f", filename, image.scale, image.size.width, image.size.height);
        [self.cacheSmileysDefaults setObject:image forKey:filename];
    }
    return image;
}

- (NSString*) getSmileyCodeForIndex:(int)index
{
    NSString *code = [[self.arrCurrentSmileyArray objectAtIndex:index] objectForKey:@"code"];
    return code;
}


- (NSMutableArray*) getSmileyListForText:(NSString*)sTextSmileys
{
    NSMutableArray* arr = [self.cacheSmileyRequests objectForKey:sTextSmileys];
    NSLog(@"getSmileyListForText %@", arr);
    return arr;
}


@end
