//
//  LensArchiveParse.m
//  LensApp
//
//  Created by Geoff MacDonald on 1/31/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensArchiveParse.h"

#import "LensStory.h"
#import "LensAuthor.h"
#import "LensAsset.h"
#import "LensPost.h"
#import "LensNetworkController.h"
#import <ElementParser.h>

@implementation LensArchiveParse

- (instancetype)initWithData:(NSData *)parseData{
    
    if (self = [super initWithData:parseData]) {
    }
    return self;
}

// The main function for this NSOperation, to start the parsing.
- (void)main {
    
    //document with ElementParser
	DocumentRoot* doc = [Element parseHTML: self.xmlString];
    
    //find entry-content div
	NSArray* posts = [doc selectElements: @".post"];
    
    NSMutableArray * newPosts = [NSMutableArray new];
    
    //go through elements adding only image divs and paragraphs, end on hr
	for (Element* post in posts){
        
        //1. title
        //2. author
        //3. storyurl
        //4. iconurl
        //5. date
        //6. excerpt
        Element * timeE = [post selectElement:@"time"];
        Element * titleE = [[post selectElement:@".entry-title"] firstChild];
        NSString * title = [titleE contentsText];
        Element * excerptE = [[post selectElement:@".entry-summary"] selectElement:@"p"];
        Element * authorE = [[post selectElement:@"address"] firstChild];
        NSString * storyUrl = [[[post selectElement:@".entry-title"] firstChild] attribute:@"href"];
        NSString * iconUrl = [[[[post selectElement:@".entry-summary"] firstChild] firstChild] attribute:@"src"];
        
        //fetch posts with same title
        NSFetchRequest * req = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", title];
        [req setPredicate:predicate];
        
        NSError * error = nil;
        NSArray * matches = [self.context executeFetchRequest:req error:&error];
        if(!error && ![matches count]){
            LensPost * newPost = [self newPost];
            newPost.title = title;
            newPost.storyUrl = storyUrl;
            newPost.iconUrl = iconUrl;
            newPost.excerpt = [excerptE contentsText];
            NSString * authorName = [authorE contentsText];
            
            NSString * dateStr = [timeE contentsText];
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setLenient:YES];
            [formatter setDateFormat:@"MMMM dd, yyyy, hh:mm a"];
            NSDate * date = [formatter dateFromString:dateStr];
            newPost.date = date;
            
            //search for author
            NSFetchRequest * authorReq = [[NSFetchRequest alloc] initWithEntityName:@"Author"];
            NSPredicate * authPred = [NSPredicate predicateWithFormat:@"name == %@", authorName];
            [authorReq setPredicate:authPred];
            
            NSError*  error = nil;
            NSArray * matches = [self.context executeFetchRequest:authorReq error:&error];
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
            
            [author addPostsObject:newPost];
            newPost.author = author;
            
            //we still need to get assets url from the story url
            [newPosts addObject:newPost];
        }
	}
    
    //save to context
    [self saveContext];
    
    //get post stories
    [newPosts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        LensPost * curPost = obj;
        [[LensNetworkController sharedNetwork] getStoryForPost:curPost.objectID];
    }];
}

- (LensPost*)newPost{
    
    LensPost * newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.context];
    return newPost;
}

- (LensAuthor*)newAuthor{
    
    LensAuthor * newAuthor = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:self.context];
    return newAuthor;
}

@end
