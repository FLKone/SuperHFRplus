//
//  RehostImage.m
//  HFRplus
//
//  Created by Shasta on 15/12/2013.
//
//

#import "RehostImage.h"
#import "UIImage+Resize.h"
#import "ASIFormDataRequest.h"
#import "HTMLParser.h"

#import "ThemeManager.h"
#import "ThemeColors.h"
#import "HFRAlertView.h"

#define CHEVERETO_UPLOAD_SUCCESS_OK 200

@implementation RehostImage

@synthesize version;

@synthesize link_full;
@synthesize link_miniature;
@synthesize link_preview;
@synthesize link_medium;
@synthesize nolink_full;
@synthesize nolink_miniature;
@synthesize nolink_preview;
@synthesize nolink_medium;
@synthesize timeStamp;
@synthesize deleted;

- (id)init {
	self = [super init];
	if (self) {
        self.link_full = [NSString string];
        self.link_miniature = [NSString string];
        self.link_preview = [NSString string];
        self.link_medium = [NSString string];

        self.nolink_full = [NSString string];
        self.nolink_miniature = [NSString string];
        self.nolink_preview = [NSString string];
        self.nolink_medium = [NSString string];

        self.timeStamp = [NSDate date];
        self.deleted = NO;
        self.version = 1;
	}
	return self;
}

// Implementation
- (void) encodeWithCoder:(NSCoder *)encoder {
    //NSLog(@"encodeWithCoder %@", self);
    
    [encoder encodeObject:link_full forKey:@"link_full"];
    [encoder encodeObject:link_miniature forKey:@"link_miniature"];
    [encoder encodeObject:link_preview forKey:@"link_preview"];
    [encoder encodeObject:link_medium forKey:@"link_medium"];

    [encoder encodeObject:nolink_full forKey:@"nolink_full"];
    [encoder encodeObject:nolink_miniature forKey:@"nolink_miniature"];
    [encoder encodeObject:nolink_preview forKey:@"nolink_preview"];
    [encoder encodeObject:nolink_medium forKey:@"nolink_medium"];

    [encoder encodeInt:version forKey:@"version"];
    [encoder encodeBool:deleted forKey:@"deleted"];
    
    [encoder encodeObject:timeStamp forKey:@"timeStamp"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {

        link_full = [decoder decodeObjectForKey:@"link_full"];
        link_miniature = [decoder decodeObjectForKey:@"link_miniature"];
        link_preview = [decoder decodeObjectForKey:@"link_preview"];
        link_medium = [decoder decodeObjectForKey:@"link_medium"];

        nolink_full = [decoder decodeObjectForKey:@"nolink_full"];
        nolink_miniature = [decoder decodeObjectForKey:@"nolink_miniature"];
        nolink_preview = [decoder decodeObjectForKey:@"nolink_preview"];
        nolink_medium = [decoder decodeObjectForKey:@"nolink_medium"];

        version = [decoder decodeIntForKey:@"version"];
        deleted = [decoder decodeBoolForKey:@"deleted"];

        timeStamp = [decoder decodeObjectForKey:@"timeStamp"];
    }
    
    return self;
}

-(void)create {
    self.link_full = @"link_full";
    self.link_miniature = @"link_miniature";
    self.link_preview = @"link_preview";
    self.link_medium = @"link_medium";

    self.nolink_full = @"nolink_full";
    self.nolink_miniature = @"nolink_miniature";
    self.nolink_preview = @"nolink_preview";
    self.nolink_medium = @"nolink_medium";
}

-(void)upload:(UIImage *)picture;
{
    [self performSelectorInBackground:@selector(loadData:) withObject:picture];
}
-(void)loadData:(UIImage *)picture {
	@autoreleasepool {
        picture = [picture scaleAndRotateImage:picture];
        
        NSData* jpegImageData = UIImageJPEGRepresentation(picture, 1);
	
        //TODO here: add setting in IASK to let user choose the image upload site
        // Then depending on the choice, out the selector on the corresponding loadDataxxx method
        [self performSelectorOnMainThread:@selector(loadDataChevereto:) withObject:jpegImageData waitUntilDone:NO];
    }
}

-(void)loadDataRehost:(NSData *)jpegImageData {
	ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:
                               [NSURL URLWithString:@"https://reho.st/upload"]];
    //[NSURL URLWithString:@"http://apps.flkone.com/hfrplus/api/upload.processor.php"]];
	
	NSString* filename = [NSString stringWithFormat:@"snapshot_%d.jpg", rand()];
	
	[request setData:jpegImageData withFileName:filename andContentType:@"image/jpeg" forKey:@"fichier"];
	//[request setData:jpegImageData withFileName:filename andContentType:@"image/jpeg" forKey:@"file"];
	[request setPostValue:@"Envoyer" forKey:@"submit"];
	[request setShouldRedirect:NO];
	[request setShowAccurateProgress:YES];
    
	request.uploadProgressDelegate = self;
	
	[request setDelegate:self];
	
	[request setDidStartSelector:@selector(fetchContentStarted:)];
	[request setDidFinishSelector:@selector(fetchContentCompleteRehost:)];
	[request setDidFailSelector:@selector(fetchContentFailed:)];
	
	[request startAsynchronous];
}

