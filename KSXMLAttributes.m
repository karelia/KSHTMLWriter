//
//  KSXMLAttributes.m
//  Sandvox
//
//  Created by Mike on 19/11/2010.
//  Copyright 2010-2012 Karelia Software. All rights reserved.
//

#import "KSXMLAttributes.h"

#import "KSXMLWriter.h"


@implementation KSXMLAttributes

#pragma mark Dictionary Primitives

- (NSUInteger)count; { return [_attributes count] / 2; }

- (id)objectForKey:(id)aKey;
{
    for (NSUInteger i = 0; i < [_attributes count]; i+=2)
    {
        NSString *attribute = [_attributes objectAtIndex:i];
        id value = [_attributes objectAtIndex:i+1];
        
        if ([attribute isEqual:aKey])   // not -isEqualToString: on the offchance someone's crazy enough to pass in non-string key
        {
            return value;
        }
    }
    
    return nil;
}

- (NSEnumerator *)keyEnumerator;
{
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    for (NSInteger i = 0; i < [_attributes count]; i+=2)
    {
        NSString *attribute = [_attributes objectAtIndex:i];
        [keys addObject:attribute];
    }
    
    NSEnumerator *result = [keys objectEnumerator];
    [keys release]; // the enumerator should retain the array
    return result;
}

#pragma mark Lifecycle

- (id)init;
{
    if (self = [super init])
    {
        _attributes = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

- (id)initWithXMLAttributes:(KSXMLAttributes *)info;
{
    if (self = [super init])    // call super, so _attributes is still nil
    {
        _attributes = [info->_attributes mutableCopy];
    }
    return self;
}

- (void)dealloc;
{
    [_attributes release];
    
    [super dealloc];
}

- (void)setAttributesAsDictionary:(NSDictionary *)dictionary;
{
    for (NSString *anAttribute in dictionary)
    {
        [self addAttribute:anAttribute value:[dictionary objectForKey:anAttribute]];
    }
}

- (void)addAttribute:(NSString *)attribute value:(id)value;
{
    NSParameterAssert(value);
    
    // TODO: Ignore if the attribute is already present
    
    [_attributes addObject:attribute];
    [_attributes addObject:value];
}

- (void)close;
{
    [_attributes removeAllObjects];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    return [[[KSXMLAttributes class] alloc] initWithXMLAttributes:self];
}

@end
