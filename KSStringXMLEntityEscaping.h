//
//  KSStringXMLEntityEscaping.h
//
//  Copyright (c) 2010, Mike Abdullah and Karelia Software
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


#import <Foundation/Foundation.h>
#import "KSXMLWriter.h"


@interface NSString (KSStringXMLEntityEscaping)

#pragma mark XML
#if !TARGET_OS_IPHONE
- (NSString *)stringByEscapingXMLEntities:(NSDictionary *)entities;
#endif
- (NSString *)stringByUnescapingXMLEntities:(NSDictionary *)entities;


#pragma mark HTML
- (NSString *)stringByEscapingHTMLEntities;
- (NSString *)stringByEscapingHTMLEntitiesWithQuot:(BOOL)escapeQuotes;


@end


#pragma mark -


// Simply passes through strings, but escapes them first
@interface KSEscapedXMLEntitiesWriter : NSObject <KSWriter>
{
@private
    KSXMLWriter *_output;
}

- (id)initWithOutputXMLWriter:(KSXMLWriter *)output;
- (void)close;  // releases output writer

@end
