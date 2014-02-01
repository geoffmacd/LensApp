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
#import "LensStoryParse.h"
#import "LensArchiveParse.h"
#import "LensImageCache.h"
#import "LensAppDelegate.h"
#import "LensAssetImageWrapper.h"
#import "LensAuthor.h"
#import "LensPost.h"
#import "LensStory.h"
#import "LensAsset.h"

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
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        //image cache only for assets
        _imageCache = [[LensImageCache alloc] init];
        [_imageCache setDelegate:self];
        
        //observe persistence changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextWasSaved:)
                                                     name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

-(void)contextWasSaved:(NSNotification*)notification{
    
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
            [parser setQueuePriority:NSOperationQueuePriorityHigh];
            [_queue addOperation:parser];
        }
    }];
    //must start
    [task resume];
}

-(void)getArchivePosts:(NSDate *)startDate withEnd:(NSDate *)endDate{
    
    //for each month, scrape monthly archive page with yy/mm name
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents * startC = [gregorian components:(NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:startDate];
    NSDateComponents * endC = [gregorian components:(NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:endDate];
    
    //for each month make one request starting from start (most recent)
    NSInteger year = startC.year;
    for (NSInteger i = startC.month + 12 *(startC.year - endC.year); i >= endC.month; i--) {
        NSInteger month = i % 12;
        if(month == 0){
            year--;
            month = 12;
        }
        
        NSLog(@"%ld / %ld", (long)year, (long)month);
        
        //archive has pagination, and we can assume no more than 5 pages of posts
        for (NSInteger page = 1; page  < 6; page++) {
            
            NSURL * archiveUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%ld/%ld/page/%ld",ArchiveUrl, (long)year, (long)month,(long)page]];
            NSURLRequest * req = [[NSURLRequest alloc] initWithURL:archiveUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            NSURLSessionDataTask * task = [_session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                //on completion
                //save relevant info to database
                if(!error){
                    //parse html
                    LensArchiveParse * parser = [[LensArchiveParse alloc] initWithData:data];
                    [parser setQueuePriority:NSOperationQueuePriorityLow];
                    [_queue addOperation:parser];
                }
            }];
            //must start
            [task resume];
        }
    }
}

-(void)getStoryForPost:(NSManagedObjectID *)postId{
    
    LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext * newContext = [appDel threadContext];
    LensPost * curPost = (LensPost *)[newContext objectWithID:postId];
    
    NSURL * storyUrl = [NSURL URLWithString:curPost.storyUrl];
    NSURLRequest * req = [[NSURLRequest alloc] initWithURL:storyUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLSessionDataTask * task = [_session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //on completion
        //save relevant info to database
        
        if(!error){
            //parse xml
            LensStoryParse * parser = [[LensStoryParse alloc] initWithPostObjectId:curPost.objectID forData:data];
            //need to see story as quick as possible
            [parser setQueuePriority:NSOperationQueuePriorityVeryHigh];
            [_queue addOperation:parser];
        }
    }];
    //must start
    [task resume];
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

-(void)getImageForAsset:(NSManagedObjectID*)assetId withPriority:(NSOperationQueuePriority)priority{
    
    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
        
        LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext * newContext = [appDel threadContext];
        LensAsset * curAsset = (LensAsset *)[newContext objectWithID:assetId];
        
        NSString * url = [curAsset imageUrl];
        
        UIImage * image = [LensImageCache getImageFromURL:url];
        
        [LensImageCache saveImage:image withFileName:filename ofType:type];
        
        curAsset.filename = filename;
        curAsset.extension = type;
        
        NSError * err;
        [newContext save:&err];
    }];
    [_queue addOperation:op];
}

-(void)triggerRemainingAssets:(NSManagedObjectID*)postId{
    
    LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext * newContext = [appDel threadContext];
    LensPost * post = (LensPost *)[newContext objectWithID:postId];
    
    
    //fetch posts with same title
    NSFetchRequest * req = [[NSFetchRequest alloc] initWithEntityName:@"Asset"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"post == %@", post];
    [req setPredicate:predicate];
    
    NSError*  error = nil;
    NSArray * matches = [newContext executeFetchRequest:req error:&error];
    if(!error && [matches count]){
        //determine if assets have downloaded there images
        [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            LensAsset * curAsset = (LensAsset * )obj;
            if(!curAsset.filename){
                //prioritize closest images
                [self getImageForAsset:curAsset.objectID withPriority:(idx < 4 ? NSOperationQueuePriorityVeryHigh : NSOperationQueuePriorityNormal)];
            }
            
        }];
    }
}

-(void)getIconForPost:(NSManagedObjectID*)postId{
    
    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
        
        LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext * newContext = [appDel threadContext];
        LensPost * post = (LensPost *)[newContext objectWithID:postId];
        
        NSString * url = [post iconUrl];
        UIImage * image = [LensImageCache getImageFromURL:url];
        NSString * type = [url pathExtension];
        NSString * filename = [[url stringByDeletingPathExtension] lastPathComponent];
        
        [LensImageCache saveImage:image withFileName:filename ofType:type];
        
        post.iconFile = filename;
        post.iconExtension = type;
        
        NSError * err;
        [newContext save:&err];
    }];
    [_queue addOperation:op];
}

#pragma mark NSCacheDelegate 

-(void)cache:(NSCache *)cache willEvictObject:(id)obj{
    
    //if evicted image should be saved, save it to file
    LensAssetImageWrapper * asset = obj;
    
    //look up associated asset
    if(asset){
        
        
    }
}

@end
