//
//  LensStory.h
//  LensApp
//
//  Created by Xtreme Dev on 1/28/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LensPost;

@interface LensStory : NSManagedObject

@property (nonatomic, strong) NSString * htmlContent;
@property (nonatomic, strong) LensPost * post;

@end
