//
//  LensStoryParse.m
//  LensApp
//
//  Created by Xtreme Dev on 1/31/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensStoryParse.h"



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
    
    // create a new SMXMLDocument with the contents of xml
    NSError *error = nil;
    
    if(error){
        NSLog(@"%@",[error description]);
        return;
    }
    

    
    //save to context
    [self saveContext];
    

}

- (LensStory*)newStory{
    
    LensStory * newStory = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:self.context];
    return newStory;
}

@end
