//
//  KSXMLWriterDOMAdaptor.h
//  Sandvox
//
//  Created by Mike on 25/06/2010.
//  Copyright 2010-2012 Karelia Software. All rights reserved.
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
- (DOMNode *)DOMAdaptor:(KSXMLWriterDOMAdaptor *)writer willWriteDOMElement:(DOMElement *)element;
@end
