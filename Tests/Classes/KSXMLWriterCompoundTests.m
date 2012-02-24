//
//  KSXMLWriterCompoundTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 27/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "ECDynamicTestCase.h"
#import "KSXMLWriter.h"
#import "KSHTMLWriter.h"
#import "KSStringWriter.h"

#pragma mark - Unit Tests Interface

@interface KSXMLWriterCompoundTests : ECDynamicTestCase
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

typedef enum
{
    TestXML,
    TestHTML
} TestType;

- (void)testCompoundWithTestType:(TestType)type
{
    Class class;
    NSString* expectedKey;
    
    switch (type) 
    {
        case TestXML:
            class = [KSXMLWriter class];
            expectedKey = @"expected-xml";
            break;
            
        default:
            class = [KSHTMLWriter class];
            expectedKey = @"expected-html";
            break;
    }

    NSDictionary* test = self.dynamicTestParameter;
    KSStringWriter* output = [[KSStringWriter alloc] init];
    KSXMLWriter* writer = [[class alloc] initWithOutputWriter:output];

    NSArray* actions = [test objectForKey:@"actions"];
    NSString* expected = [test objectForKey:expectedKey];
    [self writer:writer performActions:actions];
    
    NSString* generated = [output string];
    [self assertString:generated matchesString:expected];

    [writer release];
    [output release];
}

- (void)dynamicTestCompoundXML
{
    [self testCompoundWithTestType:TestXML];
}

- (void)dynamicTestCompoundHTML
{
    [self testCompoundWithTestType:TestHTML];
}

@end
