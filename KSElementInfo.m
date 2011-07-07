//
//  KSElementInfo.m
//  Sandvox
//
//  Created by Mike on 19/11/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSElementInfo.h"

#import "KSXMLWriter.h"


@implementation KSElementInfo

- (id)init;
{
    [super init];
    _attributes = [[NSMutableArray alloc] initWithCapacity:2];
    return self;
}

- (id)initWithElementInfo:(KSElementInfo *)info;
{
    self = [self init];
    
    [self setName:[info name]];
    _attributes = [info->_attributes mutableCopy];
    
    return self;
}

- (void)dealloc;
{
    [_elementName release];
    [_attributes release];
    
    [super dealloc];
}

@synthesize name = _elementName;

- (NSDictionary *)attributesAsDictionary;
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < [_attributes count]; i+=2)
    {
        NSString *attribute = [_attributes objectAtIndex:i];
        NSString *value = [_attributes objectAtIndex:i+1];
        [result setObject:value forKey:attribute];
    }
    
    return result;
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

- (void)close;  // sets name to nil and removes all attributes
{
    [self setName:nil];
    [_attributes removeAllObjects];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone;
{
    return [[[self class] alloc] initWithElementInfo:self];
}

#pragma mark Description

- (NSString *)description;
{
    NSMutableString *result = [NSMutableString stringWithString:[super description]];
    
    KSXMLWriter *writer = [[KSXMLWriter alloc] initWithOutputWriter:result];
    [writer writeString:@" "];
    
    [writer startElement:(self.name ? self.name : @"")
              attributes:[self attributesAsDictionary]];
    [writer endElement];
    
    [writer release];
    
    return result;
}

@end
