//
//  SmileyCache.h
//  SuperHFRplus
//
//  Created by Bruno ARENE on 28/05/2020.
//

#ifndef SmileyCache_h
#define SmileyCache_h

#import <Foundation/Foundation.h>

@interface SmileyCache : NSObject {
}

@property (nonatomic, strong) NSMutableArray* arrCurrentSmileyArray;
@property (nonatomic, strong) NSCache* cacheSmileys;

+ (SmileyCache *)shared;
- (void)handleSmileyArray:(NSMutableArray*)arrSmileys forCollection:(UICollectionView*) cv;
- (UIImage*) getImageForIndex:(int)index;

@end


#endif /* SmileyCache_h */
