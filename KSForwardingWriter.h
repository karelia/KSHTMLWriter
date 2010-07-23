//
//  KSForwardingWriter.h
//  Sandvox
//
//  Created by Mike on 23/07/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//
//  Abstract base class for any writers that operate by sending strings along to an output writer.
//


#import <Foundation/Foundation.h>
#import "KSWriter.h"


@interface KSForwardingWriter : NSObject <KSWriter>
{
  @private
    id <KSWriter> _writer;
}

#pragma mark Creating a Writer
- (id)initWithOutputWriter:(id <KSWriter>)stream; // designated initializer
- (id)init; // calls -initWithOutputWriter with nil. Handy for iteration & deriving info, but not a lot else


#pragma mark Primitive

- (void)writeString:(NSString *)string; // calls -writeString: on our string stream. Override to customize raw writing


@end
