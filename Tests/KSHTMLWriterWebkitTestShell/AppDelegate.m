//
//  AppDelegate.m
//  KSHTMLWriterWebkitTestShell
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "AppDelegate.h"
#import "StubWindowController.h"

@implementation AppDelegate

#pragma mark - Properties

@synthesize window = _window;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - App Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.window = [[[StubWindowController alloc] init] autorelease];
    self.window.stubDelegate = self;
    [self.window.window makeKeyAndOrderFront:self];
    [self.window loadStubPage];
}

- (void)stubWindowDidLoadStub:(StubWindowController *)window
{
    [self.window injectContent:@"This is some injected content"];
}

@end
