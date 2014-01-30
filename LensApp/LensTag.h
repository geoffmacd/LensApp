//
//  LensTag.h
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LensPost;

@interface LensTag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *posts;
@end

@interface LensTag (CoreDataGeneratedAccessors)

- (void)addPostsObject:(LensPost *)value;
- (void)removePostsObject:(LensPost *)value;
- (void)addPosts:(NSSet *)values;
- (void)removePosts:(NSSet *)values;

@end
