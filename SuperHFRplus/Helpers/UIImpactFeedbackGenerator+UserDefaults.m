//
//  UIImpactFeedbackGenerator+UserDefaults.m
//  SuperHFRplus
//
//  Created by Aynolor on 09.11.17.
//

#import "UIImpactFeedbackGenerator+UserDefaults.h"

@implementation UIImpactFeedbackGenerator (UserDefaults)


- (void)impactOccurredWithDefaults {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"haptics"]){
       [self impactOccurred];
    }
}

@end
