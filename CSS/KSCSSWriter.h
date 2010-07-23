//
//  KSCSSWriter.h
//  Sandvox
//
//  Created by Mike on 23/07/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "KSForwardingWriter.h"


@interface KSCSSWriter : KSForwardingWriter

// Writes the string followed enough newlines to carry on writing
- (void)writeCSSString:(NSString *)cssString;

@end
