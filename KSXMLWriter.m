//
//  KSXMLWriter.m
//  Sandvox
//
//  Created by Mike on 19/05/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSXMLWriter.h"

#import "KSStringXMLEntityEscaping.h"

#import "NSString+Karelia.h"


@implementation KSXMLWriter

#pragma mark Init & Dealloc

- (id)initWithOutputWriter:(id <KSWriter>)stream; // designated initializer
{
    [super init];
    
    _writer = [stream retain];
    _openElements = [[NSMutableArray alloc] init];
    
    return self;
}

- (id)init;
{
    return [self initWithOutputWriter:nil];
}

- (void)dealloc
{
    [self close];
    
    [_openElements release];
    OBASSERT(!_writer);
    
    [super dealloc];
}

#pragma mark Writer Status

- (void)close;
{
    [self flush];
    [_writer release]; _writer = nil;
}

- (void)flush; { }

#pragma mark Document

- (void)startDocument:(NSString *)DTD;  // at present, expect DTD to be complete tag
{
    [self writeString:DTD];
}

#pragma mark Elements

- (void)startElement:(NSString *)elementName attributes:(NSDictionary *)attributes;
{
    [self openTag:elementName];
    
    for (NSString *aName in attributes)
    {
        NSString *aValue = [attributes objectForKey:aName];
        [self writeAttribute:aName value:aValue];
    }
    
    [self didStartElement];
}

- (void)startElement:(NSString *)elementName
           attribute:(NSString *)attr
               value:(NSString *)attrValue;
{
    [self openTag:elementName];
    [self writeAttribute:attr value:attrValue];
    [self didStartElement];
}

- (void)endElement;
{
    // Handle whitespace
	[self decreaseIndentationLevel];
    if (![self isWritingInline]) [self startNewline];   // was this element written entirely inline?
    
    
    // Write the tag itself.
    if (_elementIsEmpty)
    {
        [self popElement];  // turn off _elementIsEmpty first or regular start tag will be written!
        [self closeEmptyElementTag];
    }
    else
    {
        [self writeEndTag:[self topElement]];
        [self popElement];
    }
}

#pragma mark High-level Writing

- (void)writeText:(NSString *)string;
{
    // Quotes are acceptable characters outside of attribute values
    NSString *html = [string stringByEscapingHTMLEntitiesWithQuot:NO];
    [self writeString:html];
}

- (void)startNewline;   // writes a newline character and the tabs to match -indentationLevel
{
    [self writeString:@"\n"];
    
    for (int i = 0; i < [self indentationLevel]; i++)
    {
        [self writeString:@"\t"];
    }
}

#pragma mark Comments

- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
{
    [self openComment];
    [self writeString:[comment stringByEscapingHTMLEntities]];
    [self closeComment];
}

- (void)openComment;
{
    [self writeString:@"<!--"];
}

- (void)closeComment;
{
    [self writeString:@"-->"];
}

#pragma mark Indentation

@synthesize indentationLevel = _indentation;

- (void)increaseIndentationLevel;
{
    [self setIndentationLevel:[self indentationLevel] + 1];
}

- (void)decreaseIndentationLevel;
{
    [self setIndentationLevel:[self indentationLevel] - 1];
}

#pragma mark Elements Stack

- (BOOL)canWriteElementInline:(NSString *)tagName;
{
    // In standard XML, no elements can be inline, unless it's the start of the doc
    return (_inlineWritingLevel == 0);
}

- (NSUInteger)openElementsCount;
{
    return [_openElements count];
}

- (BOOL)hasOpenElementWithTagName:(NSString *)tagName;
{
    // Seek an open element, matching case insensitively
    for (NSString *anElement in _openElements)
    {
        if ([anElement caseInsensitiveCompare:tagName] == NSOrderedSame)
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)topElement;
{
    return [_openElements lastObject];
}

- (void)pushElement:(NSString *)tagName;
{
    [_openElements addObject:tagName];
    [self startWritingInline];
}

- (void)popElement;
{
    _elementIsEmpty = NO;
    
    [_openElements removeLastObject];
    
    // Time to cancel inline writing?
    if (![self isWritingInline]) [self stopWritingInline];
}

#pragma mark Inline Writing

/*! How it works:
 *
 *  _inlineWritingLevel records the number of objects in the Elements Stack at the point inline writing began (-startWritingInline).
 *  A value of NSNotFound indicates that we are not writing inline (-stopWritingInline). This MUST be done whenever about to write non-inline content (-openTag: does so automatically).
 *  Finally, if _inlineWritingLevel is 0, this is a special value to indicate we're at the start of the document/section, so the next element to be written is inline, but then normal service shall resume.
 */

- (BOOL)isWritingInline;
{
    return ([self openElementsCount] >= _inlineWritingLevel);
}

- (void)startWritingInline;
{
    // Is it time to switch over to inline writing? (we may already be writing inline, so can ignore request)
    if (_inlineWritingLevel >= NSNotFound || _inlineWritingLevel == 0)
    {
        _inlineWritingLevel = [self openElementsCount];
    }
}

- (void)stopWritingInline; { _inlineWritingLevel = NSNotFound; }

#pragma mark Element Primitives

- (void)openTag:(NSString *)tagName;        //  <tagName
{
    // Can only write suitable tags inline if containing element also allows it
    if (![self canWriteElementInline:tagName])
    {
        [self startNewline];
        [self stopWritingInline];
    }
    
    tagName = [tagName lowercaseString];    // writes coming from the DOM are uppercase
    [self writeString:@"<"];
    [self writeString:tagName];
    
    // Must do this AFTER writing the string so subclasses can take early action in a -writeString: override
    [self pushElement:tagName];
}

- (void)writeAttribute:(NSString *)attribute
                 value:(NSString *)value;
{
    [self writeString:@" "];
    [self writeString:attribute];
    [self writeString:@"=\""];
    [self writeString:[value stringByEscapingHTMLEntitiesWithQuot:YES]];	// make sure to escape the quote mark
    [self writeString:@"\""];
}

- (void)didStartElement;
{
    _elementIsEmpty = YES;
}

- (void)closeStartTag;
{
    [self writeString:@">"];
    [self increaseIndentationLevel];
}

- (void)closeEmptyElementTag; { [self writeString:@" />"]; }

- (void)writeEndTag:(NSString *)tagName;    // primitive version that ignores open elements stack
{
    [self writeString:@"</"];
    [self writeString:tagName];
    [self writeString:@">"];
}

#pragma mark Primitive

- (void)writeString:(NSString *)string;
{
    // Is this string some element content? If so, the element is no longer empty so must close the tag and mark as such
    if (_elementIsEmpty && [string length])
    {
        _elementIsEmpty = NO;   // comes first to avoid infinte recursion
        [self closeStartTag];
    }
    
    [_writer writeString:string];
}

@end
