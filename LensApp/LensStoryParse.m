//
//  LensStoryParse.m
//  LensApp
//
//  Created by Xtreme Dev on 1/31/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensStoryParse.h"

#import <SMXMLDocument.h>

@implementation LensStoryParse

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
    
    NSError * error;
    SMXMLDocument *doc = [SMXMLDocument documentWithData:data error:&error];
    
    LensPost * post = (LensPost *)[self.context objectWithID:_postId];
    
    if(!error){
        
        SMXMLElement *bodyE = [doc.root childNamed:@"body"];
        
        //find entry-content div
        SMXMLElement * content = [bodyE descendantWithPath:@"shell.page.lens.aCol.content.entry-content"];
        __block NSMutableArray * contentArray = [NSMutableArray new];
        
        //add up paragraph and image elements
        __block BOOL scriptHit;
        [[content children] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            SMXMLElement * cur = obj;
            
            if(!scriptHit){
                if([[cur name] isEqualToString:@"script"]){
                    scriptHit = YES;
                }
            } else {
                //if it is the footer stop
                if([[cur name] isEqualToString:@"hr"]){
                    *stop = YES;
                }else{
                    //add to collection html string
                    [contentArray addObject:cur];
                }
            }
            
        }];
        
        //convert elements to text and save
        __block NSString * contentHtml = @"";
        
        [contentArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            SMXMLElement * cur = obj;
            NSString * elStr = [cur description];
            contentHtml = [contentHtml stringByAppendingString:elStr];
        }];
        
        LensStory * newStory = [self newStory];
        newStory.htmlContent = contentHtml;
        //assign relations
        newStory.post = post;
        post.story = newStory;
    }
    
    //save to context
    [self saveContext];
    

}

- (LensStory*)newStory{
    
    LensStory * newStory = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:self.context];
    return newStory;
}

@end
