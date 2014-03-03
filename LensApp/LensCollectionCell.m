//
//  LensCollectionCell.m
//  LensApp
//
//  Created by Xtreme Dev on 2/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensCollectionCell.h"
#import "LensAuthor.h"
#import "LensSlideView.h"
#import "LensAsset.h"
#import "UIImage+UILensImage.h"

@implementation LensCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}


-(void)configureCellForPost:(LensPost*)post{
    
    _slideview.backgroundColor = [UIColor clearColor];
    
    _postId = post.objectID;
    _context = post.managedObjectContext;
    
    [self.title setText:post.title];
    [self.excerpt setText:post.excerpt];
    [self.author setText:post.author.name];
    [self.date setText:post.author.name];
    
    
    _title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//    _author.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _date.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _excerpt.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString * dateStr = [formatter stringFromDate:post.date];
    [self.date setText:dateStr];
    
    _slideview.contentMode = UIViewContentModeScaleAspectFit;
    
    LensAsset * asset = [post.assets firstObject];
    UIImage * image = [UIImage lensImageNamed:asset.filename withAsset:asset.objectID];
    //if no image, request has been sent and we can expect a notification
    if(!image)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageRetrieved:) name:[asset.imageUrl lastPathComponent] object:nil];
    else
        [_slideview setImage:image];

}

-(void)imageRetrieved:(NSNotification*)notification{
    
    [self performSelectorOnMainThread:@selector(replaceImage:) withObject:notification waitUntilDone:YES];
}

-(void)replaceImage:(NSNotification*)notification{
    
    NSManagedObjectID * assetId = notification.userInfo[@"assetId"];
    NSString * filename = notification.name;
    //replace only that slide with correct image
    
    //should be in dict
    UIImage * newImage = [UIImage lensImageNamed:filename withAsset:assetId];
    [_slideview setImage:newImage];
}

@end
