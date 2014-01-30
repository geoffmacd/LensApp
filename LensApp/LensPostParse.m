//
//  LensAssetDataParse.m
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensPostParse.h"

#import <SMXMLDocument.h>
#import "LensNetworkController.h"

@implementation LensPostParse

- (instancetype)initWithData:(NSData *)parseData {
    
    if (self = [super initWithData:parseData]) {
        
        _postArray = [NSMutableArray new];
    }
    return self;
}

// The main function for this NSOperation, to start the parsing.
- (void)main {
   
    //decode to string
    NSData * data = [self.xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    // create a new SMXMLDocument with the contents of xml
    NSError *error = nil;
    SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&error];
    
    if(error){
        NSLog(@"%@",[error description]);
        return;
    }
    
    SMXMLElement *posts = [document.root childNamed:@"posts"];
    
    NSMutableArray * newPosts = [NSMutableArray new];
    
    for (SMXMLElement *post in [posts childrenNamed:@"post"]) {
        
        NSString * title = [post valueWithPath:kTagTitle];
        
        //fetch posts with same title
        NSFetchRequest * req = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", title];
        [req setPredicate:predicate];
    
        error = nil;
        NSArray * matches = [self.context executeFetchRequest:req error:&error];
        if(error || ![matches count]){
            
            LensPost * newPost = [self newPost];
            
            newPost.title = title;
            newPost.date = [NSDate date];
            //        newPost.byline = [post valueWithPath:kTagByline];
            //        NSString *keywords = [post valueWithPath:kTagKeyword];
            //        NSString *tags = [post valueWithPath:kTagTags];
            //        newPost.tags = [tags componentsSeparatedByString:@","];
            newPost.storyUrl = [post valueWithPath:kTagURL];
            newPost.assetUrl = [post valueWithPath:kTagAsset];
            newPost.iconUrl = [[post childNamed:kTagPhoto] valueWithPath:kTagURL];
            
            [newPosts addObject:newPost];
        } else {
            NSLog(@"already have this post, %@", title);
        }
    }
    
    //save to context
    [self saveContext];
    
    //launch asset request on main thread to hit queue
    dispatch_async(dispatch_get_main_queue(), ^{
        for(LensPost * post in newPosts){
            [[LensNetworkController sharedNetwork] getAssetsForPost:post.objectID];
        }
    });
}

- (LensPost*)newPost{
    
    LensPost * newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.context];
    return newPost;
}

@end
