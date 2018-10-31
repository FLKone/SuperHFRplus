//
//  UIScrollView+Theme.m
//  SuperHFRplus
//

#import <objc/runtime.h>
#import "UIScrollView+Theme.h"

@implementation UIScrollView (Theme)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIScrollView class];
        
        SEL originalSelector = @selector(drawRect:);
        SEL swizzledSelector = @selector(xxx_drawRect:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)xxx_drawRect:(CGRect)rect{
    [self xxx_drawRect:rect];
    self.indicatorStyle = [self getScrollViewIndicatorStyle];
}

-(UIScrollViewIndicatorStyle)getScrollViewIndicatorStyle {
    return [ThemeColors scrollViewIndicatorStyle:[[ThemeManager sharedManager] theme]];
}

@end

