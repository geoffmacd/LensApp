//
//  LensNetworkController.m
//  LensApp
//
//  Created by Xtreme Dev on 1/28/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensNetworkController.h"

#import "LensPostParse.h"
#import "LensAssetsParse.h"
#import "LensImage.h"
#import "LensAppDelegate.h"


@implementation LensNetworkController

+(LensNetworkController*)sharedNetwork{
    
    static LensNetworkController * sharedNetwork = nil;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedNetwork = [[self alloc] init];
    });
    return sharedNetwork;
}

-(instancetype)init{
    
    if(self = [super init]){
        
        //config
        _queue = [[NSOperationQueue alloc] init];
        _session = [NSURLSession sharedSession];
        
        //observe persistence changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextWasSaved:)
                                                     name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

-(void)contextWasSaved:(NSNotification*)notification{
    
    //1. launch requests for stories, assets, icons depending on state of LensPost and prioritize based on
    //2. notifies controllers that 
}

-(void)getCurrentPosts{
    
    NSURL * postsUrl = [NSURL URLWithString:AssetDataUrl];
    NSURLRequest * req = [[NSURLRequest alloc] initWithURL:postsUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLSessionDataTask * task = [_session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //on completion
        //save relevant info to database
        
        if(!error){
            //parse xml
            LensPostParse * parser = [[LensPostParse alloc] initWithData:data];
            [_queue addOperation:parser];
        }
    }];
    //must start
    [task resume];
}

-(NSArray *)getArchivePosts:(NSDate *)startDate withEnd:(NSDate *)endDate{
    
    return nil;
}

-(LensStory *)getStoryForPost:(LensPost *)post{
    
    return nil;
}

-(void)getAssetsForPost:(NSManagedObjectID *)postId{
    
    LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext * newContext = [appDel threadContext];
    LensPost * curPost = (LensPost *)[newContext objectWithID:postId];
    
    NSURL * assetDataUrl = [NSURL URLWithString:curPost.assetUrl];
    NSURLRequest * req = [[NSURLRequest alloc] initWithURL:assetDataUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLSessionDataTask * task = [_session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //on completion
        //save relevant info to database
        
        if(!error){
            //parse xml
            LensAssetsParse * parser = [[LensAssetsParse alloc] initWithData:data forPostObjectId:postId];
            [_queue addOperation:parser];
        }
    }];
    //must start
    [task resume];
}


-(void)getImageForAsset:(NSManagedObjectID*)assetId{
    
    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
        
        LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext * newContext = [appDel threadContext];
        LensAsset * curAsset = (LensAsset *)[newContext objectWithID:assetId];
        
        NSString * url = [curAsset imageUrl];
        UIImage * image = [LensImage getImageFromURL:url];
        NSString * type = [url pathExtension];
        NSString * filename = [[url stringByDeletingPathExtension] lastPathComponent];
        
        [LensImage saveImage:image withFileName:filename ofType:type];
        
        
        curAsset.filename = filename;
        curAsset.extension = type;
        
        NSError * err;
        [newContext save:&err];
    }];
    [_queue addOperation:op];
}

-(void)getIconForPost:(LensPost *)post{
    
}






@end
