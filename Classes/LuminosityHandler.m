//
//  LuminosityHandler.m
//  SuperHFRplus
//
//  Created by Aynolor on 26.02.18.
//

#import "LuminosityHandler.h"

@interface LuminosityHandler ()

@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;
@property (nonatomic, retain) AVCaptureSession *session;

@end

@implementation LuminosityHandler

@synthesize prevLayer = _prevLayer;
@synthesize session = _session;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)capture
{
    //Capture Session
    _session = [[AVCaptureSession alloc]init];
    _session.sessionPreset = AVCaptureSessionPreset352x288;
    
    //Add device
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    
    if(inputDevice){
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
        if(input){
            [_session addInput:input];
            
            
            //Output
            AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
            dispatch_queue_t captureQueue = dispatch_queue_create( "captureQueue", DISPATCH_QUEUE_SERIAL);
            [output setSampleBufferDelegate:self queue:captureQueue];
            [_session addOutput:output];
            output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };

            _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: _session];
            //Start capture session
            [_session startRunning];
        }
        
    }
    
}

- (void)stop {
     [_session stopRunning];
}


-(void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
                                                                 sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc]
                              initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata
                                   objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata
                              objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    [self.delegate didUpdateLuminosity:brightnessValue];
}

@end
