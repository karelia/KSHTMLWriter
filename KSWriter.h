//
//  KSWriter.h
//  Sandvox
//
//  Created by Mike on 14/02/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol KSWriter <NSObject>
- (void)writeString:(NSString *)string;
- (void)close;  // most writers will ignore, but others may use it to trigger an action
@end


@interface NSMutableString (KSWriter) <KSWriter>
@end