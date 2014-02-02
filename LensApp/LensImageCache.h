//
//  LensImage.h
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LensAssetImageWrapper.h"

@interface LensImageCache : NSCache <NSCacheDelegate>


/**
 * returns subclassed nscache configured for image storage
 * @author Geoff MacDonald
 *
 * @return singleton instance
 */
-(instancetype)init;

/**
 * saves image to cache
 * @author Geoff MacDonald
 *
 * @return singleton instance
 */
-(void)cacheImage:(LensAssetImageWrapper*)image;

/**
 * saves image to disk, while purging from cache
 * @author Geoff MacDonald
 *
 * @return singleton instance
 */
-(void)persistImage:(LensAssetImageWrapper*)image removeFromCache:(BOOL)remove;

/**
 * retrieves image intelligently from cache or from uiimage cache or from file system 
 * corrects positioning intelligently if it is being accessed too much
 * @author Geoff MacDonald
 *
 * @return UIImage if immediately available
 */
-(UIImage*)retrieveImage:(NSString*)filename withAsset:(NSManagedObjectID*)assetId;

-(UIImage*)retrieveIcon:(NSString*)filename withPost:(NSManagedObjectID*)postId;

/**
 * retrieves image intelligently from cache or from uiimage cache or from file system
 * corrects positioning intelligently if it is being accessed too much
 * @author Geoff MacDonald
 *
 * @param uiimage to save
 * @param filename without ext
 * @param and extension
 */
-(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension;

//-(NSString*)imageDirectory;

//-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension;

@end
