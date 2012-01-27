//
//  KSXMLWriterCompoundTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 27/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriterTestCase.h"
#import "KSXMLWriter.h"
#import "KSStringWriter.h"

#pragma mark - Unit Tests Interface

@interface KSXMLWriterCompoundTests : KSHTMLWriterTestCase
@end

#pragma mark - Unit Tests Implementation

@implementation KSXMLWriterCompoundTests

#pragma mark - Helpers

- (void)writer:(KSXMLWriter*)writer performActions:(NSArray*)actions
{
    for (NSDictionary* action in actions)
    {
        NSArray* content = [action objectForKey:@"content"];
        NSDictionary* attributes = [action objectForKey:@"attributes"];

        NSString* comment = [action objectForKey:@"comment"];
        if (comment)
        {
            [writer writeComment:comment];
        }

        NSString* text = [action objectForKey:@"text"];
        if (text)
        {
            [writer writeCharacters:text];
        }

        NSDictionary* push = [action objectForKey:@"push"];
        if (push)
        {
            for (NSString* key in push)
            {
                [writer pushAttribute:key value:[attributes objectForKey:key]];
            }
        }
        
        NSString* element = [action objectForKey:@"element"];
        if (element)
        {
            [writer writeElement:element attributes:attributes content:^{
                [self writer:writer performActions:content];
            }];
        }

    }
}

#pragma mark - Tests

- (void)testCompound
{
    NSURL* plist = [[NSBundle bundleForClass:[self class]] URLForResource:@"XML Tests" withExtension:@"plist"];
    NSArray* tests = [NSArray arrayWithContentsOfURL:plist];
    for (NSDictionary* test in tests)
    {
        KSStringWriter* output = [[KSStringWriter alloc] init];
        KSXMLWriter* writer = [[KSXMLWriter alloc] initWithOutputWriter:output];

        NSArray* actions = [test objectForKey:@"actions"];
        NSString* expected = [test objectForKey:@"expected"];
        [self writer:writer performActions:actions];
        
        NSString* generated = [output string];
        [self assertString:generated matchesString:expected];

        [writer release];
        [output release];
    }
}

@end
