//
//  LensImage.m
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensImageCache.h"
#import "LensAppDelegate.h"
#import "LensNetworkController.h"

@implementation LensImageCache

-(instancetype)init{
    
    if(self =[super init]){
        //config
        [self setCountLimit:100];
        [self setDelegate:self];
    }
    return self;
}

-(void)cacheImage:(LensAssetImageWrapper*)image{
    
    NSString * key = image.intendedName;
    [self setObject:image forKey:key];
}

-(void)persistImage:(LensAssetImageWrapper*)image removeFromCache:(BOOL)remove{
    
    [self saveImage:(UIImage*)image withFileName:image.intendedName ofType:image.extension];
    
    //purge from cache
    if(remove)
        [self removeObjectForKey:image.intendedName];
}

-(UIImage*)retrieveImage:(NSString*)filename withAsset:(NSManagedObjectID*)assetId{
    
    //try cache
    LensAssetImageWrapper * image = [self objectForKey:filename];
    if(!image){
        //try UIImage cache
        UIImage * uiImage = [UIImage imageNamed:filename];
        if(!uiImage){
            //launch request to get it
            [[LensNetworkController sharedNetwork] getImageForAsset:assetId withPriority:NSOperationQueuePriorityHigh];
            //return nothing immediately
            return nil;
        }
        else{
            return uiImage;
        }
    } else {
        //increments count
        return image.image;
    }
}

-(UIImage*)retrieveIcon:(NSString*)filename withPost:(NSManagedObjectID*)postId{
    
    //try cache
    LensAssetImageWrapper * image = [self objectForKey:filename];
    if(!image){
        //try UIImage cache
        UIImage * uiImage = [UIImage imageNamed:filename];
        if(!uiImage){
            //launch request to get it
            [[LensNetworkController sharedNetwork] getIconForPost:postId];
            //return nothing immediately
            return nil;
        }
        else{
            return uiImage;
        }
    } else {
        //increments count
        return image.image;
    }
}

//-(UIImage *)loadImage:(NSString *)fileName ofType:(NSString *)extension{
//    
//    NSString * path = [NSString stringWithFormat:@"%@/%@.%@", [self imageDirectory], fileName, extension];
//    UIImage * result = [UIImage imageWithContentsOfFile:path];
//    return result;
//}

-(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension {
    
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        NSString * path = [[self imageDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]];
        [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        NSString * path = [[self imageDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
        NSError * error;
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:path options:NSAtomicWrite error:&error];
        if(error){
            NSLog(@"%@", [error description]);
        }
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

-(NSString*)imageDirectory{
    
    LensAppDelegate * app = [[UIApplication sharedApplication] delegate];
    NSURL * imageUrl = [[app applicationDocumentsDirectory] URLByAppendingPathComponent:@"images"];
    NSString * result = [imageUrl path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:result])
        [[NSFileManager defaultManager] createDirectoryAtPath:result withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    return result;
}

#pragma mark NSCacheDelegate

-(void)cache:(NSCache *)cache willEvictObject:(id)obj{
    
    //if evicted image should be saved, save it to file
    LensAssetImageWrapper * asset = obj;
    
    //look up associated asset
    if(asset){
        if(asset.getCount > 3){
            //persist
            [self persistImage:asset removeFromCache:NO];
        }
    }
}

@end
