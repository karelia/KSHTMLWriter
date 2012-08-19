//
//  KSStringXMLEntityEscaping.m
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


#import "KSStringXMLEntityEscaping.h"


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
	return [result autorelease];
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
                                                                               (CFDictionaryRef)entities));
	return [result autorelease];
    
#endif
}

@end


#pragma mark -


@implementation KSEscapedXMLEntitiesWriter

- (id)initWithOutputXMLWriter:(id <KSWriter>)output;	// designated initializer
{
    if (self = [self init])
    {
        _output = [output retain];
    }
    return self;
}

- (void)dealloc
{
    [_output release];
    [super dealloc];
}

- (void)writeString:(NSString *)string;
{
    [_output writeCharacters:string];
}

- (void)close;
{
    [_output release]; _output = nil;
}

@end
