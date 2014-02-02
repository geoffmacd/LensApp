//
//  UIImage+UILensImage.h
//  LensApp
//
//  Created by Geoff MacDonald on 2/2/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UILensImage)

+(UIImage*)lensImageNamed:(NSString*)filename withAsset:(NSManagedObjectID*)assetId;
+(UIImage*)lensIconNamed:(NSString*)filename withPost:(NSManagedObjectID*)postId;
@end
