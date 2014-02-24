//
//  LensCollectionCell.h
//  LensApp
//
//  Created by Xtreme Dev on 2/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LensPost.h"

@interface LensCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UITextView *excerpt;
@property (weak, nonatomic) IBOutlet UIImageView *slideview;


@property NSManagedObjectContext * context;
@property NSManagedObjectID * postId;

-(void)configureCellForPost:(LensPost*)post;

@end
