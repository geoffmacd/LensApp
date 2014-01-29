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
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[_xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:YES];
    BOOL success = [parser parse];
    
    //save to context
    NSError *error = nil;
    if (success && _context != nil) {
        if ([_context hasChanges] && ![_context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (LensPost*)newPost{
    
    LensPost * newPost = [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:_context];
    return newPost;
}


#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    /*
     If the number of parsed earthquakes is greater than kMaximumNumberOfEarthquakesToParse, abort the parse.
     */
    if ([elementName isEqualToString:kTagPost]) {
        LensPost * post = [self newPost];
        _curPost = post;
    }
    NSLog([attributeDict description]);
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    

}


-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog([parseError description]);
}

@end
