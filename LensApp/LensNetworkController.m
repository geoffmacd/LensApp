//
//  LensNetworkController.m
//  LensApp
//
//  Created by Xtreme Dev on 1/28/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensNetworkController.h"

#import "LensAssetDataParse.h"
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
    }
    return self;
}

-(NSArray *)getCurrentPosts{
    
    NSURL * assetDataUrl = [NSURL URLWithString:AssetDataUrl];
    
    NSURLRequest * req = [[NSURLRequest alloc] initWithURL:assetDataUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    NSURLSession * ses = [NSURLSession sharedSession];
    NSURLSessionDataTask * task = [ses dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //on completion
        //save relevant info to database
        
        if(!error){
            LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
            NSManagedObjectContext * newContext = [appDel threadContext];
            
            //parse xml
            LensAssetDataParse * parser = [[LensAssetDataParse alloc] initWithData:data andContext:newContext];
            [_queue addOperation:parser];
        }
    }];
    //must start
    [task resume];

    return nil;
}

-(NSArray *)getArchivePosts:(NSDate *)startDate withEnd:(NSDate *)endDate{
    
    return nil;
}

-(LensStory *)getStoryForPost:(LensPost *)post{
    
    return nil;
}

-(NSArray *)getAssetsForPost:(LensPost *)post{
    
    return nil;
}

-(UIImage *)getIconForPost:(LensPost *)post{
    
    return nil;
}


#pragma mark - NSXMLParserDelegate

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{

}

@end
