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

@interface LensBlogCell : UITableViewCell

@property LensPost * post;

@property (weak, nonatomic) IBOutlet UIView *slideShowView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *excerptText;

@end
