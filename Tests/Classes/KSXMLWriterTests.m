//
//  KSHTMLWriterTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

@import XCTest;

#import "KSXMLWriter.h"
@import KSWriter;


@interface KSXMLWriterTests : XCTestCase
{
    KSWriter* output;
    KSXMLWriter* writer;
}
@end


#pragma mark - Unit Tests Implementation

@implementation KSXMLWriterTests

- (void)setUp
{
    output = [KSWriter stringWriterWithEncoding:NSUnicodeStringEncoding];
    writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
}

- (void)testNoAction
{
    NSString* generated = [output string];
    XCTAssertTrue([generated isEqualToString:@""], @"generated string is empty");
}

- (void)testWriteElementNoContent
{
    [writer writeElement:@"foo" attributes:nil content:nil];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo />");
}

- (void)testWriteElementEmptyContent
{
    [writer writeElement:@"foo" attributes:nil content:^{
    }];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo />");
}

- (void)testWriteElementNoAttributes
{
    [writer writeElement:@"foo" attributes:nil content:^{
         [writer writeCharacters:@"bar"];
     }];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo>bar</foo>");
}

- (void)testWriteElementEmptyAttributes
{
    NSDictionary* attributes = [NSDictionary dictionary];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo>bar</foo>");
}

- (void)testWriteElementOneAttribute
{
    NSDictionary* attributes = [NSDictionary dictionaryWithObject:@"wibble" forKey:@"wobble"];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo wobble=\"wibble\">bar</foo>");
}

- (void)testWriteElementMultipleAttributes
{
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"o1", @"k1", @"o2", @"k2", nil];
    [writer writeElement:@"foo" attributes:attributes content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo k2=\"o2\" k1=\"o1\">bar</foo>");
}

- (void)testPushAttribute
{
    [writer pushAttribute:@"a1" value:@"v1"];
    XCTAssertTrue([writer hasCurrentAttributes]);
    XCTAssertNotNil([writer currentAttributes]);
    NSUInteger attributeCount = [[writer currentAttributes] count];
    XCTAssertEqual(attributeCount, (NSUInteger) 1 , @"wrong number of attributes");
    
    [writer pushAttribute:@"a2" value:@"v2"];
    attributeCount = [[writer currentAttributes] count];
    XCTAssertEqual(attributeCount, (NSUInteger) 2, @"wrong number of attributes");
    
    [writer writeElement:@"foo" attributes:nil content:^{
        [writer writeCharacters:@"bar"];
    }];
        
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo a1=\"v1\" a2=\"v2\">bar</foo>");
    
    XCTAssertFalse([writer hasCurrentAttributes], @"has attributes");
    XCTAssertNotNil([writer currentAttributes], @"has attributes");
    attributeCount = [[writer currentAttributes] count];
    XCTAssertEqual(attributeCount, (NSUInteger) 0, @"wrong number of attributes");
}

- (void)testWriteEscapedEntities
{
    // TODO could expand this to include a list of all entities
    [writer writeElement:@"foo" attributes:nil content:^{
        [writer writeCharacters:@"< & >"];
    }];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo>&lt; &amp; &gt;</foo>");
    
    // test the raw escaping whilst we're at it
    NSString* escaped = [KSXMLWriter stringFromCharacters:@"< & >"];
    XCTAssertEqualObjects(escaped, @"&lt; &amp; &gt;");
}

- (void)testWriteEscapedNonAsciiCharacters
{
    output = [KSWriter stringWriterWithEncoding:NSASCIIStringEncoding];
    writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
    
    // TODO could expand this to loop through all characters, but some of them will expand
    // to unexpected things - e.g. see character 160 below...

    [writer writeElement:@"foo" attributes:nil content:^{
        
        // write some random non-ascii characters
        // (160 happens to be a non-breaking space, so it will be encoded as nbsp;)
        static char nonAsciiChars[] = { 160, 180, 200, 0 };
        NSString* nonAscii = [NSString stringWithCString:nonAsciiChars encoding:NSISOLatin1StringEncoding];
        [writer writeCharacters:nonAscii];
    }];

    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo>&nbsp;&#180;&#200;</foo>");
    
}

- (void)testWriteComment
{
    // TODO could expand this to include a list of all entities
    [writer writeElement:@"foo" attributes:nil content:^{
        [writer writeComment:@"this is a comment"];
        [writer writeCharacters:@"this is not a comment"];
        [writer writeComment:@"this is another comment"];
    }];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<foo><!--this is a comment-->this is not a comment<!--this is another comment--></foo>");
}

- (void)testStartDocument
{
    writer.doctype = @"some-type";
    [writer writeDoctypeDeclaration];
    [writer writeElement:@"foo" attributes:nil content:^{
        [writer writeCharacters:@"bar"];
    }];
    
    NSString* generated = [output string];
    XCTAssertEqualObjects(generated, @"<!DOCTYPE some-type>\n<foo>bar</foo>");
    
}

@end
