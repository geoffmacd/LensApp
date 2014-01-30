//
//  LensStory.h
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LensPost;

@interface LensStory : NSManagedObject

@property (nonatomic, retain) NSString * htmlContent;
@property (nonatomic, retain) LensPost *post;

@end
