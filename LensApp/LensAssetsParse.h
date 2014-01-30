//
//  LensAssetsParse.h
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LensRequest.h"
#import "LensAsset.h"
#import "LensPost.h"

#define     kTagData            @"data"
#define     kTagStory           @"story"
#define     kTagPhotos          @"photos"
#define     kTagSlide           @"slide"
#define     kTagPhoto           @"photo"
#define     kTagUrl             @"url"
#define     kTagCredit          @"credit"
#define     kTagCaption         @"caption"

/*
 <data>
     <story>
     <potd>true</potd>
     <galleryHeight>0</galleryHeight>
     <photos>
         <slide>
             <photo>
                 <credit>Gleb Garanich/Reuters</credit>
                 <caption>
                 Riot police officers drag a man away during clashes with antigovernment protesters in Kiev.
                 </caption>
                 <url>
                 http://graphics8.nytimes.com/images/2014/01/22/blogs/20140122POD-slide-FH88/20140122POD-slide-FH88-jumbo.jpg
                 </url>
                 <width>1024</width>
                 <height>665</height>
             </photo>
             <related>
                 <link>
                     <type>article</type>
                     <label/>
                     <url/>
                 </link>
             </related>
        </slide>
 */

@interface LensAssetsParse : LensRequest

@property NSManagedObjectID * postId;

- (instancetype)initWithData:(NSData *)parseData forPostObjectId:(NSManagedObjectID*)postId;

@end
