//  Created by Sam Deane on 27/01/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.

#import "KSHTMLWriterTestCase.h"

@implementation KSHTMLWriterTestCase


@synthesize dynamicTestName;
@synthesize dynamicTestParameter;

+ (id)testCaseWithSelector:(SEL)selector param:(id)param
{
    KSHTMLWriterTestCase* tc = [self testCaseWithSelector:selector];
    tc.dynamicTestParameter = param;
    
    return tc;
}

+ (id)testCaseWithSelector:(SEL)selector param:(id)param name:(NSString*)name
{
    KSHTMLWriterTestCase* tc = [self testCaseWithSelector:selector];
    tc.dynamicTestParameter = param;
    tc.dynamicTestName = name;
    
    return tc;
}

- (NSString*)name
{
    NSString* result;
    
    if (self.dynamicTestName)
    {
        result = [NSString stringWithFormat:@"-[%@ %@%@]", NSStringFromClass([self class]), NSStringFromSelector(self.selector), self.dynamicTestName];
    }
    else 
    {
       result = [super name];
    }
    
    return result;
}

- (void)assertString:(NSString*)string1 matchesString:(NSString*)string2
{
    NSUInteger length1 = [string1 length];
    NSUInteger length2 = [string2 length];
    
    STAssertTrue(length1 == length2, @"string lengths don't match: was %ld expected %ld \n\nwas:\n%@\n\nexpected:\n%@", length1, length2, string1, string2); 
    
    NSUInteger safeLength = MIN(length1, length2);
    for (NSUInteger n = 0; n < safeLength; ++n)
    {
        UniChar c1 = [string1 characterAtIndex:n];
        UniChar c2 = [string2 characterAtIndex:n];
        STAssertTrue(c1 == c2, @"Comparison failed at character %ld (was 0x%x '%c' expected 0x%x '%c') of:\n\n%@", n, c1, c1, c2, c2, string1);
        if (c1 != c2)
        {
            break; // in theory we could report every character difference, but it could get silly, so we stop after the first failure
        }
    }
}

@end
