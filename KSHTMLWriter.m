//
//  KSHTMLWriter.m
//
//  Copyright 2010-2012, Mike Abdullah and Karelia Software
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


#import "KSHTMLWriter.h"

#import "KSXMLAttributes.h"


NSString *KSHTMLWriterDocTypeHTML_4_01_Strict = @"HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\"";
NSString *KSHTMLWriterDocTypeHTML_4_01_Transitional = @"HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\"";
NSString *KSHTMLWriterDocTypeHTML_4_01_Frameset = @"HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\"";
NSString *KSHTMLWriterDocTypeXHTML_1_0_Strict = @"html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"";
NSString *KSHTMLWriterDocTypeXHTML_1_0_Transitional = @"html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"";
NSString *KSHTMLWriterDocTypeXHTML_1_0_Frameset = @"html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\"";
NSString *KSHTMLWriterDocTypeXHTML_1_1 = @"html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\"";
NSString *KSHTMLWriterDocTypeHTML_5 = @"html";


@interface KSHTMLWriter ()
@property(nonatomic, copy, readwrite) NSString *docType;
@end


@implementation KSHTMLWriter

#pragma mark Creating an HTML Writer

- (id)initWithOutputWriter:(id <KSWriter>)output;
{
    if (self = [super initWithOutputWriter:output])
    {
        [self setDocType:KSHTMLWriterDocTypeHTML_5];
        _IDs = [[NSMutableSet alloc] init];
        _classNames = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithOutputWriter:(id <KSWriter>)output docType:(NSString *)docType encoding:(NSStringEncoding)encoding;
{
    if (self = [self initWithOutputWriter:output encoding:encoding])
    {
        [self setDocType:docType];
    }
    
    return self;
}

- (void)dealloc
{
    [_IDs release];
    [_classNames release];
    
    [super dealloc];
}

#pragma mark DTD

- (void)startDocumentWithDocType:(NSString *)docType encoding:(NSStringEncoding)encoding;
{
    [self setDocType:docType];
    [super startDocumentWithDocType:docType encoding:encoding];
}

@synthesize docType = _docType;
- (void)setDocType:(NSString *)docType;
{
    docType = [docType copy];
    [_docType release]; _docType = docType;
    
    _isXHTML = [[self class] isDocTypeXHTML:docType];
}

- (BOOL)isXHTML; { return _isXHTML; }

+ (BOOL)isDocTypeXHTML:(NSString *)docType;
{
    BOOL result = !([docType isEqualToString:KSHTMLWriterDocTypeHTML_4_01_Strict] ||
                    [docType isEqualToString:KSHTMLWriterDocTypeHTML_4_01_Transitional] ||
                    [docType isEqualToString:KSHTMLWriterDocTypeHTML_4_01_Frameset]);
    return result;
}

#pragma mark CSS Class Name

- (NSString *)currentElementClassName;
{
    NSString *result = nil;
    if ([_classNames count])
    {
        result = [_classNames componentsJoinedByString:@" "];
    }
    return result;
}

- (void)pushClassName:(NSString *)className;
{
#ifdef DEBUG
    if ([_classNames containsObject:className])
    {
        NSLog(@"Adding class \"%@\" to an element twice", className);
    }
#endif
    
    [_classNames addObject:className];
}

- (void)pushClassNames:(NSArray *)classNames;
{
    // TODO: Check for duplicates while debugging
    [_classNames addObjectsFromArray:classNames];
}

- (void)pushAttribute:(NSString *)attribute value:(id)value;
{
    if ([attribute isEqualToString:@"class"])
    {
        return [self pushClassName:value];
    }
    
    // Keep track of IDs in use
    if ([attribute isEqualToString:@"id"]) [_IDs addObject:value];
    [super pushAttribute:attribute value:value];
}

- (KSXMLAttributes *)currentAttributes;
{
    KSXMLAttributes *result = [super currentAttributes];
    
    // Add in buffered class info
    NSString *class = [self currentElementClassName];
    if (class) [result addAttribute:@"class" value:class];
    
    return result;
}

- (BOOL)hasCurrentAttributes;
{
    return ([super hasCurrentAttributes] || [_classNames count]);
}

#pragma mark HTML Fragments

- (void)writeHTMLString:(NSString *)html withTerminatingNewline:(BOOL)terminatingNewline;
{
    if (terminatingNewline)
    {
        if (![html hasSuffix:@"\n"]) html = [html stringByAppendingString:@"\n"];
    }
    else
    {
        if ([html hasSuffix:@"\n"]) html = [html substringToIndex:[html length] - 1];
    }
    
    [self writeHTMLString:html];
}

- (void)writeHTMLString:(NSString *)html;
{
    NSUInteger indent = [self indentationLevel];
    if (indent)
    {
        NSString *indentedNewline = [@"\n" stringByPaddingToLength:indent + 1
                                                        withString:@"\t"
                                                   startingAtIndex:0];
        
        html = [html stringByReplacingOccurrencesOfString:@"\n" withString:indentedNewline];
    }
    
    [self writeString:html];
}

#pragma mark General

- (void)writeElement:(NSString *)name idName:(NSString *)idName className:(NSString *)className content:(void (^)(void))content;
{
    if (idName) [self pushAttribute:@"id" value:idName];
    if (className) [self pushAttribute:@"class" value:className];
    
    [self writeElement:name content:content];
}

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

#pragma mark Anchors

- (void)startAnchorElementWithHref:(NSString *)href title:(NSString *)titleString target:(NSString *)targetString rel:(NSString *)relString;
{
    // TODO: Remove this method once Sandvox no longer needs it
	if (href) [self pushAttribute:@"href" value:href];
	if (targetString) [self pushAttribute:@"target" value:targetString];
	if (titleString) [self pushAttribute:@"title" value:titleString];
	if (relString) [self pushAttribute:@"rel" value:relString];
	
    [self startElement:@"a"];
}

- (void)writeAnchorElementWithHref:(NSString *)href title:(NSString *)titleString target:(NSString *)targetString rel:(NSString *)relString content:(void (^)(void))content;
{
    NSParameterAssert(content);
    
    [self startAnchorElementWithHref:href title:titleString target:targetString rel:relString];
    content();
    [self endElement];
}

#pragma mark Images

- (void)writeImageWithSrc:(NSString *)src
                      alt:(NSString *)alt
                    width:(id)width
                   height:(id)height;
{
    [self pushAttribute:@"src" value:src];
    [self pushAttribute:@"alt" value:alt];
    if (width) [self pushAttribute:@"width" value:width];
    if (height) [self pushAttribute:@"height" value:height];
    
    [self startElement:@"img"];
    [self endElement];
}

#pragma mark Link

- (void)writeLinkWithHref:(NSString *)href
                     type:(NSString *)type
                      rel:(NSString *)rel
                    title:(NSString *)title
                    media:(NSString *)media;
{
    if (rel) [self pushAttribute:@"rel" value:rel];
    if (type) [self pushAttribute:@"type" value:type];
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
    [self writeLinkWithHref:href type:@"text/css" rel:@"stylesheet" title:title media:media];
}

#pragma mark Scripts

- (void)writeJavascriptWithSrc:(NSString *)src encoding:(NSStringEncoding)encoding;
{
    // According to the HTML spec, charset only needs to be specified if the script is a different encoding to the document
    NSString *charset = nil;
    if (encoding != [self encoding])
    {
        charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(encoding));
    }
    
    [self writeJavascriptWithSrc:src charset:charset];
}

- (void)writeJavascriptWithSrc:(NSString *)src charset:(NSString *)charset;	// src may be nil
{    
    if (charset) [self pushAttribute:@"charset" value:charset];
    [self startJavascriptElementWithSrc:src];
    [self endElement];
}

- (void)writeJavascript:(NSString *)script useCDATA:(BOOL)useCDATA;
{
    [self startJavascriptElementWithSrc:nil];
    {{
        if (useCDATA) [self startJavascriptCDATA];
        [self writeHTMLString:script];
        if (useCDATA) [self endJavascriptCDATA];
        
        [self increaseIndentationLevel];    // compensate for -decreaseIndentationLevel
    }}
    [self endElement];
}

- (void)startJavascriptElementWithSrc:(NSString *)src;  // src may be nil
{
    // HTML5 doesn't need the script type specified, but older doc types do for standards-compliance
    if (![[self docType] isEqualToString:KSHTMLWriterDocTypeHTML_5])
    {
        [self pushAttribute:@"type" value:@"text/javascript"];
    }
    
    // Script
    if (src)
	{
		[self pushAttribute:@"src" value:src];
        [self startElement:@"script"];
	}
    else
    {
        // Embedded scripts should start on their own line for clarity
        // Outdent the script comapred to wha'ts normal
        [self startElement:@"script" writeInline:NO];
        
        if (!src)
        {
            [self decreaseIndentationLevel];
            [self startNewline];
            [self stopWritingInline];
        }
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

- (BOOL)hasListOpen;
{
    return ([self hasOpenElement:@"ul"] || [self hasOpenElement:@"ol"]);
}

- (BOOL)topElementIsList;
{
    return [[self class] elementIsList:[self topElement]];
}

+ (BOOL)elementIsList:(NSString *)element;
{
    BOOL result = ([element isEqualToString:@"ul"] ||
                   [element isEqualToString:@"ol"]);
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

+ (BOOL)shouldPrettyPrintElementInline:(NSString *)elementName;
{
    switch ([elementName length])
    {
        case 1:
            if ([elementName isEqualToString:@"a"] ||
                [elementName isEqualToString:@"b"] ||
                [elementName isEqualToString:@"i"] ||
                [elementName isEqualToString:@"s"] ||
                [elementName isEqualToString:@"u"] ||
                [elementName isEqualToString:@"q"]) return YES;
            break;
            
        case 2:
            if ([elementName isEqualToString:@"br"] ||
                [elementName isEqualToString:@"em"] ||
                [elementName isEqualToString:@"tt"]) return YES;
            break;
            
        case 3:
            if ([elementName isEqualToString:@"img"] ||
                [elementName isEqualToString:@"sup"] ||
                [elementName isEqualToString:@"sub"] ||
                [elementName isEqualToString:@"big"] ||
                [elementName isEqualToString:@"del"] ||
                [elementName isEqualToString:@"ins"] ||
                [elementName isEqualToString:@"dfn"] ||
                [elementName isEqualToString:@"map"] ||
                [elementName isEqualToString:@"var"] ||
                [elementName isEqualToString:@"bdo"] ||
                [elementName isEqualToString:@"kbd"]) return YES;
            break;
            
        case 4:
            if ([elementName isEqualToString:@"span"] ||
                [elementName isEqualToString:@"font"] ||
                [elementName isEqualToString:@"abbr"] ||
                [elementName isEqualToString:@"cite"] ||
                [elementName isEqualToString:@"code"] ||
                [elementName isEqualToString:@"samp"]) return YES;
            break;
            
        case 5:
            if ([elementName isEqualToString:@"small"] ||
                [elementName isEqualToString:@"input"] ||
                [elementName isEqualToString:@"label"]) return YES;
            break;
            
        case 6:
            if ([elementName isEqualToString:@"strong"] ||
                [elementName isEqualToString:@"select"] ||
                [elementName isEqualToString:@"button"] ||
                [elementName isEqualToString:@"object"] ||
                [elementName isEqualToString:@"applet"] ||
                [elementName isEqualToString:@"script"] ||
                [elementName isEqualToString:@"strike"]) return YES;
            break;
            
        case 7:
            if ([elementName isEqualToString:@"acronym"]) return YES;
            break;
            
        case 8:
            if ([elementName isEqualToString:@"textarea"]) return YES;
            break;
    }
    
    return [super shouldPrettyPrintElementInline:elementName];
}

- (BOOL)validateElement:(NSString *)element;
{
    if (![super validateElement:element]) return NO;
    
    // Lists can only contain list items
    if ([self topElementIsList])
    {
        return [element isEqualToString:@"li"];
    }
    else
    {
        return YES;
    }
}

- (NSString *)validateAttribute:(NSString *)name value:(NSString *)value ofElement:(NSString *)element;
{
    NSString *result = [super validateAttribute:name value:value ofElement:element];
    if (!result) return nil;
    
    // value is only allowed as a list item attribute when in an ordered list
    if ([element isEqualToString:@"li"] && [name isEqualToString:@"value"])
    {
        if (![[self topElement] isEqualToString:@"ol"]) result = nil;
    }
    
    return result;
}

#pragma mark Element Primitives

- (void)startElement:(NSString *)elementName writeInline:(BOOL)writeInline; // for more control
{
    NSAssert1([elementName isEqualToString:[elementName lowercaseString]], @"Attempt to start non-lowercase element: %@", elementName);
    
    
    // Add in any pre-written classes
    NSString *class = [self currentElementClassName];
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

@end
