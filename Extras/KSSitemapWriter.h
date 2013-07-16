//
//  KSSitemapWriter.h
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