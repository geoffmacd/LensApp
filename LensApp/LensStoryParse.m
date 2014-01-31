//
//  LensStoryParse.m
//  LensApp
//
//  Created by Xtreme Dev on 1/31/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensStoryParse.h"

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
            
            result = [NSString stringWithFormat:@"<div>%@</div>",contents];
        }
        if(result)
            [results addObject:result];
	}


    __block NSString * html = @"<html><body>";
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString * elStr = obj;
        html = [html stringByAppendingString:elStr];
    }];
    html = [html stringByAppendingString:@"</body></html>"];
    
    LensStory * newStory = [self newStory];
    newStory.htmlContent = html;
    //assign relations
    newStory.post = post;
    post.story = newStory;
    
    //save to context
    [self saveContext];
    
}

- (LensStory*)newStory{
    
    LensStory * newStory = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:self.context];
    return newStory;
}

@end
