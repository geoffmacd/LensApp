//
//  LensAsset.h
//  LensApp
//
//  Created by Xtreme Dev on 1/28/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "LensPost.h"


@interface LensAsset : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * credit;
@property (nonatomic) float height;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * localUrl;
@property (nonatomic) float width;
@property (nonatomic, retain) LensPost *post;

@end