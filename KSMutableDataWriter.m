//
//  KSMutableDataWriter.m
//  Sandvox
//
//  Created by Mike on 12/03/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

#import "KSMutableDataWriter.h"


@implementation KSMutableDataWriter

- (id)initWithMutableData:(NSMutableData *)data encoding:(NSStringEncoding)encoding;
{
    [self init];
    
    _data = [data retain];
    _encoding = encoding;
    
    return self;
}

@synthesize encoding = _encoding;

- (void)writeString:(NSString *)string;
{
    CFRange range = CFRangeMake(0, CFStringGetLength((CFStringRef)string));
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding([self encoding]);
    
    CFIndex usedBufLen;
    CFIndex chars = CFStringGetBytes((CFStringRef)string,
                                     range,
                                     encoding,
                                     0,
                                     NO,
                                     NULL,
                                     0,
                                     &usedBufLen);
    NSAssert(chars == [string length], @"Unexpected number of characters converted");
    
    [_data increaseLengthBy:usedBufLen];
    UInt8 *buffer = [_data mutableBytes];
    
    chars = CFStringGetBytes((CFStringRef)string,
                             range,
                             encoding,
                             0,
                             NO,
                             buffer + [_data length] - usedBufLen,
                             usedBufLen,
                             NULL);
    NSAssert(chars == [string length], @"Unexpected number of characters converted");
}

- (void)close;
{
    [_data release];
}

@end
