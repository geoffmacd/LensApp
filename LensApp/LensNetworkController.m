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
#import "UIImage+UILensImage.h"

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

-(void)getImageForAsset:(NSManagedObjectID*)assetId withPriority:(NSOperationQueuePriority)priority{
    
    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
        
        LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext * newContext = [appDel threadContext];
        LensAsset * curAsset = (LensAsset *)[newContext objectWithID:assetId];
        
        NSString * url = [curAsset imageUrl];
        NSString * filename = [url lastPathComponent];
    
        LensAssetImageWrapper * imagewrap = [[LensAssetImageWrapper alloc] initWithName:filename assetId:assetId];
        UIImage * fileSystemImage = [_imageCache retrieveImage:filename withAsset:assetId doNotRequest:YES];
        
        if(fileSystemImage){
            //set it manually from file system
            imagewrap.image = fileSystemImage;
            [_imageCache cacheImage:imagewrap];
            curAsset.filename = filename;
            [self saveContext:newContext];
        } else if ([imagewrap getImageFromURL:url]){
            [_imageCache cacheImage:imagewrap];
            curAsset.filename = filename;
            [self saveContext:newContext];
        }
    }];
    [_queue addOperation:op];
}

-(void)getIconForPost:(NSManagedObjectID*)postId{
    
    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
        
        LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext * newContext = [appDel threadContext];
        LensPost * post = (LensPost *)[newContext objectWithID:postId];
        
        NSString * url = [post iconUrl];
        NSString * filename = [url lastPathComponent];
                
        LensAssetImageWrapper * imagewrap = [[LensAssetImageWrapper alloc] initWithName:filename assetId:nil];
        UIImage * fileSystemImage = [_imageCache retrieveIcon:filename withPost:postId doNotRequest:YES];
        
        if(fileSystemImage){
            //set it manually from file system
            imagewrap.image = fileSystemImage;
            [_imageCache cacheImage:imagewrap];
            post.iconFile = filename;
            [self saveContext:newContext];
        } else if ([imagewrap getImageFromURL:url]){
            [_imageCache cacheImage:imagewrap];
            post.iconFile = filename;
            [self saveContext:newContext];
        }
        
        //either ensure it exists or else retrieve it
        if([imagewrap getImageFromURL:url]){
        }
    }];
    [_queue addOperation:op];
}

-(void)saveContext:(NSManagedObjectContext*)context{
    
    NSError * error = nil;
    if (context != nil) {
        if ([context hasChanges]){
            if(![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
                
            }
        }
    }
}

@end
