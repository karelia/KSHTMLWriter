//
//  KSDOMToHTMLWriter.h
//  Sandvox
//
//  Created by Mike on 25/06/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSHTMLWriter+DOM.h"


@protocol SVDOMToHTMLWriterDelegate;
@interface KSDOMToHTMLWriter : KSHTMLWriter
{
  @private
    id <SVDOMToHTMLWriterDelegate>   _delegate;
}


#pragma mark Delegate
@property(nonatomic, assign) id <SVDOMToHTMLWriterDelegate> delegate;

@end


#pragma mark -


@protocol SVDOMToHTMLWriterDelegate <NSObject>
- (DOMNode *)HTMLWriter:(KSHTMLWriter *)writer willWriteDOMElement:(DOMElement *)element;
@end
