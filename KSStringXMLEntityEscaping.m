//
//  KSStringXMLEntityEscaping.m
//  Sandvox
//
//  Created by Mike on 21/06/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSStringXMLEntityEscaping.h"

#import "KSXMLWriter.h"


@interface KSXMLWriter (KSXMLWriterSecretsIKnow)
- (void)writeStringByEscapingXMLEntities:(NSString *)string escapeQuot:(BOOL)escapeQuotes;
@end


#pragma mark -


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

- (NSString *)stringByEscapingHTMLEntitiesWithQuot:(BOOL)escapeQuotes
{
    NSMutableString *result = [NSMutableString string];
    
    KSXMLWriter *writer = [[KSXMLWriter alloc] initWithOutputWriter:result];
    [writer writeStringByEscapingXMLEntities:self escapeQuot:escapeQuotes];
    [writer release];
    
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
