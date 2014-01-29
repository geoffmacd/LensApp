//
//  LensTag.h
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LensPost;

@interface LensTag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) LensPost *posts;

@end
