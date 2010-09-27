//
//  KSHTMLWriter+DOM.m
//
//  Copyright (c) 2010, Mike Abdullah and Karelia Software
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import "KSHTMLWriter+DOM.h"

//#import "DOMNode+Karelia.h"


//static NSSet *sTagsWithNewlineOnOpen = nil;
//static NSSet *sTagsThatCanBeSelfClosed = nil;
//static NSSet *sTagsWithNewlineOnClose = nil;


@interface DOMNode (KSHTMLWriter)

// All nodes can be written. We just don't really want to expose this implementation detail. DOMElement uses it recurse down through element contents.
- (DOMNode *)ks_writeHTML:(KSHTMLWriter *)writer;
- (DOMNode *)ks_writeHTML:(KSHTMLWriter *)writer fromRange:(DOMRange *)range;

- (void)ks_writeContent:(KSHTMLWriter *)writer fromRange:(DOMRange *)range;

- (BOOL)ks_isDescendantOfDOMNode:(DOMNode *)possibleAncestor;

@end


#pragma mark -


@implementation KSHTMLWriter (DOM)

#pragma mark High Level

- (void)writeDOMElement:(DOMElement *)element;  // like -outerHTML
{
    [self startElement:[element tagName] withDOMElement:element];
    [self writeInnerOfDOMNode:element];
    [self endElementWithDOMElement:element];
}

- (void)writeInnerOfDOMNode:(DOMNode *)element;  // like -innerHTML
{
    [self writeInnerOfDOMNode:element startAtChild:[element firstChild]];
}

- (void)writeDOMRange:(DOMRange *)range;
{
    DOMNode *ancestor = [range commonAncestorContainer];
    [ancestor ks_writeContent:self fromRange:range];
}

#pragma mark Implementation

- (void)writeInnerOfDOMNode:(DOMNode *)element startAtChild:(DOMNode *)aNode;
{
    // It's best to iterate using a Linked List-like approach in case the iteration also modifies the DOM
    while (aNode)
    {
        aNode = [aNode ks_writeHTML:self];
    }
}

- (void)startElement:(NSString *)elementName withDOMElement:(DOMElement *)element;    // open the tag and write attributes
{
    // Write attributes
    if ([element hasAttributes]) // -[DOMElement attributes] is slow as it has to allocate an object. #78691
    {
        DOMNamedNodeMap *attributes = [element attributes];
        NSUInteger index;
        for (index = 0; index < [attributes length]; index++)
        {
            DOMAttr *anAttribute = (DOMAttr *)[attributes item:index];
            [self pushAttribute:[anAttribute name] value:[anAttribute value]];
        }
    }
    
    
    [self startElement:elementName];
}

- (DOMNode *)endElementWithDOMElement:(DOMElement *)element;    // returns the next sibling to write
{
    [self endElement];
    return [element nextSibling];
}

- (DOMNode *)didWriteDOMText:(DOMText *)textNode nextNode:(DOMNode *)nextNode;
{
    //  For subclasses to override
    return nextNode;
}

#pragma mark Pseudo-delegate

- (DOMNode *)willWriteDOMElement:(DOMElement *)element; { return element; }

@end


#pragma mark -


@implementation DOMNode (KSHTMLWriter)

- (DOMNode *)ks_writeHTML:(KSHTMLWriter *)writer;
{
    // Recurse through child nodes
    DOMNode *aNode = [self firstChild];
    while (aNode)
    {
        aNode = [aNode ks_writeHTML:writer];
    }
    
    return [self nextSibling];
} 

- (DOMNode *)ks_writeHTML:(KSHTMLWriter *)writer fromRange:(DOMRange *)range;
{
    [self ks_writeContent:writer fromRange:range];
    return [self nextSibling];
}

- (void)ks_writeContent:(KSHTMLWriter *)writer fromRange:(DOMRange *)range;
{
    // If we begin outside the range, figure out the first child that actually belongs in the range
    DOMNode *aNode = [self firstChild];
    
    DOMNode *startContainer = [range startContainer];
    if (self == startContainer)
    {
        aNode = [[self childNodes] item:[range startOffset]];
    }
    else if ([startContainer ks_isDescendantOfDOMNode:self])
    {
        while (aNode)
        {
            if ([[range startContainer] ks_isDescendantOfDOMNode:aNode]) break;
            aNode = [aNode nextSibling];
        }
    }
    
    
    // Write child nodes that fall within the range
    DOMNode *endContainer = [range endContainer];
    DOMNode *endNode = (self == endContainer) ? [[self childNodes] item:([range endOffset] - 1)] : nil;
    
    while (aNode)
    {
        DOMNode *nextNode = [aNode ks_writeHTML:writer fromRange:range];
        
        if (aNode == endNode || [endContainer ks_isDescendantOfDOMNode:aNode])
        {
            break;
        }
        
        aNode = nextNode;
    }
}

- (BOOL)ks_isDescendantOfDOMNode:(DOMNode *)possibleAncestor;
{
    DOMNode *aNode = self;
    while (aNode)
    {
        if (aNode == possibleAncestor) return YES;        
        aNode = [aNode parentNode];
    }
    
    return NO;
}

