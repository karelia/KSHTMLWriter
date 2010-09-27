//
//  KSHTMLWriter+DOM.h
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
