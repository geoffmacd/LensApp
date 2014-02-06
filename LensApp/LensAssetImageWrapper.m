//
//  LensAssetImage.m
//  LensApp
//
//  Created by Geoff MacDonald on 2/1/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensAssetImageWrapper.h"

@implementation LensAssetImageWrapper

static NSMutableDictionary * requests;

+(void)initialize{
    requests = [[NSMutableDictionary alloc] init];
}

-(instancetype)initWithName:(NSString*)fileName assetId:(NSManagedObjectID*)assetId{
    if(self = [super init]){
        _isPersisted = NO;
        _assetId = assetId;
        _extension = [fileName pathExtension];
        _intendedName = [fileName lastPathComponent];
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
    
    NSDate * oldReq = requests[[fileURL lastPathComponent]];
    if(!oldReq){
        requests[[fileURL lastPathComponent]] = [NSDate date];
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
        //remove key
        [requests removeObjectForKey:[fileURL lastPathComponent]];
        result = [UIImage imageWithData:data];
        _image = result;
        if(result)
            return YES;
        return NO;
    }
    return NO;
}

@end
