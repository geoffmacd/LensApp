//
//  LensNetworkController.h
//  LensApp
//
//  Created by Xtreme Dev on 1/28/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LensAuthor.h"
#import "LensPost.h"
#import "LensStory.h"
#import "LensAsset.h"

#define AssetDataUrl        @"http://lens.blogs.nytimes.com/asset-data/"


@interface LensNetworkController : NSObject

@property NSOperationQueue * queue;
@property NSURLSession * session;


-(instancetype)init;

/**
 * returns shared network controller to be used between both views with the same object context
 * @author Geoff MacDonald
 *
 * @return singleton instance
 */
+(LensNetworkController*)sharedNetwork;

/**
 * retrieves all current posts with call from /asset-data
 * @author Geoff MacDonald
 *
 */
-(void)getCurrentPosts;

/**
 * returns posts of a particular time period by extrapolating dates and returning correct html content
 * @author Geoff MacDonald
 *
 * @param NSDate starting date
 * @param NSDate ending date
 * @return NSArray of LensPost
 */
-(NSArray*)getArchivePosts:(NSDate*)startDate withEnd:(NSDate*)endDate;

/**
 * requests and parses html content for post and formats correctly for uiwebview load in LensStory
 * @author Geoff MacDonald
 *
 * @param LensPost to get story for
 * @return LensStory
 */
-(void)getStoryForPost:(NSManagedObjectID *)postId;

/**
 * requests pictures for a post
 * @author Geoff MacDonald
 *
 * @param NSManagedObjectID of post to get assets for
 */
-(void)getAssetsForPost:(NSManagedObjectID*)postId;

/**
 * requests image asset
 * @author Geoff MacDonald
 *
 * @param LensPost to get icon for
 * @param priority to set on queue
 */
-(void)getImageForAsset:(NSManagedObjectID*)assetId withPriority:(NSOperationQueuePriority)priority;


/**
 * requests image asset
 * @author Geoff MacDonald
 *
 * @param LensPost to get icon for
 */
-(void)triggerRemainingAssets:(NSManagedObjectID*)postId;


/**
 * requests icon for post
 * @author Geoff MacDonald
 *
 * @param LensPost to get icon for
 */
-(void)getIconForPost:(NSManagedObjectID*)postId;

@end
