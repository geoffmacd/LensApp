//
//  LensAssetsParse.m
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensAssetsParse.h"

#import <SMXMLDocument.h>
#import "LensNetworkController.h"

@implementation LensAssetsParse

- (instancetype)initWithData:(NSData *)parseData forPostObjectId:(NSManagedObjectID*)postId{
    
    if (self = [super initWithData:parseData]) {
        _postId = postId;
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
    
    SMXMLElement * story = [document.root childNamed:kTagStory];

    SMXMLElement * slides = [story childNamed:kTagPhotos];
    
    NSMutableArray * newAssets = [NSMutableArray new];
    LensPost * post = (LensPost *)[self.context objectWithID:_postId];
    
    [[slides childrenNamed:kTagSlide] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        SMXMLElement *slide = (SMXMLElement*)obj;
        
        SMXMLElement *photo = [slide childNamed:kTagPhoto];
        
        //create new photo asset
        if(photo){
            
            NSString * imageUrl = [photo valueWithPath:kTagUrl];
            
            //fetch posts with same title
            NSFetchRequest * req = [[NSFetchRequest alloc] initWithEntityName:@"Asset"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"post == %@", imageUrl];
            [req setPredicate:predicate];
            
            NSError*  error = nil;
            NSArray * matches = [self.context executeFetchRequest:req error:&error];
            if(!error && ![matches count]){
                
                LensAsset * newAsset = [self newAsset];
                
                newAsset.imageUrl = imageUrl;
                newAsset.caption = [photo valueWithPath:kTagCaption];
                newAsset.credit = [photo valueWithPath:kTagCredit];
                newAsset.filename = [imageUrl lastPathComponent];
                if(post){
                    //add to post
                    [newAssets addObject:newAsset];
                    newAsset.post = post;
                }
                [post addAssetsObject:newAsset];
            } else {
                NSLog(@"already have this asset, %@", imageUrl);
            }
        }
    
    }];
    
    //save to context
    [self saveContext];
    
    //get first two images
    if([newAssets count]){
        LensAsset * first = [newAssets firstObject];
        [[LensNetworkController sharedNetwork] getImageForAsset:first.objectID withPriority:NSOperationQueuePriorityHigh];
    }
//    if([newAssets count] > 1){
//        LensAsset * second = newAssets[1];
//        [[LensNetworkController sharedNetwork] getImageForAsset:second.objectID withPriority:NSOperationQueuePriorityLow];
//    }
    
    //get story, will not get assets from story parse
    [[LensNetworkController sharedNetwork] getStoryForPost:post.objectID];
}

- (LensAsset*)newAsset{
    
    LensAsset * newAsset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:self.context];
    return newAsset;
}


@end
