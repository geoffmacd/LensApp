//
//  LensImage.m
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensImage.h"
#import "LensAppDelegate.h"

@implementation LensImage

+(UIImage *) loadImage:(NSString *)fileName ofType:(NSString *)extension{
    
    NSString * path = [NSString stringWithFormat:@"%@/%@.%@", [self imageDirectory], fileName, extension];
    UIImage * result = [UIImage imageWithContentsOfFile:path];
    return result;
}

+(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension {
    
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        NSString * path = [[self imageDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]];
        [UIImagePNGRepresentation(image) writeToFile:path options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        NSString * path = [[self imageDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
        NSError * error;
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:path options:NSAtomicWrite error:&error];
        if(error){
            NSLog(@"%@", [error description]);
        }
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

+(void)saveImageData:(NSData *)imageData withFileName:(NSString *)imageName ofType:(NSString *)extension {
    
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        NSString * path = [[self imageDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]];
        [imageData writeToFile:path options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        NSString * path = [[self imageDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
        [imageData writeToFile:path options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

+(NSData *) getImageDataFromURL:(NSString *)fileURL {
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    return data;
}

+(UIImage *) getImageFromURL:(NSString *)fileURL {
    
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

+(NSString*)imageDirectory{
    
    LensAppDelegate * app = [[UIApplication sharedApplication] delegate];
    NSURL * imageUrl = [[app applicationDocumentsDirectory] URLByAppendingPathComponent:@"images"];
    NSString * result = [imageUrl path];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:result])
        [[NSFileManager defaultManager] createDirectoryAtPath:result withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    return result;
}

@end
