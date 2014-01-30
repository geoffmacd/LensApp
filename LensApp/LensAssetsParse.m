//
//  LensAssetsParse.m
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensAssetsParse.h"

#import <SMXMLDocument.h>

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
    
    for (SMXMLElement *slide in [slides childrenNamed:kTagSlide]) {
        
        SMXMLElement *photo = [slide childNamed:kTagPhoto];
        
        //create new photo asset
        if(photo){
            LensAsset * newAsset = [self newAsset];
            
            newAsset.imageUrl = [photo valueWithPath:kTagUrl];
            newAsset.caption = [photo valueWithPath:kTagCaption];
            newAsset.credit = [photo valueWithPath:kTagCredit];
            newAsset.post = [self.context objectWithID:_postId];
            
            [newAssets addObject:newAsset];
        }
    }
    
    //save to context
    [self saveContext];
}

- (LensAsset*)newAsset{
    
    LensAsset * newAsset = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:self.context];
    return newAsset;
}


@end
