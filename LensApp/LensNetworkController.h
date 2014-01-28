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

@protocol LensNetworkDelegate <NSObject>

@end


@interface LensNetworkController : NSObject <NSXMLParserDelegate>



-(instancetype)init;

/**
 * returns shared network controller to be used between both views with the same object context
 * @author Geoff MacDonald
 *
 * @return singleton instance
 */
+(LensNetworkController*)sharedNetwork;

/**
 * returns current posts as call from /assetdata would
 * @author Geoff MacDonald
 *
 * @return NSArray of LensPost
 */
-(NSArray*)getCurrentPosts;

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
-(LensStory*)getStoryForPost:(LensPost*)post;

/**
 * requests pictures for a post
 * @author Geoff MacDonald
 *
 * @param LensPost to get assets for
 * @return LensAssets
 */
-(NSArray*)getAssetsForPost:(LensPost*)post;

/**
 * requests icon for post
 * @author Geoff MacDonald
 *
 * @param LensPost to get icon for
 * @return LensIcon
 */
-(UIImage*)getIconForPost:(LensPost*)post;

@end
