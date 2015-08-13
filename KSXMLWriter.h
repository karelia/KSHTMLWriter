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

#pragma mark Creating an XML Writer

// .encoding is taken from the writer. If output writer is nil, defaults to UTF-8
- (id)initWithOutputWriter:(KSWriter *)output NS_DESIGNATED_INITIALIZER;


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


#pragma mark Comments
- (void)writeComment:(NSString *)comment;   // escapes the string, and wraps in a comment tag
- (void)openComment;
- (void)closeComment;


#pragma mark CDATA
- (void)writeCDATAWithContentBlock:(void (^)(void))content;


#pragma mark Pretty Printing

/**
 Start a new line for pretty printing purposes, including tabs to match \c indentationLevel.
 Normally newlines are automatically written for you (if pretty-printing is enabled). You can call
 this if you need an extra one, or are implementing your own extra control over formatting.
 
 KSXMLWriter uses this as the cue to know that the current element spans multiple lines, and
 therefore its end tag should be written on a new line too.
 */
- (void)startNewline;

/**
 Whether the receiver should create human-friendly output by indenting elements, and placing them on
 a newline. The default is \c NO, but \c KSHTMLWriter does the opposite, to make pretty-printing on
 by default.
 
 Pretty-printing is implemented such that when starting an element, it is placed onto a new line,
 with an increased \c indentationLevel. There are some exceptions:
 
 - When starting a document, if the first bit of content is an element, it doesn't make sense to
 place that on a new line because if we did, you'd be left with a weird empty line at the start of
 the document.
 
 - You can call \c -resetPrettyPrinting to make use of the mechanism described above so as to force
 the writer not to insert a newline for a moment.
 
 - For HTML, some elements want to be written inline anyway for optimum prettiness. E.g. \c EM tags
 inside of a paragraph. `shouldPrettyPrintElementInline` is consulted to find out if that is the
 case, so as to bypass the newline behaviour.
 
 By waiting until the _start_ of an element, clients are able to do a little customisation with the
 _end_ of elements. For example, you can add a comment straight after the end tag, and that won't
 get shunted onto a new line.
 */
@property(nonatomic) BOOL prettyPrint;

/**
 Resets the system so that the next element to be written is *not* given a new line to itself,
 regardless of tag name etc. You don't need to call this under normal circumstances, but it can be
 handy for odd occasions where you need to temporarily disable pretty printing.
 */
- (void)resetPrettyPrinting;

/**
 When starting an element with \c prettyPrint turned on, this gets called to decide if \c element
 should be written inline, or begin on a new line.
 
 The default implementation returns \c NO. \c KSHTMLWriter overrides to know about a variety of
 common HTML elements.
 */
+ (BOOL)shouldPrettyPrintElementInline:(NSString *)element;


#pragma mark Indentation
// Setting the indentation level does not write to the context in any way. It is up to methods that actually do some writing to respect the indent level. e.g. starting a new line should indent that line to match.
@property(nonatomic) NSUInteger indentationLevel;
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


#pragma mark Output

/**
 This is the primitive API through which all output is channeled. The requested \c range of \c string
 is sent through to \c outputWriter. Any characters which aren't supported by the receiver's
 \c encoding are XML escaped before sending through.
 */
- (void)writeString:(NSString *)string range:(NSRange)range;

/**
 Convenience that calls straight through to \c writeString:range: requesting the whole string be
 written
 */
- (void)writeString:(NSString *)string;

/**
 Automatically taken from the \c outputWriter. Defaults to UTF8 if there is no output
 */
@property(nonatomic, readonly) NSStringEncoding encoding;

/** we support ASCII, UTF8, ISO Latin 1, and Unicode at present
 */
+ (BOOL)isStringEncodingAvailable:(NSStringEncoding)encoding;


@property(readonly) KSWriter *outputWriter;


#pragma mark -
#pragma mark Pre-Blocks Support
// Would be a category, but that confuses the compiler when looking for protocol-conformance in Sandvox

// These simple methods make up the bulk of element writing. You can start as many elements at a time as you like in order to nest them. Calling -endElement will automatically know the right close tag to write etc.
- (void)startElement:(NSString *)elementName;
- (void)endElement;

- (void)startCDATA;
- (void)endCDATA;

@end

