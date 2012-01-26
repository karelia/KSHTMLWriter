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

#pragma mark - KSXMLWriter Interface Shenanigans

// We rudely explose a few bits of the private KSXMLWriter interface so that we can frig with them during
// the unit tests
//
// Purists might argue that this is a no-no. They might be right.

@interface KSXMLWriter(UnitTestInternalAccess)
@property (nonatomic, assign, readwrite) NSStringEncoding encoding; 
@end


#pragma mark - Unit Tests Interface

@interface KSXMLWriterTests : KSHTMLWriterTestCase
{
    KSStringWriter* output;
    KSXMLWriter* writer;
}
@end

#pragma mark - Unit Tests Implementation

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

- (void)testWriteEscapedEntities
{
    // TODO could expand this to include a list of all entities
    [writer writeElement:@"foo" attributes:nil content:^{
        [writer writeCharacters:@"< & >"];
    }];
    
    NSString* generated = [output string];
    [self assertString:generated matchesString:@"<foo>&lt; &amp; &gt;</foo>"];
}

- (void)testWriteEscapedNonAsciiCharacters
{
    // TODO could expand this to loop through all characters, but some of them will expand
    // to unexpected things - e.g. see character 160 below...

    writer.encoding = NSASCIIStringEncoding;
    [writer writeElement:@"foo" attributes:nil content:^{
        
        // some random non-ascii characters
        // (160 happens to be a non-breaking space, so it will be encoded as nbsp;)
        static char nonAsciiChars[] = { 160, 180, 200, 0 };
        NSString* nonAscii = [NSString stringWithCString:nonAsciiChars encoding:NSISOLatin1StringEncoding];

        [writer writeCharacters:nonAscii];
    }];

    NSString* generated = [output string];
    [self assertString:generated matchesString:@"<foo>&nbsp;&#180;&#200;</foo>"];
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
    [self assertString:generated matchesString:@"<foo><!--this is a comment-->this is not a comment<!--this is another comment--></foo>"];
}

#if TODO // TODO - list of initial things to test

5. Combinations of the above, when nested inside elements 
6. -writeString: for a XML Writer using ASCII encoding, testing characters outside of ASCII's support to make sure they're escaped properly
7. -startDocumentWithDocType:encoding:

#endif


@end
