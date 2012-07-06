//
//  KSXMLWriter.h
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


#import "KSForwardingWriter.h"

#import "KSXMLAttributes.h"


@interface KSXMLWriter : KSForwardingWriter
{
  @private
    KSXMLAttributes   *_attributes;
    NSMutableArray  *_openElements;
    BOOL            _elementIsEmpty;
    NSUInteger      _inlineWritingLevel;    // the number of open elements at which inline writing began
        
    NSInteger   _indentation;
    
    NSStringEncoding    _encoding;
}

#pragma mark Creating an XML Writer

// If output responds to -encoding, that is used as the default encoding. Designated initializer
- (id)initWithOutputWriter:(id <KSWriter>)output;

// Use this if you need to set encoding up-front, rather than by starting document
- (id)initWithOutputWriter:(id <KSWriter>)output encoding:(NSStringEncoding)encoding;


#pragma mark Writer Status
- (void)close;  // calls -flush, then releases most ivars such as _writer
- (void)flush;  // if there's anything waiting to be lazily written, forces it to write now. For subclasses to implement


#pragma mark Document
// e.g. docType of @"html" for HTML 5. KSHTMLWriter declares many such constants
- (void)startDocumentWithDocType:(NSString *)docType encoding:(NSStringEncoding)encoding;


#pragma mark Characters

//  Escapes the string and calls -writeString:. NOT intended for other text-like strings such as element attributes
- (void)writeCharacters:(NSString *)string;

// Convenience to perform escaping without instantiating a writer
+ (NSString *)stringFromCharacters:(NSString *)string;


#pragma mark Elements

- (void)writeElement:(NSString *)name content:(void (^)(void))content;
- (void)writeElement:(NSString *)name attributes:(NSDictionary *)attributes content:(void (^)(void))content;

/* Need to force inline writing? Fall back to the old -startElement… API for now */

// Convenience for writing <tag>text</tag>
- (void)writeElement:(NSString *)elementName text:(NSString *)text;

- (void)willStartElement:(NSString *)element;


#pragma mark Current Element
/*  You can also gain finer-grained control over element attributes. KSXMLWriter maintains a list of attributes that will be applied when you *next* call one of the -startElement: methods. This has several advantages:
 *      - Attributes are written in exactly the order you specify
 *      - More efficient than building up a temporary dictionary object
 *      - Can sneak extra attributes in when using a convenience method (e.g. for HTML)
 *
 *  The stack is cleared for you each time an element starts, to save the trouble of manually managing that.
 */
- (void)pushAttribute:(NSString *)attribute value:(id)value;
- (KSXMLAttributes *)currentAttributes; // modifying this object will not affect writing
- (BOOL)hasCurrentAttributes;           // faster than querying -currentAttributes


#pragma mark Attributes
// Like +stringFromCharacters: but for attributes, where quotes need to be escaped
+ (NSString *)stringFromAttributeValue:(NSString *)value;


#pragma mark Whitespace
//  Writes a newline character and the tabs to match -indentationLevel. Normally newlines are automatically written for you; call this if you need an extra one.
- (void)startNewline;


#pragma mark Comments
- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
- (void)openComment;
- (void)closeComment;


#pragma mark CDATA
- (void)writeCDATAWithContentBlock:(void (^)(void))content;


#pragma mark Indentation
// Setting the indentation level does not write to the context in any way. It is up to methods that actually do some writing to respect the indent level. e.g. starting a new line should indent that line to match.
@property(nonatomic) NSInteger indentationLevel;
- (void)increaseIndentationLevel;
- (void)decreaseIndentationLevel;


#pragma mark Validation
// Default implementation returns YES. Subclasses can override to advise that the writing of an element would result in invalid markup
- (BOOL)validateElement:(NSString *)element;
- (NSString *)validateAttribute:(NSString *)name value:(NSString *)value ofElement:(NSString *)element;



#pragma mark Elements Stack
// XMLWriter maintains a stack of the open elements so it knows how to end them. You probably don't ever care about this, but it can be handy in more advanced use cases

@property(nonatomic, readonly) NSArray *openElements;  // the methods below are faster than this

- (NSUInteger)openElementsCount;
- (BOOL)hasOpenElement:(NSString *)tagName;

- (NSString *)topElement;
- (void)pushElement:(NSString *)element;
- (void)popElement;


#pragma mark Element Primitives
- (void)closeEmptyElementTag;             


#pragma mark Inline Writing

- (BOOL)isWritingInline;
- (void)startWritingInline;
- (void)stopWritingInline;

// Class method is a general rule; instance method takes into account current indent level etc.
- (BOOL)canWriteElementInline:(NSString *)element;
+ (BOOL)shouldPrettyPrintElementInline:(NSString *)element;


#pragma mark String Encoding
@property(nonatomic, readonly) NSStringEncoding encoding;   // default is UTF-8
+ (BOOL)isStringEncodingAvailable:(NSStringEncoding)encoding;   // we support ASCII, UTF8, ISO Latin 1, and Unicode at present 
- (void)writeString:(NSString *)string; // anything outside .encoding gets escaped


#pragma mark -
#pragma mark Pre-Blocks Support
// Would be a category, but that confuses the compiler when looking for protocol-conformance in Sandvox

// These simple methods make up the bulk of element writing. You can start as many elements at a time as you like in order to nest them. Calling -endElement will automatically know the right close tag to write etc.
- (void)startElement:(NSString *)elementName;
- (void)startElement:(NSString *)elementName writeInline:(BOOL)writeInline; // for more control
- (void)endElement;

- (void)startCDATA;
- (void)endCDATA;

@end

