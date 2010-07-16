//
//  KSStringXMLEntityEscaping.m
//  Sandvox
//
//  Created by Mike on 21/06/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSStringXMLEntityEscaping.h"


@implementation NSString (KSStringXMLEntityEscaping)

#pragma mark XML

#if !TARGET_OS_IPHONE

/*	These two methods are simple wrappers for CoreFoundation
 */

- (NSString *)stringByEscapingXMLEntities:(NSDictionary *)entities
{
	NSString *result = NSMakeCollectable(CFXMLCreateStringByEscapingEntities(NULL,
                                                                             (CFStringRef)self,
                                                                             (CFMutableDictionaryRef)entities));
	result = [result autorelease];
	return result;
}

#endif

- (NSString *)stringByUnescapingXMLEntities:(NSDictionary *)entities
{
	
#if TARGET_OS_IPHONE
	
	const xmlChar *unescapedXMLString = xmlStringDecodeEntities(xmlNewParserCtxt(),
																(const xmlChar *)[self UTF8String],
																XML_SUBSTITUTE_REF,
																0, 0, 0);
	
	NSString *result = [NSString stringWithUTF8String:(const char *)unescapedXMLString];
	return result;
	
#else
    
	NSString *result = NSMakeCollectable(CFXMLCreateStringByUnescapingEntities(NULL,
                                                                               (CFStringRef)self,
                                                                               (CFMutableDictionaryRef)entities));
	result = [result autorelease];
	return result;
    
#endif
}

#pragma mark HTML

/*!	Escape & < > " ... does NOT escape anything else.  Need to deal with character set in subsequent pass.
 Escaping " so that strings work within HTML tags
 */

// Explicitly escape, or don't escape, double-quots as &quot;
// Within a tag like <foo attribute="%@"> then we have to escape it.
// In just about all other contexts it's OK to NOT escape it, but many contexts we don't know if it's OK or not.
// So I think we want to gradually shift over to being explicit when we know when it's OK or not.
- (NSString *)stringByEscapingHTMLEntitiesWithQuot:(BOOL)escapeQuotes
{
    // Cache the characters to be escaped
	static NSCharacterSet *escapedSet;
    if (!escapedSet)
    {
        escapedSet = [[NSCharacterSet characterSetWithCharactersInString:@"&<>\""] retain];
    }
	
    
    // Look for characters to escape. If there are none can bail out quick without having had to allocate anything. #78710
    NSRange searchRange = NSMakeRange(0, [self length]);
    NSRange range = [self rangeOfCharacterFromSet:escapedSet options:0 range:searchRange];
    if (range.location == NSNotFound) return self;
    
    
    NSMutableString *result = [NSMutableString stringWithCapacity:(searchRange.length + 5)];
    while (searchRange.length)
	{
        // Characters not needing escaping can be appended straight off
		NSRange unescapedRange = searchRange;
        if (range.location != NSNotFound)
        {
            unescapedRange.length = range.location - searchRange.location;
        }
        [result appendString:[self substringWithRange:unescapedRange]];
        
        
		// Process characters that need escaping
		if (range.location != NSNotFound)
        {            
            OBASSERT(range.length == 1);    // that's all we should deal with for HTML escaping
			
            unichar ch = [self characterAtIndex:range.location];
            switch (ch)
            {
                case '&':	[result appendString:@"&amp;"];		break;
                case '<':	[result appendString:@"&lt;"];		break;
                case '>':	[result appendString:@"&gt;"];		break;
                case '"':	[result appendString:@"&quot;"];	break;
            }
		}
        else
        {
            break;  // no escapable characters were found so we must be done
        }
        
        
        // Continue the search
        searchRange.location = range.location + range.length;
        searchRange.length = [self length] - searchRange.location;
        range = [self rangeOfCharacterFromSet:escapedSet options:0 range:searchRange];
	}	
	
    
    return result;
}


- (NSString *)stringByEscapingHTMLEntities;
{
	return [self stringByEscapingHTMLEntitiesWithQuot:YES];	// default to escaping the quot as before.
}

@end


#pragma mark -


@implementation KSEscapedXMLEntitiesWriter

- (id)initWithOutputWriter:(id <KSWriter>)output;	// designated initializer
{
    [self init];
    _output = [output retain];
    return self;
}

- (void)dealloc
{
    [_output release];
    [super dealloc];
}

- (void)writeString:(NSString *)string;
{
    [_output writeString:[string stringByEscapingHTMLEntities]];
}

- (void)close;
{
    [_output release]; _output = nil;
}

@end
