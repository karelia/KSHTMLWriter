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

@interface KSHTMLWriterWebkitTestShellTests : KSHTMLWriterTestCase

@end

@implementation KSHTMLWriterWebkitTestShellTests

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

@end
