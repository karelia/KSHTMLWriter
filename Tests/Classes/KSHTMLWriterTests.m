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

#pragma mark Element Types

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

- (void)testContentInsideVoidElement {
    XCTAssertThrows([writer writeElement:@"hr" text:@"Misplaced text"]);
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

/**
 This is an example similar to something in Sandvox where you have some stuff followed by a
 complicated header (i.e. it's got an element nested in it). This is the pure version which works ok
 as-is, but I want to keep the test around.
 */
- (void)testPrettyPrinting {
    
    [writer writeElement:@"div" content:^{
        [writer writeElement:@"p" text:@"Text"];
    }];
    
    [writer writeElement:@"h2" content:^{
        [writer writeElement:@"span" text:@"Subheading"];
    }];
    
    XCTAssertEqualObjects(output.string,
                          @"<div>\n\t<p>Text</p>\n</div>\n"
                          @"<h2><span>Subheading</span></h2>");
}

/**
 …and now we try it again, but this time mimicking some of the content coming from a source other
 than nice writer commands. e.g. a template
 */
- (void)testPrettyPrintingAfterTemplate {
    
    // Some template stuff…
    [writer writeString:@"TEMPLATE START\n"];
    
    // …contains a direct bit of content
    [writer writeElement:@"div" content:^{
        [writer writeElement:@"h4" text:@"Title"];
    }];
    
    // Then goes back to the template
    [writer writeString:@"\n"];
    [writer writeString:@"TEMPLATE END\n"];
    
    // And now it's time to write the next thing
    [writer resetPrettyPrinting];
    [writer writeElement:@"h2" content:^{
        [writer writeElement:@"span" text:@"Subheading"];
    }];
    
    XCTAssertEqualObjects(output.string,
                          @"TEMPLATE START\n"
                          @"<div>\n"
                          @"\t<h4>Title</h4>\n"
                          @"</div>\n"
                          @"TEMPLATE END\n"
                          @"<h2><span>Subheading</span></h2>");
}

- (void)testEmptyElement {
    
    [writer writeElement:@"style" idName:@"paragraph-styles" className:nil content:^{
        
    }];
    
    XCTAssertEqualObjects(output.string, @"<style id=\"paragraph-styles\"></style>");
}

@end
