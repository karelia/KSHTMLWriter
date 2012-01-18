//
//  KSHTMLWriterWebkitTestShellTests.m
//  KSHTMLWriterWebkitTestShellTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriterWebkitTestShellTests.h"

#import "AppDelegate.h"
#import "StubWindowController.h"

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

    [NSRunLoop currentRunLoop];
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
    
    [NSRunLoop currentRunLoop];
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
    }

    STAssertTrue([controller.window.title isEqualToString:@"Test Web Page"], @"window should have title set by the stub html");
    
    [controller release];
}

@end
