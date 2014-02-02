//
//  LensAssetImage.m
//  LensApp
//
//  Created by Geoff MacDonald on 2/1/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensAssetImageWrapper.h"

@implementation LensAssetImageWrapper

-(instancetype)initWithName:(NSString*)fileName assetId:(NSManagedObjectID*)assetId{
    if(self = [super init]){
        _shouldPersist = NO;
        _assetId = assetId;
        _extension = [fileName pathExtension];
        _intendedName = [[fileName stringByDeletingPathExtension] lastPathComponent];
        _isIcon = (assetId ? NO : YES);
        _getCount = 0;
    }
    return self;
}

-(UIImage *)image{
    _getCount++;
    
    return _image;
}

-(BOOL) getImageFromURL:(NSString *)fileURL {
    NSLog(@"fetching image from : %@", [fileURL description]);
    
    UIImage * result;

    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    _image = result;
    if(result)
        return YES;
    return NO;
}

@end
