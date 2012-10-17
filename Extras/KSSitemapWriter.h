//
//  KSSitemapWriter.h
//  Sandvox
//
//  Created by Mike Abdullah on 10/03/2012.
//  Copyright (c) 2012 Karelia Software. All rights reserved.
//
//  An implementation of the Sitemap protocol <http://www.sitemaps.org/> built atop KSXMLWriter
//


#import <KSHTMLWriterFramework/KSHTMLWriterFramework.h>


extern NSString * const KSSitemapChangeMapFrequencyAlways;
extern NSString * const KSSitemapChangeMapFrequencyHourly;
extern NSString * const KSSitemapChangeMapFrequencyDaily;
extern NSString * const KSSitemapChangeMapFrequencyWeekly;
extern NSString * const KSSitemapChangeMapFrequencyMonthly;
extern NSString * const KSSitemapChangeMapFrequencyYearly;
extern NSString * const KSSitemapChangeMapFrequencyNever;

extern NSUInteger const KSSitemapMaxURLLength;
extern NSUInteger const KSSitemapMaxNumberOfURLs;

// The official spec is 10MB which we declare here. However, Google say they accept up to 50MB <http://support.google.com/webmasters/bin/answer.py?hl=en&answer=183668&topic=8476&ctx=topic#1>
extern NSUInteger const KSSitemapMaxFileSize;


@interface KSSitemapWriter : NSObject
{
  @private
    KSXMLWriter *_writer;
}

- (id)initWithOutputWriter:(id <KSWriter>)output;

// URL is compulsary; all else optional
- (void)writeURL:(NSURL *)loc           // should be sub-path of the folder containing the sitemap. avoid exceeding KSSitemapMaxURLLength
modificationDate:(NSDate *)lastMod
 changeFrequency:(NSString *)changeFreq
        priority:(NSNumber *)priority;  // between 0 and 1. If nil, search engines assume 0.5

// Call when done writing URLs to properly end the XML document
- (void)close;

@end


#pragma mark -


extern NSUInteger const KSSitemapIndexMaxNumberOfSitemaps;    // the FAQ <http://www.sitemaps.org/faq.html> claims 1,000 as the limit, but the protocol spec and everything else disagrees
extern NSUInteger const KSSitemapIndexMaxFileSize; // 10MB


@interface KSSitemapIndexWriter : NSObject
{
  @private
    KSXMLWriter *_writer;
}

- (id)initWithOutputWriter:(id <KSWriter>)output;

// URL is compulsary; all else optional
- (void)writeSitemapWithLocation:(NSURL *)loc modificationDate:(NSDate *)lastMod;

// Call when done writing sitemaps to properly end the XML document
- (void)close;

@end