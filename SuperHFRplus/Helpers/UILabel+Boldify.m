//
//  UILabel+Boldify.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 28/06/2020.
//

#import "UILabel+Boldify.h"

@implementation UILabel(Boldify)


- (void) boldRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.font.pointSize]} range:NSMakeRange(0, self.attributedText.length)];
    if (range.location != NSNotFound) {
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font.pointSize]} range:range];
    }
    self.attributedText = attributedText;
}

- (void) boldSubstring: (NSString*) substring {
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}

@end
