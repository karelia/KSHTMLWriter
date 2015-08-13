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