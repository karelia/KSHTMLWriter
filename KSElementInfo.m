//
//  KSElementInfo.m
//  Sandvox
//
//  Created by Mike on 19/11/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSElementInfo.h"


@implementation KSElementInfo

- (void)dealloc;
{
    [_elementName release];
    [_attributes release];
    
    [super dealloc];
}

@synthesize name = _elementName;
@synthesize attributesAsDictionary = _attributes;

@end
