//
//  KSHTMLWriterTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriterTestCase.h"

@interface KSXMLWriterTests : KSHTMLWriterTestCase

@end

#import "KSXMLWriter.h"
#import "KSStringWriter.h"

@implementation KSXMLWriterTests

- (void)testNoAction
{
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
    
    NSString* generated = [output string];
    [output release];
    [writer release];
    
    STAssertTrue([generated isEqualToString:@""], @"generated string is empty");
}

- (void)testEmptyContent
{
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
    [writer writeElement:@"foo" attributes:nil content:nil];
    
    NSString* generated = [output string];
    [output release];
    [writer release];

    [self assertString:generated matchesString:@"<foo />"];
}

- (void)testWriteElementNoAttributes
{
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
    [writer writeElement:@"foo" attributes:nil content:^{
         [writer writeCharacters:@"bar"];
     }];
    
    NSString* generated = [output string];
    [output release];
    [writer release];
    
    [self assertString:generated matchesString:@"<foo>bar</foo>"];
}

- (void)testWriteElementEmptyAttributes
{
    NSDictionary* attributes = [NSDictionary dictionary];
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    [output release];
    [writer release];
    
    [self assertString:generated matchesString:@"<foo>bar</foo>"];
}

- (void)testWriteElementOneAttribute
{
    NSDictionary* attributes = [NSDictionary dictionaryWithObject:@"wibble" forKey:@"wobble"];
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    [output release];
    [writer release];
    
    [self assertString:generated matchesString:@"<foo wobble=\"wibble\">bar</foo>"];
}

- (void)testWriteElementMultipleAttributes
{
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"o1", @"k1", @"o2", @"k2", nil];
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    [output release];
    [writer release];
    
    [self assertString:generated matchesString:@"<foo k2=\"o2\" k1=\"o1\">bar</foo>"];
}

#if TODO // TODO - list of initial things to test

2. -pushAttribute: (multiple calls), followed by -writeElement:content:
3. -writeCharacters: including the special characters of '<' etc.
4. -writeComment:
5. Combinations of the above, when nested inside elements 
6. -writeString: for a XML Writer using ASCII encoding, testing characters outside of ASCII's support to make sure they're escaped properly
7. -startDocumentWithDocType:encoding:

#endif


@end
