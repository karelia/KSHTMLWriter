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

@property (assign, nonatomic) NSUInteger written;

@end

@implementation MockStream

@synthesize written;

- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len
{
    self.written += len;
    
    return written;
}

@end


@interface KSOutputStreamWriterTests : KSHTMLWriterTestCase


@end

@implementation KSOutputStreamWriterTests

- (void)testInitiallyEmpty
{
    MockStream* stream = [[MockStream alloc] init];
    KSOutputStreamWriter* output = [[KSOutputStreamWriter alloc] initWithOutputStream:stream];

    STAssertEquals(stream.written, 0, @"nothing written initially");

    [output release];
    [stream release];
}

- (void)testWriting
{
    MockStream* stream = [[MockStream alloc] init];
    KSOutputStreamWriter* output = [[KSOutputStreamWriter alloc] initWithOutputStream:stream];

    [output writeString:@"test"];
    //    STAssertTrue([[output string] isEqualToString:@"test"], @"string is correct");

    [output writeString:@"test"];
    //    STAssertTrue([[output string] isEqualToString:@"testtest"], @"string is correct");

    [output release];
}

@end
