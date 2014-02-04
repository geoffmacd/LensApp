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

#define kXpadding       10
#define kAssetHeight    200
#define kcaptionHeight  40


@interface LensSlideView : UIView <UIScrollViewDelegate> {
    CGFloat assetWidth;
    CGFloat assetHeight;
    
    CGFloat captionHeight;
    
    CGFloat xPadding;
    NSInteger limitSlides;
    CGFloat maxScrolledX;
}

@property (weak) UIScrollView * scroll;
@property NSArray * assets;
@property LensPost * post;
@property (strong) NSMutableDictionary * slideDict;

-(void)setPost:(LensPost *)post withContext:(NSManagedObjectContext*)context;
@end
