//
//  LensAssetImage.h
//  LensApp
//
//  Created by Geoff MacDonald on 2/1/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LensAssetImageWrapper : NSObject

@property NSManagedObjectID * assetId;
@property (copy) NSString * intendedName;
@property (copy) NSString * extension;
@property BOOL shouldPersist;
@property BOOL isIcon;
@property NSInteger getCount;

@property UIImage * image;

-(instancetype)initWithName:(NSString*)fileName assetId:(NSManagedObjectID*)assetId;
-(BOOL) getImageFromURL:(NSString *)fileURL;

@end
