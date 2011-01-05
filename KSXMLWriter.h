//
//  KSXMLWriter.h
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


#import "KSForwardingWriter.h"

#import "KSElementInfo.h"


@class KSXMLElementContentsProxy;


@interface KSXMLWriter : KSForwardingWriter
{
  @private
    KSElementInfo   *_currentElement;
    NSMutableArray  *_openElements;
    BOOL            _elementIsEmpty;
    NSUInteger      _inlineWritingLevel;    // the number of open elements at which inline writing began
    
    KSXMLElementContentsProxy   *_contentsProxy;
    
    NSInteger   _indentation;
    
    NSStringEncoding    _encoding;
    NSCharacterSet      *_illegalCharacters;
}

#pragma mark Creating an XML Writer

- (id)initWithOutputWriter:(id <KSWriter>)output; // designated initializer
                                                  
// Use this if you need to set encoding up-front, rather than by starting document
- (id)initWithOutputWriter:(id <KSWriter>)output encoding:(NSStringEncoding)encoding;


#pragma mark Writer Status
- (void)close;  // calls -flush, then releases most ivars such as _writer
- (void)flush;  // if there's anything waiting to be lazily written, forces it to write now. For subclasses to implement


#pragma mark Document
- (void)startDocument:(NSString *)DTD   // at present, expect DTD to be complete tag
             encoding:(NSStringEncoding)encoding;


#pragma mark Text
//  Escapes the string and calls -writeString:. NOT intended for writing text-like strings e.g. element attributed
- (void)writeText:(NSString *)string;


#pragma mark Elements

//  Since we don't have blocks support yet, this is a slight approximation. You could do something like this:
//
//      [[writer writeElement:@"foo" contentsInvocationTarget:self]
//         writeFooContents];
//
//  Where if the -writeFooContents method writes another element and some text, you get this markup:
//
//      <foo>
//          <bar>baz</baz>
//      </foo>
//
//  This is about the same amount of code as calling -startElement: and -endElement: seperately. But, it can help make your code more readable, and will also sanity check to make sure the contents invocation balanced its calls to -startElement: and -endElement:
- (id)writeElement:(NSString *)elementName contentsInvocationTarget:(id)target;

// Convenience for writing <tag>text</tag>
- (void)writeElement:(NSString *)elementName text:(NSString *)text;

// These simple methods make up the bulk of element writing. You can start as many elements at a time as you like in order to nest them. Calling -endElement will automatically know the right close tag to write etc.
- (void)startElement:(NSString *)elementName;
- (void)startElement:(NSString *)elementName writeInline:(BOOL)writeInline; // for more control
- (void)startElement:(NSString *)elementName attributes:(NSDictionary *)attributes;
- (void)endElement;


#pragma mark Current Element
/*  You can also gain finer-grained control over element attributes. KSXMLWriter maintains a list of attributes that will be applied when you *next* call one of the -startElement: methods. This has several advantages:
 *      - Attributes are written in exactly the order you specify
 *      - More efficient than building up a temporary dictionary object
 *      - Can sneak extra attributes in when using a convenience method (e.g. for HTML)
 */
- (void)pushAttribute:(NSString *)attribute value:(id)value;
- (KSElementInfo *)currentElementInfo;  // modifying this object will not affect writing


#pragma mark Whitespace
//  Writes a newline character and the tabs to match -indentationLevel. Nornally newlines are automatically written for you; call this if you need an extra one.
- (void)startNewline;


#pragma mark Comments
- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
- (void)openComment;
- (void)closeComment;


#pragma mark CDATA
- (void)startCDATA;
- (void)endCDATA;


#pragma mark Indentation
// Setting the indentation level does not write to the context in any way. It is up to methods that actually do some writing to respect the indent level. e.g. starting a new line should indent that line to match.
@property(nonatomic) NSInteger indentationLevel;
- (void)increaseIndentationLevel;
- (void)decreaseIndentationLevel;


#pragma mark Elements Stack
// XMLWriter maintains a stack of the open elements so it knows how to end them

- (NSUInteger)openElementsCount;
- (BOOL)hasOpenElement:(NSString *)tagName;

- (NSString *)topElement;


#pragma mark Element Primitives
- (void)closeEmptyElementTag;             


#pragma mark Inline Writing
- (BOOL)isWritingInline;
- (void)startWritingInline;
- (void)stopWritingInline;
- (BOOL)canWriteElementInline:(NSString *)tagName;


#pragma mark String Encoding
@property(nonatomic, readonly) NSStringEncoding encoding;   // default is UTF-8
- (NSCharacterSet *)legalCharacterSet;  // can override. caller takes responsibility for caching
- (void)writeString:(NSString *)string; // anything outside -legalCharacterSet gets escaped


@end
