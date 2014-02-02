//
//  UIImage+UILensImage.m
//  LensApp
//
//  Created by Geoff MacDonald on 2/2/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "UIImage+UILensImage.h"

#import "LensNetworkController.h"
#import "LensImageCache.h"

@implementation UIImage (UILensImage)

+(UIImage*)lensImageNamed:(NSString*)filename withAsset:(NSManagedObjectID*)assetId{
    
    return [[[LensNetworkController sharedNetwork] imageCache] retrieveImage:filename withAsset:assetId];
}

+(UIImage*)lensIconNamed:(NSString*)filename withPost:(NSManagedObjectID*)postId{
    
    return [[[LensNetworkController sharedNetwork] imageCache] retrieveIcon:filename withPost:postId];
}

@end
