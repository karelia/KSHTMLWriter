//
//  KSStringWriter.m
//  Sandvox
//
//  Created by Mike on 26/07/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSStringWriter.h"


NSString *KSStringWriterWillFlushNotification = @"KSStringWriterWillFlush";


@implementation KSStringWriter

- (id)init;
{
    [super init];
    
    _buffer = [[NSMutableString alloc] init];
    
    _bufferPoints = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsIntegerPersonality];
    [_bufferPoints addPointer:0];
    
    return self;
}

- (void)dealloc
{
    [_buffer release];
    [_bufferPoints release];
    
    [super dealloc];
}

#pragma mark NSString Primitives
// Not really used on the whole, but theoretically this class could be an NSString subclass

- (NSUInteger)length;
{
    return (NSUInteger)[_bufferPoints pointerAtIndex:([_bufferPoints count] - 1)];
}

- (unichar)characterAtIndex:(NSUInteger)index;
{
    NSParameterAssert(index < [self length]);
    return [_buffer characterAtIndex:index];
}

- (void)getCharacters:(unichar *)buffer range:(NSRange)aRange;
{
    NSParameterAssert((aRange.location + aRange.length) <= [self length]);
    return [_buffer getCharacters:buffer range:aRange];
}

#pragma mark Writing

- (NSUInteger)insertionPoint; { return (NSUInteger)[_bufferPoints pointerAtIndex:0]; }

- (NSString *)string;
{
    return [_buffer substringToIndex:[self length]];
}

- (void)writeString:(NSString *)string;
{
    // Flush if needed
    NSUInteger length = [string length];
    if (_flushOnNextWrite && length)
    {
        [self flush];
    }
    
    
    // Replace existing characters where possible
    NSUInteger insertionPoint = [self insertionPoint];
    NSUInteger unusedCapacity = [_buffer length] - insertionPoint;
    
    NSRange range = NSMakeRange(insertionPoint, MIN(length, unusedCapacity));
    [_buffer replaceCharactersInRange:range withString:string];
    
    insertionPoint = (insertionPoint + length);
    [_bufferPoints replacePointerAtIndex:0 withPointer:(void *)insertionPoint];
}

- (void)close;
{
    // Prune the buffer back down to size
    NSUInteger length = [self length];
    NSUInteger bufferLength = [_buffer length];
    if (bufferLength > length)
    {
        NSRange range = NSMakeRange(length, bufferLength - length);
        [_buffer deleteCharactersInRange:range];
    }
}

- (void)removeAllCharacters;
{
    [_bufferPoints release]; _bufferPoints = [[NSPointerArray alloc]
                                              initWithOptions:NSPointerFunctionsIntegerPersonality];
    [_bufferPoints addPointer:0];
}

#pragma mark Buffering

// Can be called multiple times to set up a stack of buffers.
- (void)beginBuffering;
{
    [_bufferPoints insertPointer:(void *)[self insertionPoint] atIndex:0];
}

// Discards the most recent buffer. If there's a lower one in the stack, that is restored
- (void)discardBuffer;  
{
    [_bufferPoints removePointerAtIndex:0];
}

- (void)flush;
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:KSStringWriterWillFlushNotification
     object:self];
    
    // Ditch all buffer points except the one currently marking -insertionPoint
    for (NSUInteger i = [_bufferPoints count]-1; i > 0; i--)
    {
        [_bufferPoints removePointerAtIndex:i];
    }
    _flushOnNextWrite = NO;
}

- (void)flushOnNextWrite; { _flushOnNextWrite = YES; }

#pragma mark Debug

- (NSString *)debugDescription;
{
    NSString *result = [self description];
    result = [result stringByAppendingFormat:@" %@", [_buffer substringToIndex:[self insertionPoint]]];
    return result;
}

@end
