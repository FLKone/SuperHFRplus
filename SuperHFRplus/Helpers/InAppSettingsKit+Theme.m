//
//  InAppSettingsKit+Theme.m
//  SuperHFRplus
//
//  Created by FLK on 10/11/2017.
//

#import <objc/runtime.h>
#import "InAppSettingsKit+Theme.h"

@implementation IASKSpecifierValuesViewController (Theme)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(tableView:cellForRowAtIndexPath:);
        SEL swizzledSelector = @selector(xxx_tableView:cellForRowAtIndexPath:);
        
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
-(void)setThemeColors:(Theme)theme {
    self.tableView.backgroundColor = [ThemeColors greyBackgroundColor:theme];
    self.tableView.separatorColor = [ThemeColors cellBorderColor:theme];
    [self.tableView reloadData];
}

-(UITableViewCell *)xxx_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self xxx_tableView:tableView cellForRowAtIndexPath:indexPath];
    [[ThemeManager sharedManager] applyThemeToCell:cell];
    return cell;
}

@end

