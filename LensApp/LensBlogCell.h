//
//  LensBlogCell.h
//  LensApp
//
//  Created by Xtreme Dev on 2/3/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LensPost.h"
#import "LensAsset.h"
#import "LensNetworkController.h"
#import "LensSlideView.h"

@interface LensBlogCell : UITableViewCell

@property NSManagedObjectContext * context;
@property NSManagedObjectID * postId;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *excerptText;
@property (weak, nonatomic) IBOutlet LensSlideView *slideView;

-(void)configureCellForPost:(LensPost*)post;

@end
