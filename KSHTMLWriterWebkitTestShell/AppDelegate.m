//
//  AppDelegate.m
//  KSHTMLWriterWebkitTestShell
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()

#pragma mark - Private Methods

- (void)loadStubPage;

@end


@implementation AppDelegate

#pragma mark - Properties

@synthesize window = _window;
@synthesize webview = _webview;

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - App Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self loadStubPage];
}

#pragma mark - Utilities

- (void)loadStubPage
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"Stub" withExtension:@"html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.webview mainFrame] loadRequest:request];
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    NSLog(@"got title");
    [self.window setTitle:title];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSLog(@"frame loaded");
}

@end
