//
//  AQCellView.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 02/02/2019.
//

#import <Foundation/Foundation.h>
#import "AQCellView.h"
#import "ThemeManager.h"
#import "ThemeColors.h"


@implementation AQCellView

@synthesize labelTitleTopic;
@synthesize labelTitleAQ;
@synthesize labelTime;
@synthesize labelCommentAQ;

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect adjustedFrame = self.accessoryView.frame;
    adjustedFrame.origin.x += 10.0f;
    self.accessoryView.frame = adjustedFrame;
    [self applyTheme];
}

-(void)applyTheme {
    Theme theme = [[ThemeManager sharedManager] theme];
    self.backgroundColor = [ThemeColors cellBackgroundColor:theme];
    self.contentView.superview.backgroundColor =[ThemeColors cellBackgroundColor:theme];
    
    [labelTitleTopic setTextColor:[ThemeColors textColor]];
    [labelTitleAQ setTextColor:[ThemeColors topicMsgTextColor]];
    [labelCommentAQ setTextColor:[ThemeColors topicMsgTextColor]];
    [labelTime setTextColor:[ThemeColors tintColor]];
    
    self.selectionStyle = [ThemeColors cellSelectionStyle:theme];
}


@end
