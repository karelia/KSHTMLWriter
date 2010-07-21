//
//  KSHTMLWriter.h
//  Sandvox
//
//  Created by Mike on 23/02/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//


#import "KSXMLWriter.h"


@interface KSHTMLWriter : KSXMLWriter
{
  @private
    BOOL    _isXHTML;
}

#pragma mark Creating an HTML Writer
// For if you desperately need to set a doctype before calling -startDocument:isXHTML: (perhaps because you're not going to call it!)
- (id)initWithOutputWriter:(id <KSWriter>)stream isXHTML:(BOOL)isXHTML;


#pragma mark XHTML
// Whether empty elements should be written as <FOO> or <FOO />
// Default is YES. There's no setter method; instead, specify with -startDocument:isXHTML: or when initializing.
@property(nonatomic, readonly, getter=isXHTML) BOOL XHTML;


#pragma mark Document
- (void)startDocument:(NSString *)DTD isXHTML:(BOOL)isXHTML;


#pragma mark HTML Fragments
- (void)writeHTMLString:(NSString *)html;
- (void)writeHTMLFormat:(NSString *)format , ...;


#pragma mark General

//  <tagName id="idName" class="className">
//  Pretty standard convenience methods

- (void)startElement:(NSString *)tagName;
- (void)startElement:(NSString *)tagName className:(NSString *)className;

- (void)startElement:(NSString *)tagName   
              idName:(NSString *)idName
           className:(NSString *)className;


#pragma mark Line Break
// <br />   OR  <br>
// depends on isXHTML
- (void)writeLineBreak;


#pragma mark Links
//  <a href="...." target="..." rel="nofollow">
- (void)startAnchorElementWithHref:(NSString *)href title:(NSString *)titleString target:(NSString *)targetString rel:(NSString *)relString;


#pragma mark Images
//  <img src="..." alt="..." width="..." height="..." />
- (void)writeImageWithIdName:(NSString *)idName
                   className:(NSString *)className
                         src:(NSString *)src
                         alt:(NSString *)alt
                       width:(NSString *)width
                      height:(NSString *)height;


#pragma mark Link

//  <link>
//  Goes in <head> to link to scripts, CSS, etc.
- (void)writeLinkWithHref:(NSString *)href
                     type:(NSString *)type
                      rel:(NSString *)rel
                    title:(NSString *)title
                    media:(NSString *)media;

- (void)writeLinkToStylesheet:(NSString *)href
                        title:(NSString *)title
                        media:(NSString *)media;


#pragma mark Scripts

- (void)writeJavascriptWithSrc:(NSString *)src;

// Like -startCDATA and -endCDATA, but wrapped in a javascript comment so don't risk tripping up a browser's interpreter
- (void)startJavascriptCDATA;
- (void)endJavascriptCDATA;

- (void)writeScriptSrc:(NSString *)src			// Note: You should either use src OR contents, not both.
			orContents:(NSString *)contents	// However you can specify contents for comments, which is OK.
			  useCDATA:(BOOL)useCDATA;


#pragma mark Style
- (void)startStyleElementWithType:(NSString *)type;


#pragma mark Elements Stack
- (BOOL)topElementIsList;


#pragma mark Element Primitives
//   />    OR    >
//  Which is used depends on -isXHTML
- (void)closeEmptyElementTag;             


@end

