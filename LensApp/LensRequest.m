//
//  LensRequest.m
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensRequest.h"

#import "LensAppDelegate.h"
#import "NSString+HTML.h"

@implementation LensRequest

- (instancetype)initWithData:(NSData *)parseData{
    
    self = [super init];
    if (self) {
        
        NSString* newStr = [[NSString alloc] initWithData:parseData encoding:NSUTF8StringEncoding];
        NSString * decodedString = [newStr stringByDecodingHTMLEntities];
        
        LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext * newContext = [appDel threadContext];
        _xmlString = decodedString;
        _context = newContext;
    }
    return self;
}


-(void)saveContext{
    
    NSError * error;
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

@end
