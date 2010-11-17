//
//  KSDOMToHTMLWriter.m
//  Sandvox
//
//  Created by Mike on 25/06/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSDOMToHTMLWriter.h"


@implementation KSDOMToHTMLWriter

#pragma mark Delegate

@synthesize delegate = _delegate;

- (DOMNode *)willWriteDOMElement:(DOMElement *)element
{
    if ([self delegate])
    {
        return [[self delegate] HTMLWriter:self willWriteDOMElement:element];
    }
    else
    {
        return element;
    }
}

@end
