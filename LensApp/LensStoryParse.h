//
//  LensStoryParse.h
//  LensApp
//
//  Created by Xtreme Dev on 1/31/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensRequest.h"

#import "LensStory.h"
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

@interface LensStoryParse : LensRequest

@property NSManagedObjectID * postId;

- (instancetype)initWithPostObjectId:(NSManagedObjectID*)postId forData:(NSData*)data;

@end
