//
//  ASIHTTPRequest+Tools.h
//  SuperHFRplus

#include "ASIHTTPRequest.h"

@interface ASIHTTPRequest (Tools);

- (NSData *)safeResponseData;
- (NSString *)safeResponseString;

@end

