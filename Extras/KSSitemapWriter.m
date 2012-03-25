//
//  KSSitemapWriter.m
//  Sandvox
//
//  Created by Mike Abdullah on 10/03/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
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

- (id)initWithOutputWriter:(id <KSWriter>)output;
{
    if (self = [self init])
    {
        _writer = [[KSXMLWriter alloc] initWithOutputWriter:output encoding:NSUTF8StringEncoding];
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
            NSString *lastModText = [lastMod descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ"
                                                                  timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]
                                                                    locale:nil];
            
            [_writer writeElement:@"lastmod" text:lastModText];
        }
        
        if (changeFreq) [_writer writeElement:@"changefreq" text:changeFreq];
        if (priority) [_writer writeElement:@"priority" text:[NSString stringWithFormat:@"%.02f", [priority floatValue]]];
    }];
}

- (void)close;
{
    [_writer endElement];   // </urlset>
    [_writer close];
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

- (id)initWithOutputWriter:(id <KSWriter>)output;
{
    if (self = [self init])
    {
        _writer = [[KSXMLWriter alloc] initWithOutputWriter:output encoding:NSUTF8StringEncoding];
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
            NSString *lastModText = [lastMod descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ"
                                                                  timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]
                                                                    locale:nil];
            
            [_writer writeElement:@"lastmod" text:lastModText];
        }
    }];
}

- (void)close;
{
    [_writer endElement];   // </urlset>
    [_writer close];
    [_writer release]; _writer = nil;
}

- (void)dealloc
{
    [self close];   // releases _writer
    [super dealloc];
}

@end