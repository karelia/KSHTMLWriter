//
//  KSMutableDataWriter.h
//  Sandvox
//
//  Created by Mike on 12/03/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

#import "KSWriter.h"


@interface KSMutableDataWriter : NSObject <KSWriter>
{
  @private
    NSMutableData       *_data;
    NSStringEncoding    _encoding;
}

- (id)initWithMutableData:(NSMutableData *)data encoding:(NSStringEncoding)encoding;

@property(nonatomic, readonly) NSStringEncoding encoding;

@end
