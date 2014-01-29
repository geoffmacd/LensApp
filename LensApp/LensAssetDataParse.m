//
//  LensAssetDataParse.m
//  LensApp
//
//  Created by Xtreme Dev on 1/29/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensAssetDataParse.h"

#import "NSString+HTML.h"
#import <SMXMLDocument.h>


@implementation LensAssetDataParse

- (instancetype)initWithData:(NSData *)parseData andContext:(NSManagedObjectContext*)context {
    
    self = [super init];
    if (self) {
        
        NSString* newStr = [[NSString alloc] initWithData:parseData encoding:NSUTF8StringEncoding];
        NSString * decodedString = [newStr stringByDecodingHTMLEntities];
        
        _xmlString = decodedString;
        _postArray = [NSMutableArray new];
        _context = context;
    }
    return self;
}



// The main function for this NSOperation, to start the parsing.
- (void)main {
    
    /*
     It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable because it gives less control over the network, particularly in responding to connection errors.
     */
    
    NSData * data = [_xmlString dataUsingEncoding:NSUTF8StringEncoding];
    
    // create a new SMXMLDocument with the contents of sample.xml
    NSError *error = nil;
    SMXMLDocument *document = [SMXMLDocument documentWithData:data error:&error];
    
    if(error){
        NSLog([error description]);
        return;
    }
    
    SMXMLElement *posts = [document.root childNamed:@"posts"];
    
    NSMutableArray * newPosts = [NSMutableArray new];
    
    for (SMXMLElement *post in [posts childrenNamed:@"post"]) {
        
        LensPost * newPost = [self newPost];
        
//        newPost.byline = [post valueWithPath:kTagByline];
        newPost.title = [post valueWithPath:kTagTitle];
        newPost.date = [NSDate date];
//        NSString *keywords = [post valueWithPath:kTagKeyword];
//        NSString *tags = [post valueWithPath:kTagTags];
//        newPost.tags = [tags componentsSeparatedByString:@","];
        newPost.storyUrl = [post valueWithPath:kTagURL];
        newPost.assetUrl = [post valueWithPath:kTagAsset];
        newPost.iconUrl = [[post childNamed:kTagPhoto] valueWithPath:kTagURL];
        
        [newPosts addObject:newPost];
        
    }
    
    //save to context
    if (_context != nil) {
        if ([_context hasChanges]){
            if(![_context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
        
            }
        }
    }
}

- (LensPost*)newPost{
    
    LensPost * newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:_context];
    return newPost;
}

- (LensPost*)newStory{
    
    LensPost * newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:_context];
    return newPost;
}

- (LensPost*)newAssets{
    
    LensPost * newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:_context];
    return newPost;
}

@end
