//
//  KSHTMLWriter.h
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


#import "KSXMLWriter.h"


extern NSString *KSHTMLWriterDocTypeHTML_4_01_Strict;
extern NSString *KSHTMLWriterDocTypeHTML_4_01_Transitional;
extern NSString *KSHTMLWriterDocTypeHTML_4_01_Frameset;
extern NSString *KSHTMLWriterDocTypeXHTML_1_0_Strict;
extern NSString *KSHTMLWriterDocTypeXHTML_1_0_Transitional;
extern NSString *KSHTMLWriterDocTypeXHTML_1_0_Frameset;
extern NSString *KSHTMLWriterDocTypeXHTML_1_1;
extern NSString *KSHTMLWriterDocTypeHTML_5;


@interface KSHTMLWriter : KSXMLWriter
{
  @private
    NSString        *_docType;
    BOOL            _isXHTML;
    NSMutableSet    *_IDs;
    
    NSMutableArray  *_classNames;
}

#pragma mark Creating an HTML Writer
// For if you desperately need to set a doctype before calling -startDocument:isXHTML: (perhaps because you're not going to call it!)
- (id)initWithOutputWriter:(id <KSWriter>)output docType:(NSString *)docType encoding:(NSStringEncoding)encoding;


#pragma mark DTD

// Default is HTML5
@property(nonatomic, copy, readonly) NSString *docType;

// Whether empty elements should be written as <FOO> or <FOO />
// Default is YES. There's no setter method; instead, specify with -startDocumentWithDocType:encoding: or when initializing.
- (BOOL)isXHTML;
+ (BOOL)isDocTypeXHTML:(NSString *)docType;


#pragma mark CSS Class Name
// Class names are accumulated and written automatically as an attribute of the next element started
// You can also push a class name using -pushAttribute:value: if attribute is 'class'
- (void)pushClassName:(NSString *)className;
- (void)pushClassNames:(NSArray *)classNames;


#pragma mark HTML Fragments
// Any newlines in the HTML will be adjusted to account for current indentation level, but that's all
// Terminating newline character will be added or removed if needed, as according to terminatingNewline argument
- (void)writeHTMLString:(NSString *)html withTerminatingNewline:(BOOL)terminatingNewline;
- (void)writeHTMLString:(NSString *)html;


#pragma mark General

//  <tagName id="idName" class="className">
//  Pretty standard convenience methods
- (void)writeElement:(NSString *)name idName:(NSString *)idName className:(NSString *)className content:(void (^)(void))content;
- (void)startElement:(NSString *)tagName className:(NSString *)className;
- (void)startElement:(NSString *)tagName idName:(NSString *)idName className:(NSString *)className;

- (BOOL)isIDValid:(NSString *)anID; // NO if the ID has already been used


#pragma mark Document
// Convenience to give you standard document structure
// head is optional
- (void)writeDocumentOfType:(NSString *)docType encoding:(NSStringEncoding)encoding head:(void (^)(void))headBlock body:(void (^)(void))bodyBlock;


#pragma mark Line Break
// <br />   OR  <br>
// depends on isXHTML
- (void)writeLineBreak;


#pragma mark Links
//  <a href="...." target="..." rel="nofollow">
- (void)writeAnchorElementWithHref:(NSString *)href
                             title:(NSString *)titleString
                            target:(NSString *)targetString
                               rel:(NSString *)relString
                           content:(void (^)(void))content; // a block must provided - an empty anchor doesn't make sense!

// Deprecated
- (void)startAnchorElementWithHref:(NSString *)href title:(NSString *)titleString target:(NSString *)targetString rel:(NSString *)relString;


#pragma mark Images
//  <img src="..." alt="..." width="..." height="..." />
- (void)writeImageWithSrc:(NSString *)src
                      alt:(NSString *)alt
                    width:(id)width
                   height:(id)height;


#pragma mark Link

//  <link>
//  Goes in <head> to link to scripts, CSS, etc.
- (void)writeLinkWithHref:(NSString *)href
                     type:(NSString *)type
                      rel:(NSString *)rel
                    title:(NSString *)title
                    media:(NSString *)media;

// Note: If a title is set, it is considered an *alternate* stylesheet. http://www.alistapart.com/articles/alternate/
- (void)writeLinkToStylesheet:(NSString *)href
                        title:(NSString *)title
                        media:(NSString *)media;


#pragma mark Scripts

- (void)writeJavascriptWithSrc:(NSString *)src encoding:(NSStringEncoding)encoding;
- (void)writeJavascriptWithSrc:(NSString *)src charset:(NSString *)charset;
- (void)writeJavascript:(NSString *)script useCDATA:(BOOL)useCDATA;
- (void)writeJavascriptWithContent:(void (^)(void))content;

// Like -startCDATA and -endCDATA, but wrapped in a javascript comment so don't risk tripping up a browser's interpreter
- (void)startJavascriptCDATA;
- (void)endJavascriptCDATA;

#pragma mark Param

- (void)writeParamElementWithName:(NSString *)name value:(NSString *)value;

#pragma mark Style
- (void)writeStyleElementWithCSSString:(NSString *)css;
- (void)startStyleElementWithType:(NSString *)type;


#pragma mark Lists
- (BOOL)hasListOpen;
- (BOOL)topElementIsList;
+ (BOOL)elementIsList:(NSString *)element;


#pragma mark Element Primitives
//   />    OR    >
//  Which is used depends on -isXHTML
- (void)closeEmptyElementTag;             


@end