-(void)loadDataChevereto:(NSData *)jpegImageData {
    //Example : https://img3.super-h.fr/api/1/upload/?key=af34631bb9b18fd4ef1ee46acae65976&source=https://img.super-h.fr/upload/images/U28P.jpg&format=json
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:@"https://img3.super-h.fr/api/1/upload/?key=af34631bb9b18fd4ef1ee46acae65976"]];//&format=txt"]];
    
    
    NSString* filename = [NSString stringWithFormat:@"snapshot_%d.jpg", rand()];
    
    [request setData:jpegImageData withFileName:filename andContentType:@"image/jpeg" forKey:@"source"];
    [request setPostValue:@"Envoyer" forKey:@"submit"];
    [request setShouldRedirect:NO];
    [request setShowAccurateProgress:YES];
    
    request.uploadProgressDelegate = self;
    
    [request setDelegate:self];
    
    [request setDidStartSelector:@selector(fetchContentStarted:)];
    [request setDidFinishSelector:@selector(fetchContentCompleteChevereto:)];
    [request setDidFailSelector:@selector(fetchContentFailed:)];
    
    [request startAsynchronous];
}


- (void)setProgress:(float)progress
{
    //NSLog(@"progress %f", progress);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progress] forKey:@"progress"]];
}

- (void)fetchContentStarted:(ASIHTTPRequest *)theRequest
{
	//NSLog(@"fetchContentStarted");
}

- (void)fetchContentCompleteRehost:(ASIHTTPRequest *)theRequest
{
    //NSLog(@"fetchContentCompleteRehost %@", [theRequest responseString]);
	//NSLog(@"fetchContentComplete");
	
    [HFRAlertView DisplayOKAlertViewWithTitle:@"Upload réussi ?" andMessage:[theRequest responseString]];

	
	NSError * error = nil;
	HTMLParser * myParser = [[HTMLParser alloc] initWithData:[theRequest responseData] error:&error];
	HTMLNode * bodyNode = [myParser body]; //Find the body tag
    
	NSArray *codeArray = [bodyNode findChildTags:@"code"];
	if (codeArray.count == 8) {
		// If appropriate, configure the new managed object.
        self.link_full = [[codeArray objectAtIndex:0] allContents];
        self.link_medium = [[codeArray objectAtIndex:1] allContents];
        self.link_preview = [[codeArray objectAtIndex:2] allContents];
        self.link_miniature = [[codeArray objectAtIndex:3] allContents];
        
        self.nolink_full = [[codeArray objectAtIndex:4] allContents];
        self.nolink_medium = [[codeArray objectAtIndex:5] allContents];
        self.nolink_preview = [[codeArray objectAtIndex:6] allContents];
        self.nolink_miniature = [[codeArray objectAtIndex:7] allContents];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0f], self, nil] forKeys:[NSArray arrayWithObjects:@"progress", @"rehostImage", nil]]];
        
	}
	else {
        // Popup error
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ooops !"  message:@"Erreur inconnue :/"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Tant pis..." style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {  }];
        [alert addAction:actionCancel];
        UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [activeVC presentViewController:alert animated:YES completion:nil];
        [[ThemeManager sharedManager] applyThemeToAlertController:alert];
	}

}

