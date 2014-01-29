//
//  LensStory.h
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LensPost.h"

@class LensPost;

@interface LensStory : LensPost

@property (nonatomic, retain) NSString * htmlContent;
@property (nonatomic, retain) LensPost *post;

@end
