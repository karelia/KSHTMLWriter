//
//  KSHTMLWriterTests.m
//  KSHTMLWriter
//
//  Created by Mike on 18/06/2015.
//  Copyright (c) 2015 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "KSHTMLWriter.h"


@interface KSHTMLWriterTests : XCTestCase

@end


@implementation KSHTMLWriterTests {
    KSWriter* output;
    KSHTMLWriter* writer;
}

- (void)setUp {
    [super setUp];
    
    output = [KSWriter stringWriterWithEncoding:NSUTF8StringEncoding];
    writer = [[KSHTMLWriter alloc] initWithOutputWriter:output];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark Empty Elements

/**
 <HR> is a void element in HTML, so isn't allowed to contain any content or have an end tag. HTML
 parsers handle there being a start tag only, but to be XHTML-compatible, it needs to be a self-
 closing tag (have a slash at the end)
 */
- (void)testVoidElement {
    [writer writeElement:@"hr" content:NULL];
    XCTAssertEqualObjects(output.string, @"<hr>");
}

/**
 <SPAN> is a normal, not void element. If empty, still need to write a close tag, as HTML does not
 support self-closing tags for this.
 */
- (void)testEmptyNormalElement {
    [writer writeElement:@"span" content:NULL];
    XCTAssertEqualObjects(output.string, @"<span></span>");
}

#pragma mark Pretty Printing

- (void)testCommentAtEndOfElement {
    
    [writer writeElement:@"div" content:^{
        [writer writeElement:@"p" text:@"text"];
    }];
    
    [writer writeComment:@"comment"];
    
    XCTAssertEqualObjects(output.string, @"<div>\n\t<p>text</p>\n</div><!--comment-->",
                          @"Comment should be directly after end of element; not on a new line");
}

- (void)testPrettyPrintedParagraph {
    
    [writer writeElement:@"p" content:^{
        [writer writeCharacters:@"Test "];
        [writer writeElement:@"b" text:@"strong"];
        [writer writeCharacters:@". Test "];
        [writer writeElement:@"i" text:@"often"];
        [writer writeCharacters:@"."];
    }];
    
    XCTAssertEqualObjects(output.string, @"<p>Test <b>strong</b>. Test <i>often</i>.</p>");
}

- (void)testEmbeddedJavascriptPrettyPrinting {
    [writer writeJavascript:@"// your script goes here" useCDATA:NO];
    
    XCTAssertEqualObjects(output.string, @"<script>\n// your script goes here\n</script>",
                          @"The script contents go on their own line, level with the <script> tag. "
                          @"The </script> tag goes down onto its own line too");
}

@end
