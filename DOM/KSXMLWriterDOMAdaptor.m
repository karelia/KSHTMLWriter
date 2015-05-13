//
//  KSXMLWriterDOMAdaptor.m
//  Sandvox
//
//  Created by Mike Abdullah on 25/06/2010.
//  Copyright © 2010 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "KSXMLWriterDOMAdaptor.h"

#import "KSHTMLWriter.h"


@interface DOMNode (KSDOMToHTMLWriter)

// All nodes can be written. We just don't really want to expose this implementation detail. DOMElement uses it to recurse down through element contents.
- (DOMNode *)ks_writeHTML:(KSXMLWriterDOMAdaptor *)writer;
- (DOMNode *)ks_writeHTML:(KSXMLWriterDOMAdaptor *)writer fromRange:(DOMRange *)range;

- (void)ks_writeContent:(KSXMLWriterDOMAdaptor *)writer fromRange:(DOMRange *)range;

- (BOOL)ks_isDescendantOfDOMNode:(DOMNode *)possibleAncestor;

@end


#pragma mark -


@implementation KSXMLWriterDOMAdaptor

- (id)initWithXMLWriter:(KSXMLWriter *)writer;
{
    return [self initWithXMLWriter:writer options:NSXMLNodeOptionsNone];
}

- (id)initWithXMLWriter:(KSXMLWriter *)writer options:(KSXMLWriterDOMAdaptorOptions)options;
{
    if (self = [self init])
    {
        _writer = [writer retain];
        _options = options;
    }
    return self;
}

- (void) dealloc;
{
    [_writer release];
    [super dealloc];
}

@synthesize XMLWriter = _writer;
@synthesize options = _options;

#pragma mark Convenience

+ (NSString *)outerHTMLOfDOMElement:(DOMElement *)element;
{
    KSWriter *output = [KSWriter stringWriterWithEncoding:NSUnicodeStringEncoding];
    KSHTMLWriter *htmlWriter = [[KSHTMLWriter alloc] initWithOutputWriter:output];
    KSXMLWriterDOMAdaptor *adaptor = [[self alloc] initWithXMLWriter:htmlWriter];
    
    [adaptor writeDOMElement:element];
    
    [adaptor release];
    [htmlWriter close];
    [htmlWriter release];
    
    return output.string;
}

+ (NSString *)outerXMLOfDOMElement:(DOMElement *)element options:(KSXMLWriterDOMAdaptorOptions)options;
{
    KSWriter *output = [KSWriter stringWriterWithEncoding:NSUnicodeStringEncoding];
    KSXMLWriter *xmlWriter = [[KSXMLWriter alloc] initWithOutputWriter:output];
    KSXMLWriterDOMAdaptor *adaptor = [[self alloc] initWithXMLWriter:xmlWriter options:options];
    
    [adaptor writeDOMElement:element];
    
    [adaptor release];
    [xmlWriter close];
    [xmlWriter release];
    
    return output.string;
}

#pragma mark High Level

- (void)writeDOMElement:(DOMElement *)element;  // like -outerHTML
{
    [self startElement:[[element tagName] lowercaseString] withDOMElement:element];
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
        unsigned index;
        for (index = 0; index < [attributes length]; index++)
        {
            DOMAttr *anAttribute = (DOMAttr *)[attributes item:index];
            [[self XMLWriter] pushAttribute:[anAttribute name] value:[anAttribute value]];
        }
    }
    
    
    if ([self options] & KSXMLWriterDOMAdaptorPrettyPrint)
    {
        // pretty printing leaves the writer to make whitespace
        [[self XMLWriter] startElement:elementName];
    }
    else
    {
        [[self XMLWriter] startElement:elementName writeInline:YES];
    }
}

- (DOMNode *)endElementWithDOMElement:(DOMElement *)element;    // returns the next sibling to write
{
    id <KSXMLWriterDOMAdaptorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(DOMAdaptor:didWriteContentsOfDOMElement:)]) {
        [self.delegate DOMAdaptor:self didWriteContentsOfDOMElement:element];
    }
    
    [[self XMLWriter] endElement];
    
    // Make sure to grab next node before messaging delegate, since it might do something like
    // remove `element` from the document.
    DOMNode *result = element.nextSibling;
    
    if ([delegate respondsToSelector:@selector(DOMAdaptor:didWriteDOMElement:)]) {
        [self.delegate DOMAdaptor:self didWriteDOMElement:element];
    }
    
    return result;
}

- (DOMNode *)writeComment:(NSString *)comment withDOMComment:(DOMComment *)commentNode;
{
    [[self XMLWriter] writeComment:comment];
    return [commentNode nextSibling];
}

#pragma mark Pseudo-delegate

- (DOMNode *)willWriteDOMText:(DOMText *)text; {
    id <KSXMLWriterDOMAdaptorDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(DOMAdaptor:willWriteDOMText:)]) {
        DOMNode *node = [delegate DOMAdaptor:self willWriteDOMText:text];
        if (node != text) return node;
    }
    
    return text;
}

