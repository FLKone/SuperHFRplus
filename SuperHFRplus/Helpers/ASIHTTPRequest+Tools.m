//
//  ASIHTTPRequest+Tools.m
//  SuperHFRplus
//
//  Created by Bruno ARENE on 27/04/2020.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest+Tools.h"
#include "iconv.h"

@implementation ASIHTTPRequest (Tools)

- (NSData *)safeResponseData {
    // this function is from
    // https://stackoverflow.com/questions/3485190/nsstring-initwithdata-returns-null
    //
    //
    NSData* data = [self responseData];
    
    iconv_t cd = iconv_open("UTF-8", "UTF-8"); // convert to UTF-8 from UTF-8
    int one = 1;
    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // discard invalid characters
    size_t inbytesleft, outbytesleft;
    inbytesleft = outbytesleft = data.length;
    char *inbuf  = (char *)data.bytes;
    char *outbuf = malloc(sizeof(char) * data.length);
    char *outptr = outbuf;
    if (iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft)
        == (size_t)-1) {
        NSLog(@"this should not happen, seriously");
        return nil;
    }
    NSData *result = [NSData dataWithBytes:outbuf length:data.length - outbytesleft];
    iconv_close(cd);
    free(outbuf);
    return result;
}

- (NSString *) safeResponseString
{
    NSData *data = [self safeResponseData];
    if (!data) {
        return nil;
    }
    
    return [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:[self responseEncoding]];
}


@end
