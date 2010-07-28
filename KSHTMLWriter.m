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
    _classNames = [[NSMutableArray alloc] init];
    
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

- (void)dealloc
{
    [_classNames release];
    
    [super dealloc];
}

#pragma mark XHTML

@synthesize XHTML = _isXHTML;

#pragma mark Document

- (void)startDocument:(NSString *)DTD isXHTML:(BOOL)isXHTML;
{
    _isXHTML = isXHTML;
    [self startDocument:DTD];
}

#pragma mark CSS Class Name

- (void)pushElementClassName:(NSString *)className;
{
    [_classNames addObject:className];
}

- (NSString *)elementClassName;
{
    NSString *result = nil;
    if ([_classNames count])
    {
        result = [_classNames componentsJoinedByString:@" "];
    }
    return result;
}

- (void)pushElementAttribute:(NSString *)attribute value:(NSString *)value;
{
    if ([attribute isEqualToString:@"class"])
    {
        [self pushElementClassName:value];
    }
    else
    {
        [super pushElementAttribute:attribute value:value];
    }
}

- (NSDictionary *)elementAttributes;
{
    id result = [super elementAttributes];
    
    NSString *class = [self elementClassName];
    if (class)
    {
        result = [NSMutableDictionary dictionaryWithDictionary:result];
        [result setObject:class forKey:@"class"];
    }
    
    return result;
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

- (void)startElement:(NSString *)tagName className:(NSString *)className;
{
    [self startElement:tagName idName:nil className:className];
}

- (void)startElement:(NSString *)tagName idName:(NSString *)idName className:(NSString *)className;
{
    if (idName) [self pushElementAttribute:@"id" value:idName];
    if (className) [self pushElementAttribute:@"class" value:className];
    
    [self startElement:tagName];
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
	if (href) [self pushElementAttribute:@"href" value:href];
	if (targetString) [self pushElementAttribute:@"target" value:targetString];
	if (titleString) [self pushElementAttribute:@"title" value:titleString];
	if (relString) [self pushElementAttribute:@"rel" value:relString];
	
    [self startElement:@"a"];
}

- (void)writeImageWithIdName:(NSString *)idName
                   className:(NSString *)className
                         src:(NSString *)src
                         alt:(NSString *)alt
                       width:(NSString *)width
                      height:(NSString *)height;
{
    
    if (idName) [self pushElementAttribute:@"id" value:idName];
    if (className) [self pushElementAttribute:@"class" value:className];
    
    [self pushElementAttribute:@"src" value:src];
    [self pushElementAttribute:@"alt" value:alt];
    if (width) [self pushElementAttribute:@"width" value:width];
    if (height) [self pushElementAttribute:@"height" value:height];
    
    [self startElement:@"img"];
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
    if (rel) [self pushElementAttribute:@"rel" value:rel];
    if (type) [self pushElementAttribute:@"type" value:type];
    [self pushElementAttribute:@"href" value:href];
    if (title) [self pushElementAttribute:@"title" value:title];
    if (media) [self pushElementAttribute:@"media" value:media];
    
    [self startElement:@"link"];
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
    NSParameterAssert(src);
    
    [self startJavascriptElementWithSrc:src];
    [self endElement];
}

- (void)writeJavascript:(NSString *)script useCDATA:(BOOL)useCDATA;
{
    [self startJavascriptElementWithSrc:nil];
    
    if (useCDATA) [self startJavascriptCDATA];
    [self writeString:script];
    if (useCDATA) [self endJavascriptCDATA];
    
    [self endElement];
}

- (void)startJavascriptElementWithSrc:(NSString *)src;  // src may be nil
{
    [self pushElementAttribute:@"type" value:@"text/javascript"]; // in theory, HTML5 pages could omit this
    if (src) [self pushElementAttribute:@"src" value:src];
    
    [self startElement:@"script"];
    
    // Embedded scripts should start on their own line for clarity
    if (!src)
    {
        [self writeString:@"\n"];
        [self stopWritingInline];
    }
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

#pragma mark Style

- (void)writeStyleElementWithCSSString:(NSString *)css;
{
    [self startStyleElementWithType:@"text/css"];
    [self writeString:css]; // browsers don't expect styles to be XML escaped
    [self endElement];
}

- (void)startStyleElementWithType:(NSString *)type;
{
    if (type) [self pushElementAttribute:@"type" value:type];
    [self startElement:@"style"];
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

- (void)startElement:(NSString *)elementName writeInline:(BOOL)writeInline; // for more control
{
    // Add in any pre-written classes
    NSString *class = [self elementClassName];
    if (class)
    {
        [_classNames removeAllObjects];
        [super pushElementAttribute:@"class" value:class];
    }
    
    [super startElement:elementName writeInline:writeInline];
}

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
