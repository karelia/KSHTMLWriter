//
//  KSHTMLWriterNormalSnippetTests.m
//  KSHTMLWriterNormalSnippetTests
//
//  Created by Sam Deane on 24/02/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriterSnippetTests.h"

#import "KSHTMLWriter.h"
#import "KSStringWriter.h"
#import "KSXMLWriterDOMAdaptor.h"

#import <SenTestingKit/SenTestingKit.h>
#import <WebKit/WebKit.h>

@interface KSHTMLWriterNormalSnippetTests : KSHTMLWriterSnippetTests

@end

@implementation KSHTMLWriterNormalSnippetTests

+ (NSString*)snippetsPath
{
    return @"Snippets/Normal";
}

+(NSString*)snippetsExtension
{
    return @"html";
}

- (void)testWritingSnippetsWithWriterClass:(Class)class
{
    NSURL* snippetURL = self.parameterisedTestDataItem;

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


#pragma mark - Tests

- (void)parameterisedTestWritingSnippetWithHTMLWriter
{
    [self testWritingSnippetsWithWriterClass:[KSHTMLWriter class]];
}

- (void)parameterisedTestWritingSnippetWithXMLWriter
{
    [self testWritingSnippetsWithWriterClass:[KSXMLWriter class]];
}

@end
