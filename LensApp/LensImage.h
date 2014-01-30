//
//  LensImage.h
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LensImage : NSObject

+(NSString*)imageDirectory;
+(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension;
+(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension;
+(UIImage *) getImageFromURL:(NSString *)fileURL;
+(NSData *) getImageDataFromURL:(NSString *)fileURL;
+(void)saveImageData:(NSData *)imageData withFileName:(NSString *)imageName ofType:(NSString *)extension ;

@end
