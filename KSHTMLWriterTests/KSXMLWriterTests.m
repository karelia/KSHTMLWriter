//
//  KSHTMLWriterTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface KSXMLWriterTests : SenTestCase

@end

#import "KSXMLWriter.h"
#import "KSStringWriter.h"

@implementation KSXMLWriterTests

- (void)testSimpleTag
{
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
    [writer startElement:@"foo" attributes:nil];
    [writer writeCharacters:@"bar"];
    [writer endElement];
    
    NSString* generated = [output string];
    [output release];
    [writer release];
    
    STAssertTrue([generated isEqualToString:@"<foo>bar</foo>"], @"generated XML matches");
}

@end
