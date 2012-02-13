//
//  KSHTMLWriterTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "KSOutputStreamWriter.h"
#import "KSHTMLWriterTestCase.h"

@interface MockStream : NSOutputStream

@property (strong, nonatomic) NSMutableString* written;

@end

@implementation MockStream

@synthesize written;

- (NSInteger)write:(const uint8_t *)bytes maxLength:(NSUInteger)len
{
    if (!self.written)
    {
        self.written = [[[NSMutableString alloc] initWithCapacity:len] autorelease];
    }
    
    NSString* string = [[NSString alloc] initWithBytes:bytes length:len encoding:NSUTF8StringEncoding];
    [self.written appendString:string];
    [string release];
    
    return len;
}

@end


@interface KSOutputStreamWriterTests : KSHTMLWriterTestCase


@end

@implementation KSOutputStreamWriterTests

- (void)testInitiallyEmpty
{
    MockStream* stream = [[MockStream alloc] init];
    KSOutputStreamWriter* output = [[KSOutputStreamWriter alloc] initWithOutputStream:stream];

    [self assertString:stream.written matchesString:@""];

    [output release];
    [stream release];
}

- (void)testWriting
{
    MockStream* stream = [[MockStream alloc] init];
    KSOutputStreamWriter* output = [[KSOutputStreamWriter alloc] initWithOutputStream:stream];

    [output writeString:@"test"];
    [self assertString:stream.written matchesString:@"test"];

    [output writeString:@"test"];
    [self assertString:stream.written matchesString:@"testtest"];

    [output release];
    [stream release];
}

@end
