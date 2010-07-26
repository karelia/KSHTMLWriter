//
//  KSStringWriter.m
//  Sandvox
//
//  Created by Mike on 26/07/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSStringWriter.h"


@implementation KSStringWriter

- (id)init;
{
    [super init];
    
    _buffer = [[NSMutableString alloc] init];
    
    return self;
}

- (void)dealloc
{
    [_buffer release];
    [super dealloc];
}

#pragma mark NSString Primitives
// Not really used onn the whole, but theoretically this class could be an NSString subclass

- (NSUInteger)length; { return _length; }

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

- (NSString *)string;
{
    return [_buffer substringToIndex:[self length]];
}

- (void)writeString:(NSString *)string;
{
    NSUInteger length = [string length];
    NSUInteger unusedCapacity = [_buffer length] - [self length];
    
    // Replace existing characters where possible
    NSRange range = NSMakeRange([self length], MIN(length, unusedCapacity));
    [_buffer replaceCharactersInRange:range withString:string];
    
    _length += length;
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

- (void)removeAllCharacters; { _length = 0; }

@end
