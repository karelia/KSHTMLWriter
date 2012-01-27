//
//  KSHTMLWriterTests.m
//  KSHTMLWriterTests
//
//  Created by Sam Deane on 18/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//

#import "KSHTMLWriterTestCase.h"
#import "KSXMLWriter.h"
#import "KSStringWriter.h"

#pragma mark - Helper Class - For Compound Tests

typedef enum
{
    TestElement,
    TestComment,
    TestPush,
} TestType;


#pragma mark - Unit Tests Interface

@interface KSXMLWriterCompoundTests : KSHTMLWriterTestCase
{
    KSStringWriter* output;
    KSXMLWriter* writer;
}
@end

#pragma mark - Unit Tests Implementation

@implementation KSXMLWriterCompoundTests

#pragma mark - Setup / Teardown

- (void)setUp
{
    output = [[KSStringWriter alloc] init];
    writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
}

- (void)tearDown
{
    [output release];
    [writer release];
}

#pragma mark - Helpers

- (void)writeWithActions:(NSArray*)actions
{
    for (NSDictionary* action in actions)
    {
        NSArray* subactions = [action objectForKey:@"actions"];
        NSDictionary* attributes = [action objectForKey:@"attributes"];

        NSString* comment = [action objectForKey:@"pre-comment"];
        if (comment)
        {
            [writer writeComment:comment];
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
                [self writeWithActions:subactions];
            }];
        }

        NSString* text = [action objectForKey:@"text"];
        if (text)
        {
            [writer writeCharacters:text];
        }
        
        comment = [action objectForKey:@"post-comment"];
        if (comment)
        {
            [writer writeComment:comment];
        }
    }
}

#pragma mark - Tests

- (void)testCompound
{
    NSURL* plist = [[NSBundle mainBundle] URLForResource:@"XML Tests" withExtension:@"plist"];
    NSArray* actions = [NSArray arrayWithContentsOfURL:plist];
    [self writeWithActions:actions];
}
@end
