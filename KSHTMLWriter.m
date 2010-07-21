//
//  KSHTMLWriter.m
//  Sandvox
//
//  Created by Mike on 23/02/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSHTMLWriter.h"


@implementation KSHTMLWriter

#pragma mark Creating an HTML Writer

- (id)initWithOutputWriter:(id <KSWriter>)stream;
{
    [super initWithOutputWriter:stream];
    _isXHTML = YES;
    return self;
}

- (id)initWithOutputWriter:(id <KSWriter>)stream isXHTML:(BOOL)isXHTML;
{
    if (self = [self initWithOutputWriter:stream])
    {
        _isXHTML = isXHTML;
    }
    
    return self;
}

#pragma mark XHTML

@synthesize XHTML = _isXHTML;

#pragma mark Document

- (void)startDocument:(NSString *)DTD isXHTML:(BOOL)isXHTML;
{
    _isXHTML = isXHTML;
    [self startDocument:DTD];
}

#pragma mark HTML Fragments

- (void)writeHTMLString:(NSString *)html;
{
    [self writeString:html];
}

- (void)writeHTMLFormat:(NSString *)format , ...
{
	va_list argList;
	va_start(argList, format);
	NSString *aString = [[[NSString alloc] initWithFormat:format arguments:argList] autorelease];
	va_end(argList);
	
    [self writeHTMLString:aString];
}

#pragma mark General

- (void)startElement:(NSString *)tagName;
{
    [self startElement:tagName className:nil];
}

- (void)startElement:(NSString *)tagName className:(NSString *)className;
{
    [self startElement:tagName idName:nil className:className];
}

- (void)startElement:(NSString *)tagName idName:(NSString *)idName className:(NSString *)className;
{
    [self openTag:tagName];
    if (idName) [self writeAttribute:@"id" value:idName];
    if (className) [self writeAttribute:@"class" value:className];
    [self didStartElement];
}

#pragma mark Line Break

- (void)writeLineBreak;
{
    [self startElement:@"br"];
    [self endElement];
}

#pragma mark Higher-level Tag Writing

- (void)startAnchorElementWithHref:(NSString *)href title:(NSString *)titleString target:(NSString *)targetString rel:(NSString *)relString;
{
	[self openTag:@"a"];
	if (href) [self writeAttribute:@"href" value:href];
	if (targetString) [self writeAttribute:@"target" value:targetString];
	if (titleString) [self writeAttribute:@"title" value:titleString];
	if (relString) [self writeAttribute:@"rel" value:relString];
	[self didStartElement];
}

- (void)writeImageWithIdName:(NSString *)idName
                   className:(NSString *)className
                         src:(NSString *)src
                         alt:(NSString *)alt
                       width:(NSString *)width
                      height:(NSString *)height;
{
    [self openTag:@"img"];
    
    if (idName) [self writeAttribute:@"id" value:idName];
    if (className) [self writeAttribute:@"class" value:className];
    
    [self writeAttribute:@"src" value:src];
    [self writeAttribute:@"alt" value:alt];
    if (width) [self writeAttribute:@"width" value:width];
    if (height) [self writeAttribute:@"height" value:height];
    
    [self didStartElement];
    [self endElement];
}

// TODO: disable indentation & newlines when we are in an anchor tag, somehow.

#pragma mark Link

- (void)writeLinkWithHref:(NSString *)href
                     type:(NSString *)type
                      rel:(NSString *)rel
                    title:(NSString *)title
                    media:(NSString *)media;
{
    [self openTag:@"link"];
    
    if (rel) [self writeAttribute:@"rel" value:rel];
    if (type) [self writeAttribute:@"type" value:type];
    [self writeAttribute:@"href" value:href];
    if (title) [self writeAttribute:@"title" value:title];
    if (media) [self writeAttribute:@"media" value:media];
    
    [self didStartElement];
    [self endElement];
}

- (void)writeLinkToStylesheet:(NSString *)href
                        title:(NSString *)title
                        media:(NSString *)media;
{
    [self writeLinkWithHref:href type:@"text/css" rel:@"stylesheet" title:title media:media];
}

#pragma mark Scripts