- (DOMNode *)didWriteDOMText:(DOMText *)textNode nextNode:(DOMNode *)nextNode;
{
    // Is the next node also text? If so, normalize by appending to textNode.
    if ([self options] & KSXMLWriterDOMAdaptorNormalize)
    {
        if ([nextNode nodeType] == DOM_TEXT_NODE)
        {
            // Do usual writing. Produces correct output, and handles possibility of a chain of unnormalized text nodes
            DOMNode *nodeToAppend = nextNode;
            nextNode = [nodeToAppend ks_writeHTML:self];
            
            
            // Maintain selection
            /*WebView *webView = [[[textNode ownerDocument] webFrame] webView];
            DOMRange *selection = [webView selectedDOMRange];
            NSSelectionAffinity affinity = [webView selectionAffinity];
            
            NSUInteger length = [textNode length];
            NSIndexPath *startPath = [[selection ks_startIndexPathFromNode:nodeToAppend] indexPathByAddingToLastIndex:length];
            
            NSIndexPath *endPath = [[selection ks_endIndexPathFromNode:nodeToAppend] indexPathByAddingToLastIndex:length];
            if (!endPath)
            {
                // When selection is at end of textNode, WebKit extends selection to cover all of appended text. #136170
                endPath = [selection ks_endIndexPathFromNode:textNode];
            }*/
            
            
            // Delete node by appending to ourself
            [textNode appendData:[nodeToAppend nodeValue]];
            [[nodeToAppend parentNode] removeChild:nodeToAppend];
            
            
            // Restore selection
            /*if (startPath) [selection ks_setStartWithIndexPath:startPath fromNode:textNode];
            if (endPath) [selection ks_setEndWithIndexPath:endPath fromNode:textNode];
            if (startPath || endPath) [webView setSelectedDOMRange:selection affinity:affinity];*/
        }
    }
    
    return nextNode;
}

- (DOMNode *)willWriteDOMElement:(DOMElement *)element
{
    if ([self delegate])
    {
        return [[self delegate] DOMAdaptor:self willWriteDOMElement:element];
    }
    else
    {
        return element;
    }
}

#pragma mark Delegate

@synthesize delegate = _delegate;

@end


#pragma mark -


@implementation DOMNode (KSDOMToHTMLWriter)

- (DOMNode *)ks_writeHTML:(KSXMLWriterDOMAdaptor *)writer;
{
    // Recurse through child nodes
    DOMNode *aNode = [self firstChild];
    while (aNode)
    {
        aNode = [aNode ks_writeHTML:writer];
    }
    
    return [self nextSibling];
} 

- (DOMNode *)ks_writeHTML:(KSXMLWriterDOMAdaptor *)writer fromRange:(DOMRange *)range;
{
    [self ks_writeContent:writer fromRange:range];
    return [self nextSibling];
}

- (void)ks_writeContent:(KSXMLWriterDOMAdaptor *)writer fromRange:(DOMRange *)range;
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


@implementation DOMElement (KSDOMToHTMLWriter)

- (DOMNode *)ks_writeHTML:(KSXMLWriterDOMAdaptor *)adaptor;
{
    //  *Elements* are where the clever recursion starts, so switch responsibility back to the writer.
    DOMNode *node = [adaptor willWriteDOMElement:self];
    if (node == self)
    {
        [adaptor startElement:[[self tagName] lowercaseString] withDOMElement:self];
        [adaptor writeInnerOfDOMNode:self];
        return [adaptor endElementWithDOMElement:self];
    }
    else
    {
        return node;
    }
}

