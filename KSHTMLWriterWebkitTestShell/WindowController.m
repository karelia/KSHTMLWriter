//
//  WindowController.m
//  KSHTMLWriter
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "WindowController.h"

#import <WebKit/WebKit.h>

@interface WindowController()

#pragma mark - Private Methods

@end



@implementation WindowController

@synthesize stubDelegate;
@synthesize stubLoaded;
@synthesize webview;

- (id)init
{
    self = [super initWithWindowNibName:@"Window"];
    if (self) 
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark - Utilities

- (void)loadStubPage
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"Stub" withExtension:@"html"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self.webview mainFrame] loadRequest:request];
}

- (void)injectContent:(NSString *)content
{
    DOMDocument* document = [self.webview mainFrame].DOMDocument;
    DOMHTMLElement* contentDiv = (DOMHTMLElement*) [document getElementById:@"content"];
    [contentDiv setInnerHTML:content];
}

#pragma mark - Web View Delegate Methods

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    [self.window setTitle:title];
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    self.stubLoaded = YES;
    if (stubDelegate)
    {
        [stubDelegate testWindowDidLoadStub:self];
    }
}

@end
