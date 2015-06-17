//
//  KSXMLWriter.m
//
//  Created by Mike Abdullah
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

#import "KSXMLWriter.h"


@interface KSXMLWriter ()

#pragma mark Element Primitives

//   attribute="value"
- (void)writeAttribute:(NSString *)attribute
                 value:(id)value;

//  Starts tracking -writeString: calls to see if element is empty
- (void)didStartElement;

//  >
//  Then increases indentation level
- (void)closeStartTag;

//   />
- (void)closeEmptyElementTag;             

- (void)writeEndTag:(NSString *)tagName;    // primitive version that ignores open elements stack

- (BOOL)elementCanBeEmpty:(NSString *)tagName;  // YES for everything in pure XML

@end


@interface KSXMLAttributes (KSXMLWriter)
- (void)writeAttributes:(KSXMLWriter *)writer;
@end


#pragma mark -


@implementation KSXMLWriter

#pragma mark Init & Dealloc

- (id)initWithOutputWriter:(KSWriter *)output {
    if (self = [super init])
    {
        _outputWriter = [output retain];
        
        _encoding = (output ? output.encoding : NSUTF8StringEncoding);
        if (![[self class] isStringEncodingAvailable:_encoding])
        {
            CFStringRef encodingName = CFStringGetNameOfEncoding(CFStringConvertNSStringEncodingToEncoding(_encoding));
            
            [NSException raise:NSInvalidArgumentException
                        format:@"Unsupported character encoding %@ (%lu)", encodingName, (unsigned long) _encoding];
        }
        
        _attributes = [[KSXMLAttributes alloc] init];
        _openElements = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)init; { return [self initWithOutputWriter:nil]; }

- (void)dealloc
{
    [self close];
    
    [_openElements release];
    [_attributes release];
    [_doctype release];
    
    [super dealloc];
}

#pragma mark Writer Status

- (void)close;
{
    [self flush];
    
    [_outputWriter release]; _outputWriter = nil;
}

- (void)flush; { }

#pragma mark Document

- (void)writeDoctypeDeclaration
{
    [self writeString:@"<!DOCTYPE "];
    [self writeString:self.doctype];
    [self writeString:@">"];
    [self startNewline];
}

#pragma mark Characters

- (void)writeCharacters:(NSString *)string;
{
    // Quotes are acceptable characters outside of attribute values
    [self.class writeString:string escapeXMLEntitiesIncludingQuotes:NO usingBlock:^(NSString *string, NSRange range) {
        [self writeString:string range:range];
    }];
}

+ (NSString *)stringFromCharacters:(NSString *)characters;
{
	__block NSString *result = @"";
    
    [self.class writeString:characters escapeXMLEntitiesIncludingQuotes:NO usingBlock:^(NSString *string, NSRange range) {
        
        // Often the original string is valid. If so, use it whole
        if (string == characters && range.length == characters.length)
        {
            result = characters;
        }
        else
        {
            if (range.length != string.length) string = [string substringWithRange:range];
            result = [result stringByAppendingString:string];
        }
    }];
    
    return result;
}

#pragma mark Elements

- (void)writeElement:(NSString *)name content:(void (^)(void))content;
{
    [self startElement:name];
    if (content) content();
    [self endElement];
}

- (void)writeElement:(NSString *)name attributes:(NSDictionary *)attributes content:(void (^)(void))content;
{
    for (NSString *aName in attributes)
    {
        NSString *aValue = [attributes objectForKey:aName];
        [self pushAttribute:aName value:aValue];
    }
    
    [self writeElement:name content:content];
}

- (void)writeElement:(NSString *)elementName text:(NSString *)text;
{
    [self writeElement:elementName content:^{
        [self writeCharacters:text];
    }];
}

- (void)willStartElement:(NSString *)element; { /* for subclassers */ }

- (void)pushElement:(NSString *)element;
{
    // Private method so that Sandvox can work for now
    [_openElements addObject:element];
}

- (void)popElement;
{
    _elementIsEmpty = NO;
    
    [_openElements removeLastObject];
    
    // Time to cancel inline writing?
    if (![self isWritingInline]) [self stopWritingInline];
}

#pragma mark Current Element

- (void)pushAttribute:(NSString *)attribute value:(id)value; // call before -startElement:
{
    [_attributes addAttribute:attribute value:value];
}

- (KSXMLAttributes *)currentAttributes;
{
    KSXMLAttributes *result = [[_attributes copy] autorelease];
    return result;
}

- (BOOL)hasCurrentAttributes;
{
    return [_attributes count];
}

#pragma mark Attributes

- (void)writeAttributeValue:(NSString *)value;
{
    // Make sure to escape the quote mark
    [self.class writeString:value escapeXMLEntitiesIncludingQuotes:YES usingBlock:^(NSString *string, NSRange range) {
        [self writeString:string range:range];
    }];
}

+ (NSString *)stringFromAttributeValue:(NSString *)value;
{
    __block NSString *result = @"";
    
    [self.class writeString:value escapeXMLEntitiesIncludingQuotes:YES usingBlock:^(NSString *string, NSRange range) {
        
        // Often the original string is valid. If so, use it whole
        if (string == value && range.length == value.length)
        {
            result = value;
        }
        else
        {
            if (range.length != string.length) string = [string substringWithRange:range];
            result = [result stringByAppendingString:string];
        }
    }];
    
    return result;
}

- (void)writeAttribute:(NSString *)attribute
                 value:(id)value;
{
	NSString *valueString = [value description];
	
    [self writeString:@" "];
    [self writeString:attribute];
    [self writeString:@"=\""];
    [self writeAttributeValue:valueString];
    [self writeString:@"\""];
}

#pragma mark Whitespace

- (void)startNewline;   // writes a newline character and the tabs to match -indentationLevel
{
    [self writeString:@"\n"];
    
    NSInteger indentationLevel = [self indentationLevel];
	if (indentationLevel < 0)
	{
		NSLog(@"KSXMLWriter: Negative Indentation Level!");
		indentationLevel = 0;    // prevent accidental overruns if negative
	}
	for (NSUInteger i = 0; i < indentationLevel; i++)
    {
        [self writeString:@"\t"];
    }
}

#pragma mark Comments

- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
{
    [self openComment];
    [self writeAttributeValue:comment];
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

#pragma mark CDATA

- (void)writeCDATAWithContentBlock:(void (^)(void))content;
{
    [self startCDATA];
    content();
    [self endCDATA];
}

#pragma mark Indentation

- (void)increaseIndentationLevel;
{
    self.indentationLevel++;
}

- (void)decreaseIndentationLevel;
{
    if ([self indentationLevel] > 0) {
        self.indentationLevel--;
    }
    else {
        NSLog(@"Ignoring attempt to decrease indentation level when already at 0");
    }
}

#pragma mark Validation

- (BOOL)validateElement:(NSString *)element;
{
    NSParameterAssert(element);
    return YES;
}

- (NSString *)validateAttribute:(NSString *)name value:(NSString *)value ofElement:(NSString *)element;
{
    NSParameterAssert(name);
    NSParameterAssert(element);
    return value;
}

#pragma mark Elements Stack

- (BOOL)canWriteElementInline:(NSString *)element;
{
    // In standard XML, no elements can be inline, unless it's the start of the doc
    return (_inlineWritingLevel == 0 || [[self class] shouldPrettyPrintElementInline:element]);
}

+ (BOOL)shouldPrettyPrintElementInline:(NSString *)element;
{
    return NO;
}

- (NSArray *)openElements; { return [[_openElements copy] autorelease]; }

- (NSUInteger)openElementsCount;
{
    return [_openElements count];
}

- (BOOL)hasOpenElement:(NSString *)tagName;
{
    // Seek an open element, matching case insensitively
    for (NSString *anElement in _openElements)
    {
        if ([anElement isEqualToString:tagName])
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

#pragma mark Element Primitives

- (void)didStartElement;
{
    // For elements which can't be empty, might as well go ahead and close the start tag now
    _elementIsEmpty = [self elementCanBeEmpty:[self topElement]];
    if (!_elementIsEmpty) [self closeStartTag];
}

- (void)closeStartTag;
{
    [self writeString:@">"];
}

- (void)closeEmptyElementTag; { [self writeString:@" />"]; }

- (void)writeEndTag:(NSString *)tagName;    // primitive version that ignores open elements stack
{
    [self writeString:@"</"];
    [self writeString:tagName];
    [self writeString:@">"];
}

- (BOOL)elementCanBeEmpty:(NSString *)tagName; { return YES; }

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

static NSCharacterSet *sCharactersToEntityEscapeWithQuot;
static NSCharacterSet *sCharactersToEntityEscapeWithoutQuot;

+ (void)initialize
{
    // Cache the characters to be escaped. Doing it in +initialize should be threadsafe
	if (!sCharactersToEntityEscapeWithQuot)
    {
        // Don't want to escape apostrophes for HTML, but do for Javascript
        sCharactersToEntityEscapeWithQuot = [[NSCharacterSet characterSetWithCharactersInString:@"&<>\""] retain];
    }
    if (!sCharactersToEntityEscapeWithoutQuot)
    {
        sCharactersToEntityEscapeWithoutQuot = [[NSCharacterSet characterSetWithCharactersInString:@"&<>"] retain];
    }
}

/*!	Escape & < > " ... does NOT escape anything else.  Need to deal with character set in subsequent pass.
 Escaping " so that strings work within HTML tags
 */

// Explicitly escape, or don't escape, double-quots as &quot;
// Within a tag like <foo attribute="%@"> then we have to escape it.
// In just about all other contexts it's OK to NOT escape it, but many contexts we don't know if it's OK or not.
// So I think we want to gradually shift over to being explicit when we know when it's OK or not.
//
// Return value indicates whether any escaping actually needed doing
+ (void)writeString:(NSString *)string escapeXMLEntitiesIncludingQuotes:(BOOL)escapeQuotes usingBlock:(void (^)(NSString *string, NSRange range))block;
{
    NSCharacterSet *charactersToEntityEscape = (escapeQuotes ?
                                                sCharactersToEntityEscapeWithQuot :
                                                sCharactersToEntityEscapeWithoutQuot);
    
    // Look for characters to escape. If there are none can bail out quick without having had to allocate anything. #78710
    NSRange searchRange = NSMakeRange(0, [string length]);
    NSRange range = [string rangeOfCharacterFromSet:charactersToEntityEscape options:0 range:searchRange];
    if (range.location == NSNotFound)
    {
        block(string, searchRange);
        return;
    }
    
    
    while (searchRange.length)
	{
        // Write characters not needing to be escaped. Don't bother if there aren't any
		NSRange unescapedRange = searchRange;
        if (range.location != NSNotFound)
        {
            unescapedRange.length = range.location - searchRange.location;
        }
        if (unescapedRange.length)
        {
            block(string, unescapedRange);
        }
        
        
		// Process characters that need escaping
		if (range.location != NSNotFound)
        {            
            NSAssert(range.length == 1, @"trying to escaping non-single character string");    // that's all we should deal with for HTML escaping
			
            unichar ch = [string characterAtIndex:range.location];
            NSString *escaped;
            switch (ch)
            {
                case '&':	escaped = @"&amp;";     break;
                case '<':	escaped = @"&lt;";      break;
                case '>':	escaped = @"&gt;";      break;
                case '"':   escaped = @"&quot;";    break;
                default:    escaped = [NSString stringWithFormat:@"&#%d;",ch];
            }
            
            block(escaped, NSMakeRange(0, escaped.length));
		}
        else
        {
            break;  // no escapable characters were found so we must be done
        }
        
        
        // Continue the search
        searchRange.location = NSMaxRange(range);
        searchRange.length = [string length] - searchRange.location;
        range = [string rangeOfCharacterFromSet:charactersToEntityEscape options:0 range:searchRange];
	}
}

#pragma mark String Encoding

+ (BOOL)isStringEncodingAvailable:(NSStringEncoding)encoding;
{
    return (encoding == NSASCIIStringEncoding ||
            encoding == NSUTF8StringEncoding ||
			encoding == NSISOLatin1StringEncoding ||
			encoding == NSWindowsCP1251StringEncoding ||
			encoding == NSUnicodeStringEncoding);
}

- (void)writeString:(NSString *)string range:(NSRange)nsrange;
{
	NSParameterAssert(nil != string); 
    // Is this string some element content? If so, the element is no longer empty so must close the tag and mark as such
    if (_elementIsEmpty && [string length])
    {
        _elementIsEmpty = NO;   // comes first to avoid infinte recursion
        [self closeStartTag];
    }
    
    
    CFRange range = CFRangeMake(nsrange.location, nsrange.length);
    
    while (range.length)
    {
        CFIndex written = CFStringGetBytes((CFStringRef)string,
                                           range,
                                           CFStringConvertNSStringEncodingToEncoding([self encoding]),
                                           0,                   // don't convert invalid characters
                                           false,
                                           NULL,                // not interested in actually getting the bytes
                                           0,
                                           NULL);
        
        if (written < range.length) // there was an invalid character
        {
            // Write what is valid
            if (written)
            {
                NSRange validRange = NSMakeRange(range.location, written);
                [_outputWriter writeString:string range:validRange];
            }
            
            // Convert the invalid char
            unichar ch = [string characterAtIndex:(range.location + written)];
            switch (ch)
            {
                    // If we encounter a special character with a symbolic entity, use that
                case 160:	[_outputWriter writeString:@"&nbsp;"];      break;
                case 169:	[_outputWriter writeString:@"&copy;"];      break;
                case 174:	[_outputWriter writeString:@"&reg;"];       break;
                case 8211:	[_outputWriter writeString:@"&ndash;"];     break;
                case 8212:	[_outputWriter writeString:@"&mdash;"];     break;
                case 8364:	[_outputWriter writeString:@"&euro;"];      break;
                    
                    // Otherwise, use the decimal unicode value.
                default:
				{
					NSString *escaped = [NSString stringWithFormat:@"&#%d;",ch];
					[_outputWriter writeString:escaped];   break;
				}
            }
            
            // Convert the rest
            NSUInteger increment = written + 1;
            range.location += increment; range.length -= increment;
        }
        else if (range.location == 0)
        {
            // Efficient route for if entire string can be written
            [_outputWriter writeString:string range:nsrange];
            break;
        }
        else
        {
            // Write what remains
            [_outputWriter writeString:string range:NSMakeRange(range.location, range.length)];
            break;
        }
    }
}

- (void)writeString:(NSString *)string; { [self writeString:string range:NSMakeRange(0, string.length)]; }

#pragma mark -
#pragma mark Pre-Blocks Support

- (void)startElement:(NSString *)elementName;
{
    [self startElement:elementName writeInline:[self canWriteElementInline:elementName]];
}

- (void)startElement:(NSString *)elementName writeInline:(BOOL)writeInline;
{
    // Can only write suitable tags inline if containing element also allows it
    if (!writeInline)
    {
        [self startNewline];
        [self stopWritingInline];
    }
    
    // Warn of impending start
    [self willStartElement:elementName];
    
    [self writeString:@"<"];
    [self writeString:elementName];
    
    // Must do this AFTER writing the string so subclasses can take early action in a -writeString: override
    [self pushElement:elementName];
    [self startWritingInline];
    
    
    // Write attributes
    [_attributes writeAttributes:self];
    [_attributes close];
    
    
    [self didStartElement];
    [self increaseIndentationLevel];
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

- (void)startCDATA;
{
    [self writeString:@"<![CDATA["];
}

- (void)endCDATA;
{
    [self writeString:@"]]>"];
}

@end


#pragma mark -


@implementation KSXMLAttributes (KSXMLWriter)

- (void)writeAttributes:(KSXMLWriter *)writer;
{
    for (NSUInteger i = 0; i < [_attributes count]; i+=2)
    {
        NSString *attribute = [_attributes objectAtIndex:i];
        NSString *value = [_attributes objectAtIndex:i+1];
        [writer writeAttribute:attribute value:value];
    }
}

@end

