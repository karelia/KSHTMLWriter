//
//  KSXMLWriterDOMAdaptor.h
//  Sandvox
//
//  Created by Mike Abdullah on 25/06/2010.
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

#import <WebKit/WebKit.h>
#import "KSXMLWriter.h"


typedef NS_OPTIONS(NSInteger, KSXMLWriterDOMAdaptorOptions) {
    KSXMLWriterOptionsNone = NSXMLNodeOptionsNone,
    KSXMLWriterDOMAdaptorPrettyPrint = NSXMLNodePrettyPrint,
    KSXMLWriterDOMAdaptorNormalize = 1 << 31,
};


@protocol KSXMLWriterDOMAdaptorDelegate;
@interface KSXMLWriterDOMAdaptor : NSObject
{
  @private
    KSXMLWriter *_writer;
    KSXMLWriterDOMAdaptorOptions    _options;
    
    id <KSXMLWriterDOMAdaptorDelegate>   _delegate;
}


#pragma mark Convenience
+ (NSString *)outerHTMLOfDOMElement:(DOMElement *)element;
+ (NSString *)outerXMLOfDOMElement:(DOMElement *)element options:(KSXMLWriterDOMAdaptorOptions)options;


#pragma mark Init
- (id)initWithXMLWriter:(KSXMLWriter *)writer;  // no options
- (id)initWithXMLWriter:(KSXMLWriter *)writer options:(KSXMLWriterDOMAdaptorOptions)options;

@property(nonatomic, retain, readonly) KSXMLWriter *XMLWriter;
@property(nonatomic, readonly) KSXMLWriterDOMAdaptorOptions options;


#pragma mark High Level
- (void)writeDOMElement:(DOMElement *)element;  // like -outerHTML
- (void)writeInnerOfDOMNode:(DOMNode *)node;    // like -innerHTML
- (void)writeDOMRange:(DOMRange *)range;


#pragma mark Implementation
- (void)writeInnerOfDOMNode:(DOMNode *)node startAtChild:(DOMNode *)aNode;
- (void)startElement:(NSString *)elementName withDOMElement:(DOMElement *)element;    // open the tag and write attributes
- (DOMNode *)endElementWithDOMElement:(DOMElement *)element;    // returns the next sibling to write
- (DOMNode *)writeComment:(NSString *)comment withDOMComment:(DOMComment *)commentNode;


#pragma mark Pseudo-delegate

// Default implementation returns element. To customise writing, subclass method to do its own writing and return the node to write instead (generally the element's next sibling)
- (DOMNode *)willWriteDOMElement:(DOMElement *)element;

- (DOMNode *)willWriteDOMText:(DOMText *)text;
- (DOMNode *)didWriteDOMText:(DOMText *)text nextNode:(DOMNode *)nextNode;  // for any post-processing


#pragma mark Delegate
@property(nonatomic, assign) id <KSXMLWriterDOMAdaptorDelegate> delegate;

@end


#pragma mark -


@protocol KSXMLWriterDOMAdaptorDelegate <NSObject>

/**
 Gives an opportunity to customise how the element is handled. Return `element` untouched for the
 adaptor to do its usual work. Otherwise, return a different node to move onto that. You might well
 perform your stringification logic for the element before returning.
 */
- (DOMNode *)DOMAdaptor:(KSXMLWriterDOMAdaptor *)writer willWriteDOMElement:(DOMElement *)element;

@end
