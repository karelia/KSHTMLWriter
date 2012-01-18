//
//  AppDelegate.h
//  KSHTMLWriterWebkitTestShell
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, StubDelegate>

@property (retain) IBOutlet WindowController* window;

@end
