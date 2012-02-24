//
//  KSHTMLWriterSnippetTests.m
//  KSHTMLWriterSnippetTests
//
//  Created by Sam Deane on 24/02/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriterSnippetTests.h"

#import <WebKit/WebKit.h>

@implementation KSHTMLWriterSnippetTests

@synthesize done;

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    done = YES;
}    

#pragma mark - Helpers

- (WebView*)webViewWithStubPage
{
    WebView* result = nil;
    NSError* error = nil;
    NSURL* stubURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"Stub" withExtension:@"html"];
    NSString* stubHTML = [NSString stringWithContentsOfURL:stubURL encoding:NSUTF8StringEncoding error:&error];
    if (stubHTML && !error)
    {
        result = [[WebView alloc] initWithFrame: NSMakeRect (0,0,640,480)];
        result.frameLoadDelegate = self;
        [[result mainFrame] loadRequest:[NSURLRequest requestWithURL:stubURL]];
        
        while (self.done == NO)
        {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
        }
   }
    
    return [result autorelease];
}

+(NSString*)snippetsPath
{
    return nil;
}

+ (NSDictionary*)dynamicTestData
{
    NSMutableDictionary* result = nil;
    NSString* path = [self snippetsPath];
    if (path)
    {
        NSArray* snippets = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"html" subdirectory:[self snippetsPath]];
        result = [NSMutableDictionary dictionaryWithCapacity:[snippets count]];
        for (NSURL* snippet in snippets)
        {
            [result setObject:snippets forKey:[snippet lastPathComponent]];
        }
    }
    
    return result;
}

@end
