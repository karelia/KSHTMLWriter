//
//  KSStringWriter.h
//  Sandvox
//
//  Created by Mike on 26/07/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSWriter.h"


@interface KSStringWriter : NSObject <KSWriter>
{
  @private
    NSMutableString *_buffer;
    NSUInteger      _length;
}

- (NSString *)string;

- (void)removeAllCharacters;    // reset, but cunningly keeps memory allocated for speed
- (void)close;                  // no effect on output/state, but frees any unused memory

@end
