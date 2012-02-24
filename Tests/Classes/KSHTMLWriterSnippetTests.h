//
//  KSHTMLWriterSnippetTests.m
//  KSHTMLWriterSnippetTests
//
//  Created by Sam Deane on 24/02/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "ECDynamicTestCase.h"

@class WebView;

@interface KSHTMLWriterSnippetTests : ECDynamicTestCase

@property (assign, nonatomic) BOOL done;

- (WebView*)webViewWithStubPage;

@end