@end


#pragma mark -


@implementation DOMElement (KSHTMLWriter)

- (DOMNode *)ks_writeHTML:(KSHTMLWriter *)writer;
{
    //  *Elements* are where the clever recursion starts, so switch responsibility back to the writer.
    DOMNode *node = [writer willWriteDOMElement:self];
    if (node == self)
    {
        [writer startElement:[[self tagName] lowercaseString] withDOMElement:self];
        [writer writeInnerOfDOMNode:self];
        return [writer endElementWithDOMElement:self];
    }
    else
    {
        return node;
    }
}

- (DOMNode *)ks_writeHTML:(KSHTMLWriter *)writer fromRange:(DOMRange *)range;
{
    // Bit of a special case. When a DOM range ends at the start of an element 
    if ([range endContainer] == self && [range endOffset] == 0)
    {
        [writer writeLineBreak];
        return nil;
    }
    
    
    // Let pseudo-delegate jump in if it likes
    DOMNode *node = [writer willWriteDOMElement:self];
    if (node != self) 
    {
        return node;
    }
    
    
    // Start the element
    [writer startElement:[[self tagName] lowercaseString] withDOMElement:self];
    
    // Child nodes
    DOMNode *result = [super ks_writeHTML:writer fromRange:range];
    
    // Close the tag
    [writer endElement];
    
    return result;
}
/*
- (void)writeCleanedHTMLToContext:(KSHTMLWriter *)writer innards:(BOOL)writeInnards;
{
	[writer startElementWithDOMElement:self];
    
	
	if (!sTagsThatCanBeSelfClosed)
	{
		sTagsThatCanBeSelfClosed = [[NSSet alloc] initWithObjects:@"img", @"br", @"hr", @"p", @"meta", @"link", @"base", @"param", @"source", nil];
	}
	
    
    NSString *tagName = [[self tagName] lowercaseString];
    
	if ([self hasChildNodes] || ![sTagsThatCanBeSelfClosed containsObject:tagName])
	{
		[writer closeStartTag];		// close the node first
		
		if (nil == sTagsWithNewlineOnOpen)
		{
			sTagsWithNewlineOnOpen = [[NSSet alloc] initWithObjects:@"head", @"body", @"ul", @"ol", @"table", @"tr", nil];
		}
		if (writeInnards)
		{
			if ([self hasChildNodes])
			{
				[self writeCleanedInnerHTMLToContext:writer];		// <----- RECURSION POINT
			}
			[writer endElement];
		}
	}
	else	// no children, self-close tag.
	{
		[writer closeEmptyElementTag];
	}
	
	if (writeInnards)	// only deal with newline if we're doing the innards too
	{
		if (!sTagsWithNewlineOnClose)
		{
			sTagsWithNewlineOnClose = [[NSSet alloc] initWithObjects:@"ul", @"ol", @"table", @"li", @"p", @"h1", @"h2", @"h3", @"h4", @"blockquote", @"br", @"pre", @"td", @"tr", @"div", @"hr", nil];
		}
	}
}
*/
@end


#pragma mark -


@implementation DOMCharacterData (KSHTMLWriter)

- (DOMNode *)writeData:(NSString *)data toHTMLWriter:(KSHTMLWriter *)writer;
{
    //  The text to write is passed in (rather than calling [self data]) so as to handle writing a subset of it
    [writer writeText:data];
    return [super ks_writeHTML:writer];
}

- (DOMNode *)ks_writeHTML:(KSHTMLWriter *)writer;
{
    DOMNode *result = [self writeData:[self data] toHTMLWriter:writer];
    return result;
}

- (void)ks_writeContent:(KSHTMLWriter *)writer fromRange:(DOMRange *)range;
{
    // Character data treats that text as its content. This is so you can specify a substring using the offsets in DOMRange
    NSString *text = [self data];
    
    if ([range endContainer] == self)
    {
        text = [text substringToIndex:[range endOffset]];
    }
    if ([range startContainer] == self)
    {
        text = [text substringFromIndex:[range startOffset]];
    }
    
    [self writeData:text toHTMLWriter:writer];
}

@end


@implementation DOMComment (KSHTMLWriter)

- (DOMNode *)writeData:(NSString *)data toHTMLWriter:(KSHTMLWriter *)writer;
{
	[writer writeComment:data];
    return [self nextSibling];
}

@end


@implementation DOMText (KSHTMLWriter)

- (DOMNode *)ks_writeHTML:(KSHTMLWriter *)writer;
{
    DOMNode *result = [super ks_writeHTML:writer];
    result = [writer didWriteDOMText:self nextNode:result];
    
    return result;
}

@end



@implementation DOMCDATASection (KSHTMLWriter)

- (DOMNode *)writeData:(NSString *)data toHTMLWriter:(KSHTMLWriter *)writer;
{
	[writer writeHTMLString:[NSString stringWithFormat:@"<![CDATA[%@]]>", data]];
    return [self nextSibling];
}

@end


