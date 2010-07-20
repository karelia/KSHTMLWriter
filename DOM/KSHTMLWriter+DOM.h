//
//  KSHTMLWriter+DOM.h
//  Sandvox
//
//  Created by Mike on 25/02/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSHTMLWriter.h"
#import <WebKit/WebKit.h>

@interface KSHTMLWriter (DOM)

#pragma mark High Level
- (void)writeDOMElement:(DOMElement *)element;  // like -outerHTML
- (void)writeInnerOfDOMNode:(DOMNode *)node;    // like -innerHTML
- (void)writeDOMRange:(DOMRange *)range;


#pragma mark Implementation
- (void)writeInnerOfDOMNode:(DOMNode *)node startAtChild:(DOMNode *)aNode;
- (void)startElement:(NSString *)elementName withDOMElement:(DOMElement *)element;    // open the tag and write attributes
- (DOMNode *)endElementWithDOMElement:(DOMElement *)element;    // returns the next sibling to write


#pragma mark Pseudo-delegate

// Default implementation returns element. To customise writing, subclass method to do its own writing and return the node to write instead (generally the element's next sibling)
- (DOMNode *)willWriteDOMElement:(DOMElement *)element;

- (DOMNode *)didWriteDOMText:(DOMText *)text nextNode:(DOMNode *)nextNode;  // for any post-processing


@end
