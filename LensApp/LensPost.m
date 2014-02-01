//
//  LensPost.m
//  LensApp
//
//  Created by Geoff MacDonald on 1/31/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensPost.h"
#import "LensAsset.h"
#import "LensAuthor.h"
#import "LensStory.h"
#import "LensTag.h"


@implementation LensPost

@dynamic assetUrl;
@dynamic date;
@dynamic excerpt;
@dynamic iconUrl;
@dynamic storyUrl;
@dynamic title;
@dynamic iconFile;
@dynamic iconExtension;
@dynamic assets;
@dynamic author;
@dynamic story;
@dynamic tags;

//hack for broken CoreDataGeneratedAccessors method
- (void)addAssetsObject:(LensAsset *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.assets];
    [tempSet addObject:value];
    self.assets = tempSet;
}

- (void)addTagsObject:(LensTag *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.tags];
    [tempSet addObject:value];
    self.tags = tempSet;
}

@end
