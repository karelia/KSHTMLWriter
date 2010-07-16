//
//  KSStringXMLEntityEscaping.h
//  Sandvox
//
//  Created by Mike on 21/06/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSWriter.h"


@interface NSString (KSStringXMLEntityEscaping)

#pragma mark XML
#if !TARGET_OS_IPHONE
- (NSString *)stringByEscapingXMLEntities:(NSDictionary *)entities;
#endif
- (NSString *)stringByUnescapingXMLEntities:(NSDictionary *)entities;


#pragma mark HTML
- (NSString *)stringByEscapingHTMLEntities;
- (NSString *)stringByEscapingHTMLEntitiesWithQuot:(BOOL)escapeQuotes;


@end


#pragma mark -


// Simply passes through strings, but escapes them first
@interface KSEscapedXMLEntitiesWriter : NSObject <KSWriter>
{
@private
    id <KSWriter>   _output;
}

- (id)initWithOutputWriter:(id <KSWriter>)output;
- (void)close;  // releases output writer

@end
