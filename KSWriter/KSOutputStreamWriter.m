//
//  KSOutputStreamWriter.m
//  Sandvox
//
//  Created by Mike on 10/03/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

#import "KSOutputStreamWriter.h"


@implementation KSOutputStreamWriter

- (id)initWithOutputStream:(NSOutputStream *)outputStream encoding:(NSStringEncoding)encoding;
{
    [self init];
    
    _outputStream = [outputStream retain];
    _encoding = encoding;
    
    return self;
}

- (id)initWithOutputStream:(NSOutputStream *)outputStream;  // uses UTF8 encoding
{
    return [self initWithOutputStream:outputStream encoding:NSUTF8StringEncoding];
}

- (void)dealloc;
{
    [self close];   // release stream
    [super dealloc];
}

@synthesize encoding = _encoding;

- (void)writeString:(NSString *)string;
{
    CFDataRef data = CFStringCreateExternalRepresentation(NULL,
                                                          (CFStringRef)string,
                                                          CFStringConvertNSStringEncodingToEncoding([self encoding]),
                                                          0);
    
    /*CFIndex chars = CFStringGetBytes((CFStringRef)string,
                                     CFRangeMake(0, CFStringGetLength((CFStringRef)string)),
                                     CFStringConvertNSStringEncodingToEncoding([self encoding]),
                                     <#UInt8 lossByte#>,
                                     <#Boolean isExternalRepresentation#>,
                                     <#UInt8 *buffer#>,
                                     <#CFIndex maxBufLen#>,
                                     <#CFIndex *usedBufLen#>);
    */
    
    
    CFIndex length = CFDataGetLength(data);
    NSInteger written = [_outputStream write:CFDataGetBytePtr(data) maxLength:length];
    
    while (written < length)
    {
        if (written > 0)
        {
            NSData *subdata = [(NSData *)data subdataWithRange:NSMakeRange(written, length - written)];
            length = CFDataGetLength((CFDataRef)subdata);
            
            written = [_outputStream write:[subdata bytes] maxLength:length];
        }
    }
    
    CFRelease(data);
}

- (void)close;
{
    [_outputStream release]; _outputStream = nil;
}

@end
