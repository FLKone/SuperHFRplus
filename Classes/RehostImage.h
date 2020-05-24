//
//  RehostImage.h
//  HFRplus
//
//  Created by Shasta on 15/12/2013.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, bbcodeImageSizeType) {
    bbcodeImageFull,
    bbcodeImageMedium,
    bbcodeImagePreview,
    bbcodeImageMini
};

typedef NS_ENUM(NSInteger, bbcodeLinkType) {
    bbcodeImageWithLink,
    bbcodeImageNoLink,
    bbcodeLinkOnly
};

@interface RehostImage : NSObject <NSCoding> {
}

@property (nonatomic, strong) NSString *full_width;
@property (nonatomic, strong) NSString *full_height;

@property (nonatomic, strong) NSString *link_full;
@property (nonatomic, strong) NSString *link_miniature;
@property (nonatomic, strong) NSString *link_preview;
@property (nonatomic, strong) NSString *link_medium;

@property (nonatomic, strong) NSString *nolink_full;
@property (nonatomic, strong) NSString *nolink_miniature;
@property (nonatomic, strong) NSString *nolink_preview;
@property (nonatomic, strong) NSString *nolink_medium;

@property (nonatomic, strong) NSDate *timeStamp;

@property int version;
@property BOOL deleted;

- (void)create;
- (void)upload:(UIImage *)picture;
- (void)copyToPasteBoard:(bbcodeImageSizeType)imageSizeType;

@end
