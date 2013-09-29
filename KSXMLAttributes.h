//
//  KSXMLAttributes.h
//  Sandvox
//
//  Created by Mike Abdullah on 19/11/2010.
//  Copyright © 2010 Karelia Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
