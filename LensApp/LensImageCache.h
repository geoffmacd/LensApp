//
//  LensImage.h
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LensAssetImageWrapper.h"

@interface LensImageCache : NSCache


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
-(void)persistImage:(LensAssetImageWrapper*)image;

/**
 * retrieves image intelligently from cache or from uiimage cache or from file system 
 * corrects positioning intelligently if it is being accessed too much
 * @author Geoff MacDonald
 *
 * @return singleton instance
 */
-(UIImage*)retrieveImage:(NSString*)filename;


-(NSString*)imageDirectory;

-(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension;
-(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension;
-(UIImage *) getImageFromURL:(NSString *)fileURL;
-(NSData *) getImageDataFromURL:(NSString *)fileURL;


@end
