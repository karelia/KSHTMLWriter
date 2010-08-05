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
    NSPointerArray  *_bufferPoints; // stored in reverse order for efficiency
    BOOL            _flushOnNextWrite;
}

- (NSString *)string;

- (void)removeAllCharacters;    // reset, but cunningly keeps memory allocated for speed
- (void)close;                  // no effect on output/state, but frees any unused memory


#pragma mark Buffering

- (void)beginBuffering; // can be called multiple times to set up a stack of buffers.
- (void)discardBuffer;  // discards the most recent buffer
- (void)flush;          // end buffering by pushing all buffers through to main string

- (void)flushOnNextWrite;   // calls -flush at next write. Can still use -discardBuffer to effectively cancel this
- (void)cancelFlushOnNextWrite;

@end


extern NSString *KSStringWriterWillFlushNotification;