//
//  KSXMLAttributes.m
//  Sandvox
//
//  Created by Mike Abdullah on 19/11/2010.
//  Copyright © 2010 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
