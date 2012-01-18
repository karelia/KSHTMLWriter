//
//  WindowController.h
//  KSHTMLWriter
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class WindowController;

@protocol StubDelegate <NSObject>

- (void)testWindowDidLoadStub:(WindowController*)window;

@end

@interface WindowController : NSWindowController

@property (assign) IBOutlet WebView* webview;
@property (assign) BOOL stubLoaded;
@property (assign) id<StubDelegate> stubDelegate;

- (void)loadStubPage;
- (void)injectContent:(NSString*)content;

@end
