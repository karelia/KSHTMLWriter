//
//  KSSitemapWriter.m
//  Sandvox
//
//  Created by Mike Abdullah on 10/03/2012.
//  Copyright © 2012 Karelia Software
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

#import "KSSitemapWriter.h"


NSString * const KSSitemapChangeMapFrequencyAlways = @"always";
NSString * const KSSitemapChangeMapFrequencyHourly = @"hourly";
NSString * const KSSitemapChangeMapFrequencyDaily = @"daily";
NSString * const KSSitemapChangeMapFrequencyWeekly = @"weekly";
NSString * const KSSitemapChangeMapFrequencyMonthly = @"monthly";
NSString * const KSSitemapChangeMapFrequencyYearly = @"yearly";
NSString * const KSSitemapChangeMapFrequencyNever = @"never";

NSUInteger const KSSitemapMaxURLLength = 2048;
NSUInteger const KSSitemapMaxNumberOfURLs = 50000;
NSUInteger const KSSitemapMaxFileSize = 10485760;

NSUInteger const KSSitemapIndexMaxNumberOfSitemaps = 50000;
NSUInteger const KSSitemapIndexMaxFileSize = 10485760;


@implementation KSSitemapWriter

- (id)initWithOutputWriter:(KSWriter *)output;
{
    OBPRECONDITION(output.encoding == NSUTF8StringEncoding);
    
    if (self = [self init])
    {
        _writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
        [_writer writeString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
        
        [_writer pushAttribute:@"xmlns" value:@"http://www.sitemaps.org/schemas/sitemap/0.9"];
        [_writer startElement:@"urlset"];
    }
    
    return self;
}

- (void)writeURL:(NSURL *)loc modificationDate:(NSDate *)lastMod changeFrequency:(NSString *)changeFreq priority:(NSNumber *)priority;
{
    [_writer writeElement:@"url" content:^{
        [_writer writeElement:@"loc" text:[loc absoluteString]];
        
        if (lastMod)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSString *lastModText = [lastMod descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ"
                                                                  timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]
                                                                    locale:nil];
#pragma clang diagnostic pop
            [_writer writeElement:@"lastmod" text:lastModText];
        }
        
        if (changeFreq) [_writer writeElement:@"changefreq" text:changeFreq];
        if (priority) [_writer writeElement:@"priority" text:[NSString stringWithFormat:@"%.02f", [priority floatValue]]];
    }];
}

- (void)close;
{
    [_writer endElement];   // </urlset>
    [_writer release]; _writer = nil;
}

- (void)dealloc
{
    [self close];   // releases _writer
    [super dealloc];
}

@end


#pragma mark -


@implementation KSSitemapIndexWriter

- (id)initWithOutputWriter:(KSWriter *)output;
{
    OBPRECONDITION(output.encoding == NSUTF8StringEncoding);
    
    if (self = [self init])
    {
        _writer = [[KSXMLWriter alloc] initWithOutputWriter:output];
        [_writer writeString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
        
        [_writer pushAttribute:@"xmlns" value:@"http://www.sitemaps.org/schemas/sitemap/0.9"];
        [_writer startElement:@"sitemapindex"];
    }
    
    return self;
}

- (void)writeSitemapWithLocation:(NSURL *)loc modificationDate:(NSDate *)lastMod;
{
    [_writer writeElement:@"sitemap" content:^{
        [_writer writeElement:@"loc" text:[loc absoluteString]];
        
        if (lastMod)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSString *lastModText = [lastMod descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ"
                                                                  timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]
                                                                    locale:nil];
#pragma clang diagnostic pop
            [_writer writeElement:@"lastmod" text:lastModText];
        }
    }];
}

- (void)close;
{
    [_writer endElement];   // </urlset>
    [_writer release]; _writer = nil;
}

- (void)dealloc
{
    [self close];   // releases _writer
    [super dealloc];
}

@end