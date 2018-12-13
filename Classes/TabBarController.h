//
//  TabBarController.h
//  HFRplus
//
//  Created by FLK on 17/09/10.
//

#import <UIKit/UIKit.h>
#import "BrowserViewController.h"

@interface TabBarController : UITabBarController <UITabBarControllerDelegate> {

}

@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIImageView *bgOverlayView;
@property (nonatomic, strong) UIImageView *bgOverlayViewBis;
-(void)popAllToRoot:(BOOL)includingSelectedIndex;
@end
