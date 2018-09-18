//
//  LuminosityHandler.h
//  SuperHFRplus
//
//  Created by Aynolor on 26.02.18.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol LuminosityHandlerDelegate <NSObject>
-(void)didUpdateLuminosity:(float)luminosity;
@end

@interface LuminosityHandler : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, weak) id <LuminosityHandlerDelegate> delegate;
- (void)capture;
- (void)stop;

@end
