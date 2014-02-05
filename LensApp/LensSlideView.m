//
//  LensSlideshowViewController.m
//  LensApp
//
//  Created by Xtreme Dev on 2/3/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensSlideView.h"
#import "UIImage+UILensImage.h"


@interface LensSlide : UIView

@property NSManagedObjectID * assetId;
@property NSString * intendedName;
@property UIImageView * imageView;
@property UILabel * caption;
@end

@implementation LensSlide

-(id)initWithFrame:(CGRect)frame{
    
    if(self = [super initWithFrame:frame]){
        
        UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, frame.size.width, frame.size.height - kcaptionHeight - 2)];
        _imageView = imgView;
         imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imgView];
        
        UILabel * label  = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - kcaptionHeight, frame.size.width, kcaptionHeight)];
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        label.textColor = [UIColor colorWithWhite:0.8 alpha:1];
        label.numberOfLines = 2;
        label.minimumScaleFactor = 0.7;
        label.adjustsFontSizeToFitWidth = YES;
        _caption = label;
        [self addSubview:label];
    }

    return self;
}

@end

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
    UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scroll = scroll;
    [_scroll setDelegate:self];
    [self addSubview:scroll];
    
    [self setBackgroundColor:[UIColor blackColor]];
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
    
    //set blank dictionary
    //remove first
    [_slideDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        LensSlide * slide = obj;
        [slide removeFromSuperview];
    }];
    _slideDict = [[NSMutableDictionary alloc] initWithCapacity:15];
    
    //first 2 slides at first
    limitSlides = 2;
    [self populateSlides];
}

-(void)imageRetrieved:(NSNotification*)notification{
    
    [self performSelectorOnMainThread:@selector(replaceImage:) withObject:notification waitUntilDone:YES];
}

-(void)replaceImage:(NSNotification*)notification{
    
    NSManagedObjectID * assetId = notification.userInfo[@"assetId"];
    NSString * filename = notification.name;
    //replace only that slide with correct image
    
    //should be in dict
    LensSlide * slide = _slideDict[assetId];
    UIImage * newImage = [UIImage lensImageNamed:filename withAsset:assetId];
    [slide.imageView setImage:newImage];
}

-(void)populateSlides{
    
    [self sizeSlider];
    
    //start at padding
    __block CGFloat xOff = xPadding;
    //place slides sequentially ordered by asset
    [_assets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        LensAsset * curAsset = obj;
        
        LensSlide * slide;
        if(idx >= limitSlides){
            //add minimal slide without image
            slide = [self slideViewForAsset:curAsset blankImage:YES];
        } else {
            //add real slide with image
            slide = [self slideViewForAsset:curAsset blankImage:NO];
        }
        if(slide){
            //offset frame
            [slide setFrame:CGRectOffset(slide.frame, xOff, 0)];
            [_scroll addSubview:slide];
            //increase offset for next slide
            xOff += assetWidth + 2 * xPadding;
            
            //add key for asset file with ordering
            _slideDict[curAsset.objectID] = slide;
        }
    }];
}

-(LensSlide*)slideViewForAsset:(LensAsset*)asset blankImage:(BOOL)blank{
    
    LensSlide * slide = [[LensSlide alloc] initWithFrame:CGRectMake(0, 0, assetWidth, assetHeight + captionHeight)];
    if(slide){
        
        slide.assetId = asset.objectID;
        [slide.caption setText:asset.caption];
        slide.intendedName = asset.filename;
        
        if(!blank){
            UIImage * image = [UIImage lensImageNamed:asset.filename withAsset:asset.objectID];
            //if no image, request has been sent and we can expect a notification
            if(!image)
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageRetrieved:) name:[asset.imageUrl lastPathComponent] object:nil];
            else
                [slide.imageView setImage:image];
        }
    }
    
    return slide;
}

-(void)sizeSlider{
    
    xPadding = 10;
    assetWidth = self.frame.size.width - (2 * xPadding);
    assetHeight = 200;
    captionHeight = 30;
    
    CGFloat fullWidth = assetWidth + 2 * xPadding;
    
    CGRect content = CGRectMake(0, 0, fullWidth * [_assets count], assetHeight);
    [_scroll setContentSize:content.size];
    [_scroll setContentOffset:CGPointMake(0, 0) animated:YES];
    
    maxScrolledX = fullWidth;
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if(limitSlides == 2){
        //enable
        limitSlides = [_assets count];
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint offset = scrollView.contentOffset;
    
    if(offset.x > maxScrolledX){
        
        maxScrolledX = offset.x + 10;
        
        offset.x += assetWidth;
        [_slideDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            LensSlide * slide = obj;
            //if content is showing slide, load image
            if(CGRectContainsPoint(slide.frame, offset)){
                //only if image is not already set
                if(!slide.imageView.image){
                    UIImage * img = [UIImage lensImageNamed:slide.intendedName withAsset:slide.assetId];
                    if(img)
                        [slide.imageView setImage:img];
                }
            }
            
        }];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    //stop on current scrollview
    CGPoint offset = scrollView.contentOffset;
    CGFloat fullWidth = assetWidth + 2 * xPadding;
    
    //decide what picture to go to
    NSInteger num = (offset.x + (fullWidth/2)) / fullWidth;
    CGRect target = CGRectMake(num * fullWidth, 0, fullWidth, assetHeight);
    
    //animate scroll to discrete target
    [scrollView scrollRectToVisible:target animated:YES];
    
}


@end
