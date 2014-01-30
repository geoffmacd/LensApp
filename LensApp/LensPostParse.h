//
//  LensAssetDataParse.h
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LensRequest.h"
#import "LensPost.h"

#define     kTagData            @"data"
#define     kTagPosts           @"posts"
#define     kTagPost            @"post"
#define     kTagTitle           @"title"
#define     kTagByline          @"byline"
#define     kTagDate            @"date"
#define     kTagKeyword         @"keywords"
#define     kTagTags            @"tags"
#define     kTagExcerpt         @"excerpt"
#define     kTagURL             @"url"
#define     kTagPhoto           @"photo"
#define     kTagAsset           @"asset"

/*
<data>
 <posts>
 <post>
 <title>Scars, Visible and Invisible, in Bosnia</title>
 <byline></byline>
 <date>January 29, 2014, 05:00 am</date>
 <keywords></keywords>
 <tags>Bosnia,Bosnia and Herzegovina,Bosnian conflict,Croatia,International Commission on Missing Persons,Kerri MacDonald,Matteo Bastianelli,Sarajevo,Serbia,Showcase,Srebrenica,The Bosnian Identity,Tomislav Nikolic</tags>
 <excerpt>The emotional wounds of the 1992-95 war in Bosnia are still so deep that even an ostensibly simple question, &#8220;How old are you?,&#8221; produces fraught answers.</excerpt>
 <url>http://lens.blogs.nytimes.com/2014/01/29/scars-visible-and-invisible-in-bosnia/</url>
 <photo>
 <url>http://graphics8.nytimes.com/images/2014/01/28/blogs/20140128-lens-bastianelli-slide-VSL2/20140128-lens-bastianelli-slide-VSL2-custom2.jpg</url>
 </photo>
 <asset>http://graphics8.nytimes.com/packages/flash/multimedia/TEMPLATES/Lens/data/20140128-lens-bastianelli.xml</asset>
 </post>
 */


@interface LensPostParse : LensRequest

@property NSMutableArray * postArray;


- (instancetype)initWithData:(NSData *)parseData;

@end
