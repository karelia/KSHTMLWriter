//
//  KSXMLWriter.h
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

#import <KSWriter/KSWriter.h>

#import "KSXMLAttributes.h"


@interface KSXMLWriter : NSObject
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

// .encoding is taken from the writer. If output writer is nil, defaults to UTF-8
// Designated initializer
- (id)initWithOutputWriter:(KSWriter *)output;


#pragma mark Writer Status
- (void)close;  // calls -flush, then releases most ivars such as _writer
- (void)flush;  // if there's anything waiting to be lazily written, forces it to write now. For subclasses to implement


#pragma mark Document

/**
 The document's type, which we hang onto so clients can get some information about the XML being
 written if they need to. Avoid changing this mid-writing as would likely confuse clients.
 */
@property(nonatomic, copy) NSString *doctype;

/**
 Writes a doctype declaration according to the receiver's \c docType, which must be non-nil. Example:
 
 <!DOCTYPE %docType%>
 */
- (void)writeDoctypeDeclaration;


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

/**
 Attempting to decrease the indentation level to a negative value will log an error message and go
 otherwise ignored.
 */
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
- (void)writeString:(NSString *)string range:(NSRange)range; // anything outside the receiver's encoding gets escaped. primitive
- (void)writeString:(NSString *)string; // convenience
+ (BOOL)isStringEncodingAvailable:(NSStringEncoding)encoding;   // we support ASCII, UTF8, ISO Latin 1, and Unicode at present


#pragma mark Output
@property(readonly) KSWriter *outputWriter;


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

