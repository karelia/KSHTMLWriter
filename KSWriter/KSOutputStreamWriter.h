//
//  KSOutputStreamWriter.h
//  Sandvox
//
//  Created by Mike on 10/03/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//
//  Converts incoming strings to data and writes them to an NSOutputStream


#import <KSWriter.h>


@interface KSOutputStreamWriter : NSObject <KSWriter>
{
  @private
    NSOutputStream      *_outputStream;
    NSStringEncoding    _encoding;
}

- (id)initWithOutputStream:(NSOutputStream *)outputStream encoding:(NSStringEncoding)encoding;
- (id)initWithOutputStream:(NSOutputStream *)outputStream;  // uses UTF8 encoding

@property(nonatomic, readonly) NSStringEncoding encoding;

@end
