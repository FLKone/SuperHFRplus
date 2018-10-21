//
//  IdentificationViewController.h
//  HFRplus
//
//  Created by FLK on 25/07/10.
//

#import <UIKit/UIKit.h>

@protocol IdentificationViewControllerDelegate;

@interface IdentificationViewController : UIViewController {
	id <IdentificationViewControllerDelegate> __weak delegate;

	IBOutlet UITextField *pseudoField;
	IBOutlet UITextField *passField;
    IBOutlet UILabel *titleLabel;
    IBOutlet UITextView *logView;
}
@property (nonatomic, weak) id <IdentificationViewControllerDelegate> delegate;

@property (nonatomic, strong) UITextField* pseudoField;
@property (nonatomic, strong) UITextField* passField;
@property (nonatomic, strong) UITextView *logView;
@property (nonatomic, strong) NSString *password;



-(IBAction) done:(id)sender;

-(IBAction) connexion;
-(void)finish;
-(void)finishOK;

- (IBAction)goToCreate;

@end


@protocol IdentificationViewControllerDelegate
- (void)identificationViewControllerDidFinish:(IdentificationViewController *)controller;
- (void)identificationViewControllerDidFinishOK:(IdentificationViewController *)controller;
@end
