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

#import "KSWriterTestCase.h"

#import <SenTestingKit/SenTestingKit.h>
#import <WebKit/WebKit.h>

@interface KSHTMLWriterSnippetTests : KSWriterTestCase

@property (assign, nonatomic) BOOL done;

@end

@implementation KSHTMLWriterSnippetTests

@synthesize done;

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    done = YES;
}    

#pragma mark - Helpers

- (WebView*)webViewWithStubPage
{
    WebView* result = nil;
    NSError* error = nil;
    NSURL* stubURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"Stub" withExtension:@"html"];
    NSString* stubHTML = [NSString stringWithContentsOfURL:stubURL encoding:NSUTF8StringEncoding error:&error];
    if (stubHTML && !error)
    {
        result = [[WebView alloc] initWithFrame: NSMakeRect (0,0,640,480)];
        result.frameLoadDelegate = self;
        [[result mainFrame] loadRequest:[NSURLRequest requestWithURL:stubURL]];
        
        while (self.done == NO)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        }
   }
    
    return [result autorelease];
}

+ (id)testCaseWithSelector:(SEL)selector url:(NSURL*)url
{
    NSString* name = [[url lastPathComponent] stringByDeletingPathExtension];
    KSHTMLWriterSnippetTests* test = [super testCaseWithSelector:selector param:url name:name];

    return test;
}

- (void)testWritingSnippetsWithWriterClass:(Class)class
{
    NSURL* snippetURL = self.dynamicTestParameter;

    WebView* view = [self webViewWithStubPage];
    DOMDocument* document = view.mainFrame.DOMDocument;
    DOMHTMLElement* element = (DOMHTMLElement*) [document getElementById:@"content"];
    
    NSError* error = nil;
    NSString* snippetHTML = [NSString stringWithContentsOfURL:snippetURL encoding:NSUTF8StringEncoding error:&error];
    
    [element setInnerHTML:snippetHTML];
    
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSHTMLWriter* writer = [[class alloc] initWithOutputWriter:output];
    KSXMLWriterDOMAdaptor* adaptor = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer];
    
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

    WebView* view = [self webViewWithStubPage];
    DOMDocument* document = view.mainFrame.DOMDocument;
    DOMHTMLElement* element = (DOMHTMLElement*) [document getElementById:@"content"];

    [element setInnerHTML:inputHTML];
    
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSHTMLWriter* writer = [[class alloc] initWithOutputWriter:output];
    KSXMLWriterDOMAdaptor* adaptor = [[KSXMLWriterDOMAdaptor alloc] initWithXMLWriter:writer options:KSXMLWriterDOMAdaptorPrettyPrint];
    
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
    id result = [[[SenTestSuite alloc] initWithName:NSStringFromClass(self)] autorelease];
    
    // simple html tests
    NSArray* snippets = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"html" subdirectory:@"Snippets/Normal"];
    for (NSURL* snippetURL in snippets)
    {
        [result addTest:[self testCaseWithSelector:@selector(testWritingSnippetWithXMLWriter) url:snippetURL]];
        [result addTest:[self testCaseWithSelector:@selector(testWritingSnippetWithHTMLWriter) url:snippetURL]];
    }

    // pretty printing tests
    snippets = [[NSBundle mainBundle] URLsForResourcesWithExtension:nil subdirectory:@"Snippets/Pretty"];
    for (NSURL* snippetURL in snippets)
    {
        [result addTest:[self testCaseWithSelector:@selector(testWritingSnippetWithHTMLWriterPretty) url:snippetURL]];
    }
    
    return result;
}

@end
