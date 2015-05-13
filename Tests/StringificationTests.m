//
//  KSHTMLWriter
//
//  Created by Mike on 13/05/2015.
//  Copyright (c) 2015 Karelia Software. All rights reserved.
//

#import "KSXMLWriterDOMAdaptor.h"
#import "KSHTMLWriter.h"
#import <XCTest/XCTest.h>


@interface StringificationTests : XCTestCase

@end


@implementation StringificationTests {
    NSArray *_suite;
    WebView *_webView;
}

- (void)setUp {
    [super setUp];
    
    NSURL *url = [[NSBundle bundleForClass:self.class] URLForResource:@"Stringification" withExtension:@"testdata"];
    XCTAssertNotNil(url);
    _suite = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:NULL];
    XCTAssertNotNil(_suite);

    _webView = [[WebView alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)loadHTMLString:(NSString *)string completionHandler:(void (^)())block {
    
    [_webView.mainFrame loadHTMLString:string baseURL:nil];
    [self expectationForNotification:WebViewProgressFinishedNotification object:_webView handler:NULL];
    [self waitForExpectationsWithTimeout:5 handler:NULL];
    block();
}

- (void)testItAll {
    for (NSDictionary *properties in _suite) {
        
        NSString *input = properties[@"Input"];
        NSString *literalOutput = properties[@"Literal"];
        NSString *prettyPrintedOutput = properties[@"Pretty-printed"];
        
        [self loadHTMLString:input completionHandler:^{
            
            // Suck the HTML back out of the DOM and make sure we've done a good job of that
            DOMHTMLElement *body = _webView.mainFrame.DOMDocument.body;
            KSWriter *buffer = [KSWriter stringWriterWithEncoding:NSUTF8StringEncoding];
            KSHTMLWriter *writer = [[KSHTMLWriter alloc] initWithOutputWriter:buffer];
            
            KSXMLWriterDOMAdaptor *stringifier = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer options:0];
            [stringifier writeInnerOfDOMNode:body];
            
            XCTAssertEqualObjects(buffer.string, literalOutput);
            
            
            buffer = [KSWriter stringWriterWithEncoding:NSUTF8StringEncoding];
            writer = [[KSHTMLWriter alloc] initWithOutputWriter:buffer];
            
            stringifier = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer options:KSXMLWriterDOMAdaptorPrettyPrint];
            [stringifier writeInnerOfDOMNode:body];
            
            XCTAssertEqualObjects(buffer.string, prettyPrintedOutput);
        }];
    }
    
}

@end