- (void)fetchContentCompleteChevereto:(ASIHTTPRequest *)theRequest
{
    //NSLog(@"fetchContentCompleteChevereto %@", [theRequest responseString]);
    /* Example
     {
     "status_code": 200,
     "success": {
         "message": "image uploaded",
         "code": 200
     },
     "image": {
             "name": "example",
             "extension": "png",
             "size": 53237,
             "width": 1151,
             "height": 898,
             "date": "2014-06-04 15:32:33",
             "date_gmt": "2014-06-04 19:32:33",
             "storage_id": null,
             "description": null,
             "nsfw": "0",
             "md5": "c684350d722c956c362ab70299735830",
             "storage": "datefolder",
             "original_filename": "example.png",
             "original_exifdata": null,
             "views": "0",
             "id_encoded": "L",
             "filename": "example.png",
             "ratio": 1.2817371937639,
             "size_formatted": "52 KB",
             "mime": "image/png",
             "bits": 8,
             "channels": null,
             "url": "http://127.0.0.1/images/2014/06/04/example.png",
             "url_viewer": "http://127.0.0.1/image/L",
             "thumb": {
                 "filename": "example.th.png",
                 "name": "example.th",
                 "width": 160,
                 "height": 160,
                 "ratio": 1,
                 "size": 17848,
                 "size_formatted": "17.4 KB",
                 "mime": "image/png",
                 "extension": "png",
                 "bits": 8,
                 "channels": null,
                 "url": "http://127.0.0.1/images/2014/06/04/example.th.png"
             },
             "medium": {
                 "filename": "example.md.png",
                 "name": "example.md",
                 "width": 500,
                 "height": 390,
                 "ratio": 1.2820512820513,
                 "size": 104448,
                 "size_formatted": "102 KB",
                 "mime": "image/png",
                 "extension": "png",
                 "bits": 8,
                 "channels": null,
                 "url": "http://127.0.0.1/images/2014/06/04/example.md.png"
             },
             "views_label": "views",
             "display_url": "http://127.0.0.1/images/2014/06/04/example.md.png",
             "how_long_ago": "moments ago"
         },
         "status_txt": "OK"
     }
     */
    BOOL bSuccess = NO;
    @try {
        NSError* error = nil;
        NSDictionary* dReply = [NSJSONSerialization JSONObjectWithData:[theRequest responseData] options: NSJSONReadingMutableContainers error: &error];
        
        if ([[dReply objectForKey:@"status_code"] intValue] == CHEVERETO_UPLOAD_SUCCESS_OK) {
            bSuccess = YES;
            self.link_full = [[dReply[@"image"] objectForKey:@"url"] stringValue];
            self.link_medium = [[dReply[@"image"][@"medium"] objectForKey:@"url"] stringValue];
            self.link_preview = nil;
            self.link_miniature = [[dReply[@"image"][@"thumb"] objectForKey:@"url"] stringValue];

            self.nolink_full = [[dReply[@"image"] objectForKey:@"url"] stringValue];
            self.nolink_medium = [[dReply[@"image"][@"medium"] objectForKey:@"url"] stringValue];
            self.nolink_preview = nil;
            self.nolink_miniature = [[dReply[@"image"][@"thumb"] objectForKey:@"url"] stringValue];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0f], self, nil] forKeys:[NSArray arrayWithObjects:@"progress", @"rehostImage", nil]]];
            
        }
        else {
            //Example:  {"status_code":400,"error":{"message":"File too big - max 500 KB","code":313,"context":"CHV\\UploadException"},"status_txt":"Bad Request"}
            NSString* sErrorMessage = [NSString stringWithFormat:@"%d - %@", [[dReply objectForKey:@"status_code"] intValue], [[dReply[@"error"][@"message"] objectForKey:@"url"] stringValue]];
            [HFRAlertView DisplayOKAlertViewWithTitle:@"Ooops !" andMessage:[NSString stringWithFormat:@"Erreur : %@", sErrorMessage]];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [HFRAlertView DisplayOKAlertViewWithTitle:@"Ooops !" andMessage:[NSString stringWithFormat:@"Erreur : %@", e]];
    }
    @finally {}

}


- (void)fetchContentFailed:(ASIHTTPRequest *)theRequest
{
    //NSLog(@"fetchContentFailed %@", [theRequest responseString]);

    // Popup error
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Ooops !" message:@"Erreur inconnue :/"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Tant pis..." style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) { [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadProgress" object:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0] forKey:@"progress"]];
                                                         }];
    [alert addAction:actionCancel];
    UIViewController* activeVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [activeVC presentViewController:alert animated:YES completion:nil];
    [[ThemeManager sharedManager] applyThemeToAlertController:alert];
}

-(void)dealloc {
    NSLog(@"deallocdealloc");
}


@end
