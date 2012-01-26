//
//  KSHTMLWriterTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriterTestCase.h"
#import "KSXMLWriter.h"
#import "KSStringWriter.h"

@interface KSXMLWriterTests : KSHTMLWriterTestCase
{
    KSStringWriter* output;
    KSXMLWriter* writer;
}
@end


@implementation KSXMLWriterTests

- (void)setUp
{
    output = [[KSStringWriter alloc] init];
    writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
}

- (void)tearDown
{
    [output release];
    [writer release];
}

- (void)testNoAction
{
    NSString* generated = [output string];
    
    STAssertTrue([generated isEqualToString:@""], @"generated string is empty");
}

- (void)testWriteElementNoContent
{
    [writer writeElement:@"foo" attributes:nil content:nil];
    
    NSString* generated = [output string];

    [self assertString:generated matchesString:@"<foo />"];
}

- (void)testWriteElementEmptyContent
{
    [writer writeElement:@"foo" attributes:nil content:^{
    }];
    
    NSString* generated = [output string];
    
    [self assertString:generated matchesString:@"<foo />"];
}

- (void)testWriteElementNoAttributes
{
    [writer writeElement:@"foo" attributes:nil content:^{
         [writer writeCharacters:@"bar"];
     }];
    
    NSString* generated = [output string];
    
    [self assertString:generated matchesString:@"<foo>bar</foo>"];
}

- (void)testWriteElementEmptyAttributes
{
    NSDictionary* attributes = [NSDictionary dictionary];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    
    [self assertString:generated matchesString:@"<foo>bar</foo>"];
}

- (void)testWriteElementOneAttribute
{
    NSDictionary* attributes = [NSDictionary dictionaryWithObject:@"wibble" forKey:@"wobble"];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    [self assertString:generated matchesString:@"<foo wobble=\"wibble\">bar</foo>"];
}

- (void)testWriteElementMultipleAttributes
{
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"o1", @"k1", @"o2", @"k2", nil];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    [self assertString:generated matchesString:@"<foo k2=\"o2\" k1=\"o1\">bar</foo>"];
}

- (void)testPushAttribute
{
    [writer pushAttribute:@"a1" value:@"v1"];
    STAssertTrue([writer hasCurrentAttributes], @"has attributes");
    STAssertNotNil([writer currentAttributes], @"has attributes");
    NSUInteger attributeCount = [[writer currentAttributes] count];
    STAssertEquals(attributeCount, (NSUInteger) 1 , @"wrong number of attributes");
    
    [writer pushAttribute:@"a2" value:@"v2"];
    attributeCount = [[writer currentAttributes] count];
    STAssertEquals(attributeCount, (NSUInteger) 2, @"wrong number of attributes");
    
    [writer writeElement:@"foo" attributes:nil content:^{
        [writer writeCharacters:@"bar"];
    }];
        
    NSString* generated = [output string];
    [self assertString:generated matchesString:@"<foo a1=\"v1\" a2=\"v2\">bar</foo>"];
    
    STAssertFalse([writer hasCurrentAttributes], @"has attributes");
    STAssertNotNil([writer currentAttributes], @"has attributes");
    attributeCount = [[writer currentAttributes] count];
    STAssertEquals(attributeCount, (NSUInteger) 0, @"wrong number of attributes");
}

#if TODO // TODO - list of initial things to test

3. -writeCharacters: including the special characters of '<' etc.
4. -writeComment:
5. Combinations of the above, when nested inside elements 
6. -writeString: for a XML Writer using ASCII encoding, testing characters outside of ASCII's support to make sure they're escaped properly
7. -startDocumentWithDocType:encoding:

#endif


@end
