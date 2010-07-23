//
//  KSForwardingWriter.m
//  Sandvox
//
//  Created by Mike on 23/07/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSForwardingWriter.h"


@implementation KSForwardingWriter

#pragma mark Init & Dealloc

- (id)initWithOutputWriter:(id <KSWriter>)output; // designated initializer
{
    [super init];
    
    _writer = [output retain];
    
    return self;
}

- (id)init;
{
    return [self initWithOutputWriter:nil];
}

- (void)dealloc
{
    [self close];
    NSAssert(!_writer, @"-close failed to dispose of output writer");
    
    [super dealloc];
}

#pragma mark Writer Status

- (void)close;
{
    [_writer release]; _writer = nil;
}

#pragma mark Primitive

- (void)writeString:(NSString *)string;
{
    [_writer writeString:string];
}

@end
