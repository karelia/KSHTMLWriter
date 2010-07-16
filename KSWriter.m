//
//  KSWriter.m
//  Sandvox
//
//  Created by Mike on 14/02/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSWriter.h"


@implementation NSMutableString (KSWriter)

- (void)writeString:(NSString *)string
{
    /*  This was some experimental code to see if it would speed up writing:
    const UniChar *characters = CFStringGetCharactersPtr((CFStringRef)string);
    if (characters)
    {
        CFStringAppendCharacters((CFMutableStringRef)self,
                                 characters,
                                 CFStringGetLength((CFStringRef)string));
    }
    else
    {
        CFStringAppend((CFMutableStringRef)self, (CFStringRef)string);
    }*/

    [self appendString:string];
}

- (void)close; { }  // do nothing as it makes no sense to close a mutable string

@end
