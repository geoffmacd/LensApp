//
//  LensSlideshowViewController.m
//  LensApp
//
//  Created by Xtreme Dev on 2/3/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensSlideView.h"
#import "UIImage+UILensImage.h"

@interface LensSlideView ()

@end

@implementation LensSlideView

-(id)initWithFrame:(CGRect)frame{
    
    if(self = [super initWithFrame:frame]){
        
        //configure self
        [self configure];

    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        
        //configure self
        [self configure];
        
    }
    return self;
}

-(void)configure{
    //add slider of same frame
    UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:self.frame];
    _scroll = scroll;
    [self addSubview:scroll];
}

-(void)setPost:(LensPost *)post withContext:(NSManagedObjectContext*)context{
    
    //set post
    _post = post;
    
    //retrieve assets
    NSFetchRequest * req = [[NSFetchRequest alloc] initWithEntityName:@"Asset"];
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"post == %@", post];
    [req setPredicate:pred];
    
    NSError * err;
    //set all assets for post
    _assets = [context executeFetchRequest:req error:&err];
    
    [self populateSlides];
}

-(void)populateSlides{
    
    [self sizeSlider];
    
    //start at padding
    __block CGFloat xOff = xPadding;
    //place slides sequentially ordered by asset
    [_assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        LensAsset * curAsset = obj;
        UIView * slide = [self slideViewForAsset:curAsset];
        if(slide){
            //offset frame
            [slide setFrame:CGRectOffset(slide.frame, xOff, 0)];
            [_scroll addSubview:slide];
            //increase offset for next slide
            xOff += assetWidth + 2 * xPadding;
        }
    }];
}

-(UIView*)slideViewForAsset:(LensAsset*)asset{
    
    UIImage * image = [UIImage lensImageNamed:asset.filename withAsset:asset.objectID];
    UIView * view;
    
    if(image){
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, assetWidth, assetHeight + captionHeight)];
        
        UIImageView * imgView = [[UIImageView alloc] initWithImage:image];
        [imgView setFrame:CGRectMake(0, 0, assetWidth, assetHeight)];
        [view addSubview:imgView];
        
        UILabel * label  = [[UILabel alloc] initWithFrame:CGRectMake(xPadding, assetHeight, assetWidth, captionHeight)];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        label.frame = CGRectOffset(label.frame, 0, 5);
        [label setText:asset.caption];
        [view addSubview:label];
    }
    return view;
}

-(void)sizeSlider{
    
    xPadding = 10;
    assetWidth = [[[UIApplication sharedApplication] keyWindow] frame].size.width - (2 * xPadding);
    assetHeight = 200;
    captionHeight = 30;
    
    CGFloat fullWidth = 320 + 2 * xPadding;
    
    CGRect content = CGRectMake(0, 0, fullWidth * [_assets count], assetHeight);
    [_scroll setContentSize:content.size];
}

@end
