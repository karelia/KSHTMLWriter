//
//  WindowController.h
//  KSHTMLWriter
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class StubWindowController;

@protocol StubWindowDelegate <NSObject>

- (void)stubWindowDidLoadStub:(StubWindowController*)window;

@end

@interface StubWindowController : NSWindowController

@property (assign) IBOutlet WebView* webview;
@property (assign) BOOL stubLoaded;
@property (assign) id<StubWindowDelegate> stubDelegate;

- (void)loadStubPage;
- (void)injectContent:(NSString*)content;

@end
