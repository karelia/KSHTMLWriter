//
//  KSStringWriter.h
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


#import "KSWriter.h"


@interface KSStringWriter : NSObject <KSWriter>
{
  @private
    NSMutableString *_buffer;
    NSPointerArray  *_bufferPoints; // stored in reverse order for efficiency
    BOOL            _flushOnNextWrite;
}

- (NSUInteger)length;
- (NSString *)string;

- (void)removeAllCharacters;    // reset, but cunningly keeps memory allocated for speed
- (void)close;                  // no effect on output/state, but frees any unused memory


#pragma mark Buffering

- (void)beginBuffering; // can be called multiple times to set up a stack of buffers.
- (void)discardBuffer;  // discards the most recent buffer
- (void)flush;          // end buffering by pushing all buffers through to main string

- (void)flushOnNextWrite;   // calls -flush at next write. Can still use -discardBuffer to effectively cancel this
- (void)cancelFlushOnNextWrite;


#pragma mark Special
// This is more for the benefit of Sandvox. Will try to improve later.
- (void)insertString:(NSString *)aString atIndex:(NSUInteger)anIndex;


@end


extern NSString *KSStringWriterWillFlushNotification;