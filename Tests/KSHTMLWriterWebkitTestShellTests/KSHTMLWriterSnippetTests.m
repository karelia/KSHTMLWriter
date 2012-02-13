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
#import "KSHTMLWriterTestCase.h"


#import <SenTestingKit/SenTestingKit.h>
#import <WebKit/WebKit.h>

@class StubWindowController;

@interface KSHTMLWriterSnippetTests : KSHTMLWriterTestCase

@property (strong, nonatomic) StubWindowController* controller;

@end

@implementation KSHTMLWriterSnippetTests

@synthesize controller;

#pragma mark - Helpers

+ (id)testCaseWithSelector:(SEL)selector url:(NSURL*)url controller:(StubWindowController*)controller
{
    NSString* name = [[[url lastPathComponent] stringByDeletingPathExtension] capitalizedString];
    KSHTMLWriterSnippetTests* test = [super testCaseWithSelector:selector param:url name:name];
    test.controller = controller;

    return test;
}
- (void)dealloc
{
    [controller release];
    [super dealloc];
}

- (void)testWritingSnippetsWithWriterClass:(Class)class
{
    //    STAssertTrue([controller.window.title isEqualToString:@"Test Web Page"], @"window should have title set by the stub html");

    NSURL* snippetURL = self.dynamicTestParameter;
    
    NSError* error = nil;
    NSString* snippetHTML = [NSString stringWithContentsOfURL:snippetURL encoding:NSUTF8StringEncoding error:&error];
    [controller injectContent:snippetHTML];
    
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSHTMLWriter* writer = [[class alloc] initWithOutputWriter:output];
    KSXMLWriterDOMAdaptor* adaptor = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer];
    
    DOMDocument* document = controller.webview.mainFrame.DOMDocument;
    DOMElement* element = [document getElementById:@"content"];
    [adaptor writeInnerOfDOMNode:element];
    
    NSString* written = [output string];
    [self assertString:written matchesString:snippetHTML];
    
    [output release];
    [adaptor release];
    [writer release];
}

#pragma mark - Tests

- (void)testWritingSnippetWithHTMLWriter
{
    [self testWritingSnippetsWithWriterClass:[KSHTMLWriter class]];
}

- (void)testWritingSnippetWithXMLWriter
{
    [self testWritingSnippetsWithWriterClass:[KSXMLWriter class]];
}

+ (id) defaultTestSuite
{
    StubWindowController* controller = [[StubWindowController alloc] init];
    [controller.window makeKeyAndOrderFront:self];
    [controller loadStubPage];
    
    while (controller.stubLoaded == NO)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    }

    id result = [[[SenTestSuite alloc] initWithName:NSStringFromClass(self)] autorelease];
    
    NSArray* snippets = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"html" subdirectory:@"Snippets"];
    for (NSURL* snippetURL in snippets)
    {
        [result addTest:[self testCaseWithSelector:@selector(testWritingSnippetWithXMLWriter) url:snippetURL controller:controller]];
        [result addTest:[self testCaseWithSelector:@selector(testWritingSnippetWithHTMLWriter) url:snippetURL controller:controller]];
    }

    [controller release];

    return result;
}

@end
