//
//  LensPost.h
//  LensApp
//
//  Created by Xtreme Dev on 1/28/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LensStory;
@class LensAuthor;

@interface LensPost : NSManagedObject

@property (nonatomic,strong) NSDate * date;
@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * excerpt;
@property (nonatomic,strong) NSString * byline;
@property (nonatomic,strong) NSString * iconUrl;
@property (nonatomic,strong) NSString * localIconUrl;
@property (nonatomic,strong) NSString * storyUrl;
@property (nonatomic,strong) NSString * assetUrl;
@property (nonatomic,strong) LensAuthor * author;
@property (nonatomic,strong) LensStory * story;
@property (nonatomic,strong) NSSet * assets;
@property (nonatomic,strong) NSSet * tags;

@end
