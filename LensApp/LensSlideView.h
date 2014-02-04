//
//  LensSlideshowViewController.h
//  LensApp
//
//  Created by Xtreme Dev on 2/3/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LensPost.h"
#import "LensAsset.h"


@interface LensSlideView : UIView{
    CGFloat assetWidth;
    CGFloat assetHeight;
    
    CGFloat captionHeight;
    
    CGFloat xPadding;
}

@property (weak) UIScrollView * scroll;
@property NSArray * assets;
@property LensPost * post;

-(void)setPost:(LensPost *)post withContext:(NSManagedObjectContext*)context;
@end
