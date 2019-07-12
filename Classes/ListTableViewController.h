//
//  ListTableViewController.h
//  SuperHFRplus
//
//  Created by ezzz on 12/07/2019.
//

#ifndef ListTableViewController_h
#define ListTableViewController_h

#import <UIKit/UIKit.h>

@interface ListTableViewController : UITableViewController <UIAlertViewDelegate> {
    NSMutableArray *blackListDict;
}

@property (nonatomic, strong) NSMutableArray *listDict;

@end

#endif /* ListTableViewController_h */
