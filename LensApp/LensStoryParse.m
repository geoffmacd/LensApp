//
//  LensStoryParse.m
//  LensApp
//
//  Created by Xtreme Dev on 1/31/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensStoryParse.h"

#import "LensAsset.h"
#import "LensNetworkController.h"
#import <ElementParser.h>

@implementation LensStoryParse

- (instancetype)initWithPostObjectId:(NSManagedObjectID*)postId forData:(NSData*)data{
    
    if (self = [super initWithData:data]) {
        _postId = postId;
    }
    return self;
}

// The main function for this NSOperation, to start the parsing.
- (void)main {
    
    BOOL getAssets = NO;
    
    //post
    LensPost * post = (LensPost *)[self.context objectWithID:_postId];
    
    //document with ElementParser
	DocumentRoot* doc = [Element parseHTML: self.xmlString];
    
    //find entry-content div
	NSArray* divs = [doc selectElements: @".entry-content"];
    Element * div = [divs firstObject];
    NSArray * elements = [div childElements];
	NSMutableArray* results = [NSMutableArray new];
    
    //go through elements adding only image divs and paragraphs, end on hr
	for (Element* element in elements){
        
        //add to collection html string
        NSString * type = [element description];
        NSString * contents = [element contentsText];
        NSString * result;
        if([type isEqualToString:@"<p>"]){
            
            result = [NSString stringWithFormat:@"<p>%@</p>",contents];
            
        } else if([type rangeOfString:@"w480"].location != NSNotFound){
            
//            Element * img = [element firstChild];
//            NSString * imgPath = [img attribute:@"src"];
//            NSString * filename = [[imgPath stringByDeletingPathExtension] lastPathComponent];
//            
//            //search for filename to use an already downloaded asset
//            NSFetchRequest * req = [[NSFetchRequest alloc] initWithEntityName:@"Asset"];
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename == %@", filename];
//            [req setPredicate:predicate];
//            
//            NSError*  error = nil;
//            NSArray * matches = [self.context executeFetchRequest:req error:&error];
//            if(!error){
//                if([matches count]){
//                    LensAsset * asset = [matches firstObject];
//                    result = [NSString stringWithFormat:@"<div><img src='%@.%@'></img></div>",asset.filename, asset.extension];
//                }
//            }
            
            //add img which is always first child
//            NSString * imgTag = [[element firstChild] description];
            NSString * imgSource = [element nextElement].attributes[@"src"];
            //style image to be width of screen,caption has different size
            CGFloat width = [[UIScreen mainScreen] bounds].size.width;
            CGFloat height = (width * 2.0) / 3.0;
            result = [NSString stringWithFormat:@"<div><img src='%@' height=%.0f width=%.0f><figcaption style='font-size: small;'>%@</figcaption></div>",imgSource, height, width, contents];
        }
        
        //add to array to display natively
        if(result)
            [results addObject:result];
	}
    
    //add black background stylingp
    __block NSString * html = @"<html><body style='background-color: black;color: white;'>";
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString * elStr = obj;
        html = [html stringByAppendingString:elStr];
    }];
    html = [html stringByAppendingString:@"</body></html>"];
    
    //find author
	NSArray* addressDivs = [doc selectElements: @"address"];
    Element * address = [addressDivs firstObject];
    Element * linkEl = [address firstChild];
    NSString * authorName = [linkEl contentsText];
    //search for author
    NSFetchRequest * req = [[NSFetchRequest alloc] initWithEntityName:@"Author"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", authorName];
    [req setPredicate:predicate];

    NSError*  error = nil;
    NSArray * matches = [self.context executeFetchRequest:req error:&error];
    LensAuthor * author;
    if(!error){
        if([matches count]){
            author = [matches firstObject];
        }
    }
    
    if(!author){
        author = [self newAuthor];
        author.name = authorName;
    }
    
    //if no assets in post, find assets
    if(!post.assetUrl){
        //find .xml') in string
        NSRange xmlR = [self.xmlString rangeOfString:@".xml')"];
        if(xmlR.location != NSNotFound){
            NSString * first = [self.xmlString substringToIndex:xmlR.location];
            NSRange httpR = [first rangeOfString:@"http" options:NSBackwardsSearch];
            if(httpR.location != NSNotFound){
                //found complete xml
                NSRange fileRange = NSMakeRange(httpR.location, xmlR.location + xmlR.length - 2 - httpR.location);
                NSString * assetsUrl = [self.xmlString substringWithRange:fileRange];
                post.assetUrl = assetsUrl;
                //immediately launch assets request
                getAssets = YES;
            }
        }
    }
    
    //if no tags, find tags at bottom
    if(![post.tags count]){
        NSArray* tags = [doc selectElements: @".tags"];
        for(Element * tag in tags){
            //in link text
            NSString * tagText = [tag contentsText];
            NSArray * tagArray = [tagText componentsSeparatedByString:@","];
            
            for(NSString * whiteName in tagArray){
                
                NSString * tagName = [whiteName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
                    [curTag addPostsObject: post];
                    [post addTagsObject:curTag];
                }
            }
        }
    }
    
    [author addPostsObject:post];
    post.author = author;
    
    LensStory * newStory = [self newStory];
    newStory.htmlContent = html;
    //assign relations
    newStory.post = post;
    post.story = newStory;
    
    //save to context
    [self saveContext];
    
    //after save to ensure post has saved
    if(getAssets)
        [[LensNetworkController sharedNetwork] getAssetsForPost:post.objectID];
    
}

- (LensStory*)newStory{
    
    LensStory * newStory = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:self.context];
    return newStory;
}

- (LensAuthor*)newAuthor{
    
    LensAuthor * newAuthor = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:self.context];
    return newAuthor;
}

- (LensTag*)newTag{
    
    LensTag * newTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tags" inManagedObjectContext:self.context];
    return newTag;
}
@end
