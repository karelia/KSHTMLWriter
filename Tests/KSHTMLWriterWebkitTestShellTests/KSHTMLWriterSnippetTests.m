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
#import "KSWriterTestCase.h"


#import <SenTestingKit/SenTestingKit.h>
#import <WebKit/WebKit.h>

@class StubWindowController;

@interface KSHTMLWriterSnippetTests : KSWriterTestCase

@property (strong, nonatomic) StubWindowController* controller;

@end

@implementation KSHTMLWriterSnippetTests

@synthesize controller;

#pragma mark - Helpers

+ (id)testCaseWithSelector:(SEL)selector url:(NSURL*)url controller:(StubWindowController*)controller
{
    NSString* name = [[url lastPathComponent] stringByDeletingPathExtension];
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
    NSURL* snippetURL = self.dynamicTestParameter;
    
    NSError* error = nil;
    NSString* snippetHTML = [NSString stringWithContentsOfURL:snippetURL encoding:NSUTF8StringEncoding error:&error];
    [self.controller injectContent:snippetHTML];
    
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSHTMLWriter* writer = [[class alloc] initWithOutputWriter:output];
    KSXMLWriterDOMAdaptor* adaptor = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer];
    
    DOMDocument* document = self.controller.webview.mainFrame.DOMDocument;
    DOMElement* element = [document getElementById:@"content"];
    [adaptor writeInnerOfDOMNode:element];
    
    NSString* written = [output string];
    [self assertString:written matchesString:snippetHTML];
    
    [output release];
    [adaptor release];
    [writer release];
}

- (void)testPrettyPrintSnippetsWithWriterClass:(Class)class
{
    NSURL* snippetURL = self.dynamicTestParameter;
    
    NSError* error = nil;
    NSString* inputHTML = [NSString stringWithContentsOfURL:[snippetURL URLByAppendingPathComponent:@"input.html"] encoding:NSUTF8StringEncoding error:&error];
    NSString* outputHTML = [NSString stringWithContentsOfURL:[snippetURL URLByAppendingPathComponent:@"output.html"] encoding:NSUTF8StringEncoding error:&error];
    [self.controller injectContent:inputHTML];
    
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSHTMLWriter* writer = [[class alloc] initWithOutputWriter:output];
    KSXMLWriterDOMAdaptor* adaptor = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer options:KSXMLWriterDOMAdaptorPrettyPrint];
    
    DOMDocument* document = self.controller.webview.mainFrame.DOMDocument;
    DOMElement* element = [document getElementById:@"content"];
    [adaptor writeInnerOfDOMNode:element];
    
    NSString* written = [output string];
    [self assertString:written matchesString:outputHTML];
    
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

- (void)testWritingSnippetWithHTMLWriterPretty
{
    [self testPrettyPrintSnippetsWithWriterClass:[KSHTMLWriter class]];
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
    
    // simple html tests
    NSArray* snippets = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"html" subdirectory:@"Snippets/Normal"];
    for (NSURL* snippetURL in snippets)
    {
        [result addTest:[self testCaseWithSelector:@selector(testWritingSnippetWithXMLWriter) url:snippetURL controller:controller]];
        [result addTest:[self testCaseWithSelector:@selector(testWritingSnippetWithHTMLWriter) url:snippetURL controller:controller]];
    }

    // pretty printing tests
    snippets = [[NSBundle mainBundle] URLsForResourcesWithExtension:nil subdirectory:@"Snippets/Pretty"];
    for (NSURL* snippetURL in snippets)
    {
        [result addTest:[self testCaseWithSelector:@selector(testWritingSnippetWithHTMLWriterPretty) url:snippetURL controller:controller]];
    }
    
    [controller release];

    return result;
}

@end
