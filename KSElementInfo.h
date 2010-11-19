//
//  KSElementInfo.h
//  Sandvox
//
//  Created by Mike on 19/11/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KSElementInfo : NSObject <NSCopying>
{
  @private
    NSString        *_elementName;
    NSMutableArray  *_attributes;
}

@property(nonatomic, copy) NSString *name;

@property(nonatomic, copy) NSDictionary *attributesAsDictionary;
- (void)addAttribute:(NSString *)attribute value:(id)value;


@end
