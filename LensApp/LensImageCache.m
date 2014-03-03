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
#import "LensPost.h"
#import "LensAsset.h"


@implementation LensImageCache

-(instancetype)init{
    
    if(self =[super init]){
        //config
//        [self setCountLimit:300];
        [self setDelegate:self];
        count = 0;
    }
    return self;
}

-(void)cacheImage:(LensAssetImageWrapper*)image{
    
    //if tried before
    
    count++;
    
    NSString * key = image.intendedName;
    [self setObject:image forKey:key];
    
    image = [self objectForKey:key];
    
    //notify view controllers image is available
    if(image.assetId){   //only images not icons
        __block NSString * name = image.intendedName;
        __block NSManagedObjectID * asset = image.assetId;
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:@{@"assetId":asset}];
    }
}

-(void)persistImage:(LensAssetImageWrapper*)image removeFromCache:(BOOL)remove{
    
    //do not resave if already exits on filesystem
    if(!image.isPersisted){
        
        NSLog(@"persisting image: %@", image.intendedName);
        [self saveImage:image];
    }
    
    //purge from cache
    if(remove){
        [self removeObjectForKey:image.intendedName];
        count--;
    }
}

-(UIImage*)retrieveImage:(NSString*)filename withAsset:(NSManagedObjectID*)assetId doNotRequest:(BOOL)doNotRequest{
    
    //try cache
    LensAssetImageWrapper * image = [self objectForKey:filename];
    if(!image){
        //try file system, do not save to cache
        if(![[NSFileManager defaultManager] fileExistsAtPath:[[self imageDirectory] stringByAppendingPathComponent:filename]]){
            if(!doNotRequest){
                //launch request to get it
                [[LensNetworkController sharedNetwork] getImageForAsset:assetId withPriority:NSOperationQueuePriorityHigh];
                NSLog(@"retrieving image miss, fetch: %@", filename);
            }
            //return nothing immediately
            return nil;
        }
        else{
            UIImage * uiImage = [UIImage imageWithContentsOfFile:[[self imageDirectory] stringByAppendingPathComponent:filename]];
            //create wrapper and cache
            LensAssetImageWrapper * wrapper = [[LensAssetImageWrapper alloc] initWithName:filename assetId:assetId];
            [wrapper setIsPersisted:YES];
            wrapper.image = uiImage;
            [self cacheImage:wrapper];
            
            NSLog(@"retrieving filesystem image: %@", filename);
            return uiImage;
        }
    } else {
        
        NSLog(@"retrieving cached image: %@", filename);
        
        //increments count
        return image.image;
    }
}

-(UIImage*)retrieveIcon:(NSString*)filename withPost:(NSManagedObjectID*)postId doNotRequest:(BOOL)doNotRequest{
        
    //try cache
    LensAssetImageWrapper * image = [self objectForKey:filename];
    if(!image){
        //try file system, do not save to cache
        if(![[NSFileManager defaultManager] fileExistsAtPath:[[self imageDirectory] stringByAppendingPathComponent:filename]]){
            if(!doNotRequest){
                //launch request to get it
                [[LensNetworkController sharedNetwork] getIconForPost:postId];
                NSLog(@"retrieving icon miss, fetch: %@", filename);
            }
            //return nothing immediately
            return nil;
        }
        else{
            //create wrapper and cache
            UIImage * uiImage = [UIImage imageWithContentsOfFile:[[self imageDirectory] stringByAppendingPathComponent:filename]];
            LensAssetImageWrapper * wrapper = [[LensAssetImageWrapper alloc] initWithName:filename assetId:nil];
            [wrapper setIsPersisted:YES];
            wrapper.image = uiImage;
            [self cacheImage:wrapper];
            
            NSLog(@"retrieving filesystem icon: %@", filename);
            return uiImage;
        }
    } else {
        
        NSLog(@"retrieving cached icon: %@", filename);
        
        //increments count
        return image.image;
    }
}

-(void)saveImage:(LensAssetImageWrapper*)wrapperToSave {
    
    UIImage * image = wrapperToSave.image;
    NSString * extension = wrapperToSave.extension;
    NSString * filename = wrapperToSave.intendedName;
    
    //tell the asset it is persisted
    wrapperToSave.isPersisted = YES;
    
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        NSString * path = [[self imageDirectory] stringByAppendingPathComponent:filename];
        [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        NSString * path = [[self imageDirectory] stringByAppendingPathComponent:filename];
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

-(void)persistAndFlush{
    //cannot enumerate assets, pull array of assets and see what has not been saved
    
    LensAppDelegate * app = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * context = [app threadContext];
    
    NSFetchRequest * req = [[NSFetchRequest alloc] initWithEntityName:@"Asset"];
    NSError * error;
    NSArray * assets = [context executeFetchRequest:req error:&error];
    
    if(!error && [assets count]){
        //enumerate assets
        [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LensAsset * asset = obj;
            LensAssetImageWrapper * wrapper;
            if((wrapper = [self objectForKey:asset.filename])){
                //still in cache check if should go to disk and then be used by uiimage cache later
                if(wrapper.getCount > 3 || [self remainingFreeObjectSpace]){
                    [self persistImage:wrapper removeFromCache:YES];
                }
            }
        }];
    }
    
    NSFetchRequest * postreq = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    error = nil;
    NSArray * posts = [context executeFetchRequest:postreq error:&error];
    if(!error && [posts count]){
        //enumerate assets
        [posts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LensPost * post = obj;
            LensAssetImageWrapper * wrapper;
            if((wrapper = [self objectForKey:post.iconFile])){
                //still in cache check if should go to disk and then be used by uiimage cache later
                if(!wrapper.isPersisted && [self remainingFreeObjectSpace]){
                    [self persistImage:wrapper removeFromCache:YES];
                }
            }
        }];
    }
    //let cache die naturally
}

-(NSInteger)remainingFreeObjectSpace{
    
    NSError * error;
    NSArray * files =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self imageDirectory] error:&error];
    
    return ((200 - [files count]) > 0 ? YES: NO);
}

-(void)evictBottom{
    count = 0;
    [self removeAllObjects];
}

-(void)evictRow:(NSArray*)assets{
    //don't evict first
    [assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(idx != 0){
            LensAsset * curAsset = obj;
            [self removeObjectForKey:curAsset.filename];
            count--;
        }
        
    }];
}

#pragma mark NSCacheDelegate

-(void)cache:(NSCache *)cache willEvictObject:(id)obj{
    
    count--;
    
    //if evicted image should be saved, save it to file
    LensAssetImageWrapper * wrapper = obj;
    if(!wrapper.isPersisted){
        NSLog(@"evicting image from cache to filesystem: %@", wrapper.intendedName);
        //persist
        [self persistImage:wrapper removeFromCache:NO];
        
    } else{
        NSLog(@"evicting image from cache already persisted: %@", wrapper.intendedName);
    }
}

@end
