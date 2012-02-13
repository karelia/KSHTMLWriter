//
//  KSHTMLWriterTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "KSMutableDataWriter.h"
#import "KSHTMLWriterTestCase.h"

@interface KSMutableDataWriterTests : KSHTMLWriterTestCase


@end

@implementation KSMutableDataWriterTests

- (void)testInitiallyEmpty
{
    NSMutableData* data = [NSMutableData data];
    KSMutableDataWriter* output = [[KSMutableDataWriter alloc] initWithMutableData:data encoding:NSUTF8StringEncoding];
    STAssertTrue([data length] == 0, @"doesn't do anything with data until strings are written");
    [output release];
}

- (void)testWriting
{
    NSMutableData* data = [NSMutableData data];
    KSMutableDataWriter* output = [[KSMutableDataWriter alloc] initWithMutableData:data encoding:NSUTF8StringEncoding];

    [output writeString:@"test"];
    NSString* string1 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self assertString:string1 matchesString:@"test"];
    [string1 release];
    
    [output writeString:@"test"];
    NSString* string2 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self assertString:string2 matchesString:@"testtest"];
    [string2 release];
    
    [output release];
}

@end
