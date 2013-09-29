//
//  KSStringXMLEntityEscaping.m
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

- (NSString *)stringByUnescapingXMLEntities:(NSDictionary *)entities
{
	/*  OLD IOS CODE; RE-INSTATE IF NEEDED
	const xmlChar *unescapedXMLString = xmlStringDecodeEntities(xmlNewParserCtxt(),
																(const xmlChar *)[self UTF8String],
																XML_SUBSTITUTE_REF,
																0, 0, 0);
	
	NSString *result = [NSString stringWithUTF8String:(const char *)unescapedXMLString];
	return result;
    */
	   
	NSString *result = NSMakeCollectable(CFXMLCreateStringByUnescapingEntities(NULL,
                                                                               (CFStringRef)self,
                                                                               (CFDictionaryRef)entities));
	return [result autorelease];
    
}

#endif

@end
