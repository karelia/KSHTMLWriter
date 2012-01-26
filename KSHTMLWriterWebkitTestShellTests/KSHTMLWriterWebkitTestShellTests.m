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

- (BOOL)string:(NSString*)string1 matchesString:(NSString*)string2
{
    ;
    
    NSUInteger length = [string1 length];
    BOOL match = ([string2 length] == length);
    
    if (match)
    {
        for (NSUInteger n = 0; n < length; ++n)
        {
            UniChar c1 = [string1 characterAtIndex:n];
            UniChar c2 = [string2 characterAtIndex:n];
            if (c1 != c2)
            {
                NSLog(@"Comparison failed at character %ld (0x%x '%c' vs 0x%x '%c') of '%@'", n, c1, c1, c2, c2, string1);
                match = NO;
                break;
            }
        }
    }

    return match;
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
        NSLog(@"written '%@' expected '%@'", written, snippetHTML);
        STAssertTrue([self string:written matchesString:snippetHTML], @"written html should match the original snippet");
        
        [adaptor release];
        [writer release];
        
        
        [output release];
        
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