- (void)writeJavascriptWithSrc:(NSString *)src;
{
    [self openTag:@"script"];
    [self writeAttribute:@"type" value:@"text/javascript"]; // in theory, HTML5 pages could omit this
    [self writeAttribute:@"src" value:src];
    [self didStartElement];
    
    [self endElement];
}

- (void)startJavascriptCDATA;
{
    [self writeString:@"\n/* "];
    [self startCDATA];
    [self writeString:@" */"];
}

- (void)endJavascriptCDATA;
{
    [self writeString:@"\n/* "];
    [self endCDATA];
    [self writeString:@" */\n"];
}

- (void)writeScriptSrc:(NSString *)src			// Note: You should either use src OR contents, not both.
			orContents:(NSString *)contents	// However you can specify contents for comments, which is OK.
			  useCDATA:(BOOL)useCDATA;
{
    // Use clean API when possible…
    if (src && !contents) return [self writeJavascriptWithSrc:src];
    
    
    // …otherwise bodge it:
    
    [self openTag:@"script"];
    
    [self writeAttribute:@"type" value:@"text/javascript"];
    if (src) [self writeAttribute:@"src" value:src];
    [self didStartElement];
    if (contents)
	{
		// DO NOT USE startNewline since we don't want indentation
        if (useCDATA) [self startJavascriptCDATA];
        
        [self writeString:@"\n"];
		[self writeString:contents];
		[self writeString:@"\n"];
        
        if (useCDATA) [self endJavascriptCDATA];
	}
    
    [self endElement];
}

#pragma mark Style

- (void)startStyleElementWithType:(NSString *)type;
{
    [self openTag:@"style"];
    if (type) [self writeAttribute:@"type" value:type];
    [self didStartElement];
}

#pragma mark Elements Stack

- (BOOL)topElementIsList;
{
    NSString *tagName = [self topElement];
    BOOL result = [tagName isEqualToString:@"UL"] || [tagName isEqualToString:@"OL"];
    return result;
}

#pragma mark (X)HTML

- (BOOL)elementCanBeEmpty:(NSString *)tagName;
{
    if ([tagName caseInsensitiveCompare:@"BR"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"IMG"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"HR"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"META"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"LINK"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"INPUT"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"BASE"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"BASEFONT"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"PARAM"] == NSOrderedSame ||
        [tagName caseInsensitiveCompare:@"AREA"] == NSOrderedSame) return YES;
    
    return NO;
}

- (BOOL)canWriteElementInline:(NSString *)tagName;
{
    switch ([tagName length])
    {
        case 1:
            if ([tagName caseInsensitiveCompare:@"A"] == NSOrderedSame ||
                [tagName caseInsensitiveCompare:@"B"] == NSOrderedSame ||
                [tagName caseInsensitiveCompare:@"I"] == NSOrderedSame) return YES;
            break;
            
        case 2:
            if ([tagName caseInsensitiveCompare:@"BR"] == NSOrderedSame ||
                [tagName caseInsensitiveCompare:@"EM"] == NSOrderedSame) return YES;
            break;
            
        case 3:
            if ([tagName caseInsensitiveCompare:@"IMG"] == NSOrderedSame ||
                [tagName caseInsensitiveCompare:@"SUP"] == NSOrderedSame ||
                [tagName caseInsensitiveCompare:@"SUB"] == NSOrderedSame ||
                [tagName caseInsensitiveCompare:@"BIG"] == NSOrderedSame) return YES;
            break;
            
        case 4:
            if ([tagName caseInsensitiveCompare:@"SPAN"] == NSOrderedSame ||
                [tagName caseInsensitiveCompare:@"FONT"] == NSOrderedSame) return YES;
            break;
            
        case 5:
            if ([tagName caseInsensitiveCompare:@"SMALL"] == NSOrderedSame) return YES;
            break;
            
        case 6:
            if ([tagName caseInsensitiveCompare:@"STRONG"] == NSOrderedSame) return YES;
            break;
    }
    
    return [super canWriteElementInline:tagName];
}

#pragma mark Element Primitives

- (void)closeEmptyElementTag;               //   />    OR    >    depending on -isXHTML
{
    if ([self isXHTML])
    {
        [super closeEmptyElementTag];
    }
    else
    {
        [self writeString:@">"];
    }
}

@end
