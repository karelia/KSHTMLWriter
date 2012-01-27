//
//  AppDelegate.h
//  KSHTMLWriterWebkitTestShell
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StubWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, StubWindowDelegate>

@property (retain) IBOutlet StubWindowController* window;

@end
