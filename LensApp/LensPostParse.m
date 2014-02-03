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
        if(!error && ![matches count]){
            
            LensPost * newPost = [self newPost];
            
            newPost.title = title;
            
            NSString * dateStr = [post valueWithPath:kTagDate];
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setLenient:YES];
            [formatter setDateFormat:@"MMMM dd, yyyy, hh:mm a"];
            NSDate * date = [formatter dateFromString:dateStr];
            newPost.date = date;
//            newPost.byline = [post valueWithPath:kTagByline];
//            NSString *keywords = [post valueWithPath:kTagKeyword];
            newPost.storyUrl = [post valueWithPath:kTagURL];
            newPost.assetUrl = [post valueWithPath:kTagAsset];
            newPost.excerpt = [post valueWithPath:kTagExcerpt];
            newPost.iconUrl = [[post childNamed:kTagPhoto] valueWithPath:kTagURL];
            //process tags
            NSString *tags = [post valueWithPath:kTagTags];
            NSArray * tagArray = [tags componentsSeparatedByString:@","];
            
            [tagArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                NSString * tagName = obj;
                
                NSFetchRequest * tagReq = [[NSFetchRequest alloc] initWithEntityName:@"Tags"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", tagName];
                [tagReq setPredicate:predicate];
                
                NSError * err = nil;
                NSArray * tagMatch = [self.context executeFetchRequest:tagReq error:&err];
                LensTag * curTag;
                if(!err && ![tagMatch count]){
                    
                    curTag = [self newTag];
                    curTag.name = tagName;
                } else if ([tagMatch count]){
                    curTag = [tagMatch firstObject];
                }
                //add tag to post and post to tag
                if(curTag){
                    [curTag addPostsObject: newPost];
                    [newPost addTagsObject:curTag];
                }
            }];
            
            [newPosts addObject:newPost];
        } else {
//            NSLog(@"already have this post, %@", title);
        }
    }
    
    //save to context
    [self saveContext];
    
    for(LensPost * post in newPosts){
        [[LensNetworkController sharedNetwork] getAssetsForPost:post.objectID];
    }
}

- (LensPost*)newPost{
    
    LensPost * newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.context];
    return newPost;
}

- (LensTag*)newTag{
    
    LensTag * newtag = [NSEntityDescription insertNewObjectForEntityForName:@"Tags" inManagedObjectContext:self.context];
    return newtag;
}

@end