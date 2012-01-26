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

#pragma mark - Helpers

- (void)checkString:(NSString*)string1 matchesString:(NSString*)string2
{
    NSUInteger length1 = [string1 length];
    NSUInteger length2 = [string2 length];
    
    STAssertTrue(length1 == length2, @"string lengths don't match: for %ld (%@) vs %ld (%@)", length1, string1, length2, string2); 
    
    for (NSUInteger n = 0; n < length1; ++n)
    {
        UniChar c1 = [string1 characterAtIndex:n];
        UniChar c2 = [string2 characterAtIndex:n];
        STAssertTrue(c1 == c2, @"Comparison failed at character %ld (0x%x '%c' vs 0x%x '%c') of '%@'", n, c1, c1, c2, c2, string1);
    }
}


- (void)testWritingSnippetsWithWriterClass:(Class)writerClass
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
        KSXMLWriter* writer = [[writerClass alloc] initWithOutputWriter:output];
        KSXMLWriterDOMAdaptor* adaptor = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer];
        
        DOMDocument* document = controller.webview.mainFrame.DOMDocument;
        DOMElement* element = [document getElementById:@"content"];
        [adaptor writeInnerOfDOMNode:element];
        
        NSString* written = [output string];
        [self checkString:written matchesString:snippetHTML];
        
        [adaptor release];
        [writer release];
        
        
        [output release];
        
    }
    
    STAssertTrue([controller.window.title isEqualToString:@"Test Web Page"], @"window should have title set by the stub html");
    
    [controller release];
}

#pragma mark - Tests

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

- (void)testWritingSnippetsWithHTMLWriter
{
    [self testWritingSnippetsWithWriterClass:[KSHTMLWriter class]];
}

- (void)testWritingSnippetsWithXMLWriter
{
    [self testWritingSnippetsWithWriterClass:[KSXMLWriter class]];
}


@end
