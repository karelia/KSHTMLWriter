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

- (id)initWithOutputWriter:(id <KSWriter>)output;
{
    [super initWithOutputWriter:output];
    
    _isXHTML = YES;
    _IDs = [[NSMutableSet alloc] init];
    _classNames = [[NSMutableArray alloc] init];
    
    return self;
}

- (id)initWithOutputWriter:(id <KSWriter>)output isXHTML:(BOOL)isXHTML;
{
    if (self = [self initWithOutputWriter:output])
    {
        _isXHTML = isXHTML;
    }
    
    return self;
}

- (void)dealloc
{
    [_IDs release];
    [_classNames release];
    
    [super dealloc];
}

#pragma mark XHTML

@synthesize XHTML = _isXHTML;

#pragma mark Document

- (void)startDocument:(NSString *)DTD encoding:(NSStringEncoding)encoding isXHTML:(BOOL)isXHTML;
{
    _isXHTML = isXHTML;
    [self startDocument:DTD encoding:encoding];
}

#pragma mark CSS Class Name

- (void)pushClassName:(NSString *)className;
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

- (void)pushAttribute:(NSString *)attribute value:(NSString *)value;
{
    if ([attribute isEqualToString:@"class"])
    {
        return [self pushClassName:value];
    }
    
    // Keep track of IDs in use
    if ([attribute isEqualToString:@"id"]) [_IDs addObject:value];
    [super pushAttribute:attribute value:value];
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
    if (idName) [self pushAttribute:@"id" value:idName];
    if (className) [self pushAttribute:@"class" value:className];
    
    [self startElement:tagName];
}

- (BOOL)isIDValid:(NSString *)anID; // NO if the ID has already been used
{
    BOOL result = ![_IDs containsObject:anID];
    return result;
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
	if (href) [self pushAttribute:@"href" value:href];
	if (targetString) [self pushAttribute:@"target" value:targetString];
	if (titleString) [self pushAttribute:@"title" value:titleString];
	if (relString) [self pushAttribute:@"rel" value:relString];
	
    [self startElement:@"a"];
}

- (void)writeImageWithSrc:(NSString *)src
                      alt:(NSString *)alt
                    width:(NSString *)width
                   height:(NSString *)height;
{
    [self pushAttribute:@"src" value:src];
    [self pushAttribute:@"alt" value:alt];
    if (width) [self pushAttribute:@"width" value:width];
    if (height) [self pushAttribute:@"height" value:height];
    
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
    if (rel) [self pushAttribute:@"rel" value:rel];
    if (!type) type = @"text/css";  [self pushAttribute:@"type" value:type];
    [self pushAttribute:@"href" value:href];
    if (title) [self pushAttribute:@"title" value:title];
    if (media) [self pushAttribute:@"media" value:media];
    
    [self startElement:@"link"];
    [self endElement];
}

- (void)writeLinkToStylesheet:(NSString *)href
                        title:(NSString *)title
                        media:(NSString *)media;
{
    [self writeLinkWithHref:href type:nil rel:@"stylesheet" title:title media:media];
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
    [self pushAttribute:@"type" value:@"text/javascript"]; // in theory, HTML5 pages could omit this
    if (src) [self pushAttribute:@"src" value:src];
    
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

#pragma mark Param

- (void)writeParamElementWithName:(NSString *)name value:(NSString *)value;
{
	if (name) [self pushAttribute:@"name" value:name];
	if (value) [self pushAttribute:@"value" value:value];
    [self startElement:@"param"];
    [self endElement];
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
    if (type) [self pushAttribute:@"type" value:type];
    [self startElement:@"style"];
}

#pragma mark Elements Stack

- (BOOL)topElementIsList;
{
    NSString *tagName = [self topElement];
    BOOL result = ([tagName isEqualToString:@"ul"] ||
                   [tagName isEqualToString:@"ol"]);
    return result;
}

#pragma mark (X)HTML

- (BOOL)elementCanBeEmpty:(NSString *)tagName;
{
    if ([tagName isEqualToString:@"br"] ||
        [tagName isEqualToString:@"img"] ||
        [tagName isEqualToString:@"hr"] ||
        [tagName isEqualToString:@"meta"] ||
        [tagName isEqualToString:@"link"] ||
        [tagName isEqualToString:@"input"] ||
        [tagName isEqualToString:@"base"] ||
        [tagName isEqualToString:@"basefont"] ||
        [tagName isEqualToString:@"param"] ||
        [tagName isEqualToString:@"area"] ||
        [tagName isEqualToString:@"source"]) return YES;
    
    return NO;
}

- (BOOL)canWriteElementInline:(NSString *)tagName;
{
    switch ([tagName length])
    {
        case 1:
            if ([tagName isEqualToString:@"a"] ||
                [tagName isEqualToString:@"b"] ||
                [tagName isEqualToString:@"i"]) return YES;
            break;
            
        case 2:
            if ([tagName isEqualToString:@"br"] ||
                [tagName isEqualToString:@"em"]) return YES;
            break;
            
        case 3:
            if ([tagName isEqualToString:@"img"] ||
                [tagName isEqualToString:@"sup"] ||
                [tagName isEqualToString:@"sub"] ||
                [tagName isEqualToString:@"big"]) return YES;
            break;
            
        case 4:
            if ([tagName isEqualToString:@"span"] ||
                [tagName isEqualToString:@"font"]) return YES;
            break;
            
        case 5:
            if ([tagName isEqualToString:@"small"]) return YES;
            break;
            
        case 6:
            if ([tagName isEqualToString:@"strong"]) return YES;
            break;
    }
    
    return [super canWriteElementInline:tagName];
}

#pragma mark Element Primitives

- (void)startElement:(NSString *)elementName writeInline:(BOOL)writeInline; // for more control
{
    NSAssert1([elementName isEqualToString:[elementName lowercaseString]], @"Attempt to start non-lowercase element: %@", elementName);
    
    
    // Add in any pre-written classes
    NSString *class = [self elementClassName];
    if (class)
    {
        [_classNames removeAllObjects];
        [super pushAttribute:@"class" value:class];
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

#pragma mark String Encoding

// NBSP is special -- for HTML, we usually want to encode it, for XML, no.
- (NSCharacterSet *)legalCharacterSet;
{
    NSMutableCharacterSet *result = [[[super legalCharacterSet] mutableCopy] autorelease];
	
	// Take out special characters which we ALWAYS want to escape
    [result removeCharactersInRange:NSMakeRange(160,1)];		// nbsp ... since they are hard to spot!
    
    return result;
}

@end
