//
//  KSHTMLWriterWebkitTestShellTests.m
//  KSHTMLWriterWebkitTestShellTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriter.h"
#import "KSStringWriter.h"
#import "KSXMLWriterDOMAdaptor.h"

#import "AppDelegate.h"
#import "StubWindowController.h"

#import <SenTestingKit/SenTestingKit.h>
#import <WebKit/WebKit.h>

@class StubWindowController;

@interface KSHTMLWriterWebkitTestShellTests : SenTestCase

@end

@implementation KSHTMLWriterWebkitTestShellTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAppLoaded
{
    AppDelegate* app = (AppDelegate*) [NSApplication sharedApplication].delegate;
    
    STAssertTrue(app != nil, @"Unit tests are not implemented yet in KSHTMLWriterWebkitTestShellTests");
}

- (void)testStubLoading
{

    StubWindowController* controller = [[StubWindowController alloc] init];
    [controller.window makeKeyAndOrderFront:self];
    [controller loadStubPage];

    while (controller.stubLoaded == NO)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }

    STAssertTrue([controller.window.title isEqualToString:@"Test Web Page"], @"window should have title set by the stub html");

    [controller release];
}

- (void)testWritingSnippets
{
    
    StubWindowController* controller = [[StubWindowController alloc] init];
    [controller.window makeKeyAndOrderFront:self];
    [controller loadStubPage];
    
    while (controller.stubLoaded == NO)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }
    
    NSArray* snippets = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"html" subdirectory:@"Snippets"];
    for (NSURL* snippetURL in snippets)
    {
        NSError* error = nil;
        NSString* snippetHTML = [NSString stringWithContentsOfURL:snippetURL encoding:NSUTF8StringEncoding error:&error];
        [controller injectContent:snippetHTML];

        KSStringWriter* output = [[KSStringWriter alloc] init];
        KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
        KSXMLWriterDOMAdaptor* adaptor = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer];
        
        DOMDocument* document = controller.webview.mainFrame.DOMDocument;
        DOMElement* element = [document getElementById:@"content"];
        [adaptor writeInnerOfDOMNode:element];

        NSString* written = [output string];
        NSLog(@"written:\n%@", written);
        STAssertTrue([written isEqualToString:snippetHTML], @"written html should match the original snippet");
        
        
        [adaptor release];
        [writer release];
        
        
        [output release];
        
    }

    STAssertTrue([controller.window.title isEqualToString:@"Test Web Page"], @"window should have title set by the stub html");
    
    [controller release];
}

@end