- (DOMNode *)ks_writeHTML:(KSXMLWriterDOMAdaptor *)adaptor fromRange:(DOMRange *)range;
{
    // Bit of a special case. When a DOM range ends at the start of an element 
    if ([range endContainer] == self && [range endOffset] == 0)
    {
        [(KSHTMLWriter *)[adaptor XMLWriter] writeLineBreak];
        return nil;
    }
    
    
    // Let pseudo-delegate jump in if it likes
    DOMNode *node = [adaptor willWriteDOMElement:self];
    if (node != self) 
    {
        return node;
    }
    
    
    // Start the element
    [adaptor startElement:[[self tagName] lowercaseString] withDOMElement:self];
    
    // Child nodes
    DOMNode *result = [super ks_writeHTML:adaptor fromRange:range];
    
    // Close the tag
    [[adaptor XMLWriter] endElement];
    
    return result;
}
/*
 - (void)writeCleanedHTMLToContext:(KSDOMToHTMLWriter *)writer innards:(BOOL)writeInnards;
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


@implementation DOMCharacterData (KSDOMToHTMLWriter)

- (DOMNode *)writeData:(NSString *)data toHTMLWriter:(KSXMLWriterDOMAdaptor *)adaptor;
{
    /*  The text to write is passed in (rather than calling [self data]) so as to handle writing a subset of it
     */
    
    
    if ([adaptor options] & KSXMLWriterDOMAdaptorPrettyPrint)
    {
        // Unecessary whitespace should be trimmed here
        // For text inside HTML elements like <span>, whitespace has meaning, so domn't trim it
        KSXMLWriter *writer = [adaptor XMLWriter];
        NSString *parentElement = [writer topElement];
        if (!parentElement || ![writer canWriteElementInline:parentElement])
        {
            static NSCharacterSet *nonWhitespace;
            if (!nonWhitespace) nonWhitespace = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet] copy];
            
            
            BOOL isFirst = [self previousSibling] == nil;
            BOOL isLast = [self nextSibling] == nil;
            
            if (isFirst)
            {
                if (isLast)
                {
                    data = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                else
                {
                    // Trim off starting whitespace; ignore complete whitespace
                    NSUInteger nonWhitespaceStart = [data rangeOfCharacterFromSet:nonWhitespace].location;
                    if (nonWhitespaceStart == NSNotFound) return [super ks_writeHTML:adaptor];
                    if (nonWhitespaceStart > 0) data = [data substringFromIndex:nonWhitespaceStart];
                    
                    // Trailing whitespace should be a single space character; not a newline or similar
                    NSRange nonWhitespaceEnd = [data rangeOfCharacterFromSet:nonWhitespace options:NSBackwardsSearch];
                    if (NSMaxRange(nonWhitespaceEnd) < [data length])
                    {
                        NSUInteger length = [data length];
                        NSUInteger whitespaceLength = length - NSMaxRange(nonWhitespaceEnd);
                        
                        if (whitespaceLength > 1 || [data characterAtIndex:length - 1] != ' ')
                        {
                            data = [data stringByReplacingCharactersInRange:NSMakeRange(NSMaxRange(nonWhitespaceEnd), whitespaceLength)
                                                                 withString:@" "];
                        }
                    }
                }
            }
            else if (isLast)
            {
                // Trim off ending whitespace; ignore complete whitespace
                NSRange nonWhitespaceEnd = [data rangeOfCharacterFromSet:nonWhitespace options:NSBackwardsSearch];
                if (nonWhitespaceEnd.location == NSNotFound) return [super ks_writeHTML:adaptor];
                
                nonWhitespaceEnd.location++;
                if (nonWhitespaceEnd.location < [data length]) data = [data substringToIndex:nonWhitespaceEnd.location];
            }
            else
            {
                // Ignore complete whitespace, but let all else through
                NSRange nonWhitespaceStart = [data rangeOfCharacterFromSet:nonWhitespace options:0];
                if (nonWhitespaceStart.location == NSNotFound) return [super ks_writeHTML:adaptor];
            }
            
            // Ignore nodes which are naught but whitespace
            if ([data length] == 0) return [super ks_writeHTML:adaptor];
        }
    }
    
    
    [[adaptor XMLWriter] writeCharacters:data];
    return [super ks_writeHTML:adaptor];
}

- (DOMNode *)ks_writeHTML:(KSXMLWriterDOMAdaptor *)writer;
{
    DOMNode *result = [self writeData:[self data] toHTMLWriter:writer];
    return result;
}

- (void)ks_writeContent:(KSXMLWriterDOMAdaptor *)writer fromRange:(DOMRange *)range;
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


@implementation DOMComment (KSDOMToHTMLWriter)

- (DOMNode *)writeData:(NSString *)data toHTMLWriter:(KSXMLWriterDOMAdaptor *)adaptor;
{
    id <KSXMLWriterDOMAdaptorDelegate> delegate = adaptor.delegate;
    if ([delegate respondsToSelector:@selector(DOMAdaptor:willWriteDOMComment:)]) {
        DOMNode *node = [delegate DOMAdaptor:adaptor willWriteDOMComment:self];
        if (node != self) return node;
    }
    
    return [adaptor writeComment:data withDOMComment:self];
}

@end


@implementation DOMText (KSDOMToHTMLWriter)

- (DOMNode *)ks_writeHTML:(KSXMLWriterDOMAdaptor *)adaptor;
{
    DOMNode *result = [adaptor willWriteDOMText:self];
    if (result != self) return result;
    
    result = [super ks_writeHTML:adaptor];
    result = [adaptor didWriteDOMText:self nextNode:result];
    
    return result;
}

@end



@implementation DOMCDATASection (KSDOMToHTMLWriter)

- (DOMNode *)writeData:(NSString *)data toHTMLWriter:(KSXMLWriterDOMAdaptor *)adaptor;
{
    id <KSXMLWriterDOMAdaptorDelegate> delegate = adaptor.delegate;
    if ([delegate respondsToSelector:@selector(DOMAdaptor:willWriteDOMCDATASection:)]) {
        DOMNode *node = [delegate DOMAdaptor:adaptor willWriteDOMCDATASection:self];
        if (node != self) return node;
    }
    
	[[adaptor XMLWriter] writeString:[NSString stringWithFormat:@"<![CDATA[%@]]>", data]];
    return [self nextSibling];
}

@end
