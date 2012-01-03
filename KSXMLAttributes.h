//
//  KSXMLAttributes.h
//  Sandvox
//
//  Created by Mike on 19/11/2010.
//  Copyright 2010-2012 Karelia Software. All rights reserved.
//

//  A subclass of NSDictionary that is slightly mutable, and preserves ordering

#import <Foundation/Foundation.h>


@interface KSXMLAttributes : NSDictionary
{
  @private
    NSMutableArray  *_attributes;
}

- (id)initWithXMLAttributes:(KSXMLAttributes *)info;

// Unlike NSDictionary, no protection is provided against duplicate keys, to improve performance. If you do add the same key twice, it will appear twice while enumerating, but which value is reported for it is indeterminate
- (void)addAttribute:(NSString *)attribute value:(id)value;

- (void)close;  // removes all attributes


@end
