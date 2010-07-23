//
//  KSCSSWriter.m
//  Sandvox
//
//  Created by Mike on 23/07/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSCSSWriter.h"


@implementation KSCSSWriter

- (void)writeCSSString:(NSString *)cssString;
{
    [self writeString:cssString];
    if (![cssString hasSuffix:@"\n"]) [self writeString:@"\n"];
    [self writeString:@"\n"];
}

- (void)writeIDSelector:(NSString *)ID;
{
    [self writeString:@"#"];
    [self writeString:ID];
}

@end
