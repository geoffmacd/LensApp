//
//  LensPost.h
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LensAsset, LensAuthor, LensStory;

@interface LensPost : NSManagedObject

@property (nonatomic, retain) NSString * assetUrl;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * excerpt;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * localIconUrl;
@property (nonatomic, retain) NSString * storyUrl;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *assets;
@property (nonatomic, retain) LensAuthor *author;
@property (nonatomic, retain) LensStory *story;
@property (nonatomic, retain) NSOrderedSet *tags;
@end

@interface LensPost (CoreDataGeneratedAccessors)

- (void)insertObject:(LensAsset *)value inAssetsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAssetsAtIndex:(NSUInteger)idx;
- (void)insertAssets:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAssetsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAssetsAtIndex:(NSUInteger)idx withObject:(LensAsset *)value;
- (void)replaceAssetsAtIndexes:(NSIndexSet *)indexes withAssets:(NSArray *)values;
- (void)addAssetsObject:(LensAsset *)value;
- (void)removeAssetsObject:(LensAsset *)value;
- (void)addAssets:(NSOrderedSet *)values;
- (void)removeAssets:(NSOrderedSet *)values;
- (void)insertObject:(NSManagedObject *)value inTagsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTagsAtIndex:(NSUInteger)idx;
- (void)insertTags:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTagsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTagsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceTagsAtIndexes:(NSIndexSet *)indexes withTags:(NSArray *)values;
- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSOrderedSet *)values;
- (void)removeTags:(NSOrderedSet *)values;
@end
