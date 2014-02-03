//
//  LensBlogCell.m
//  LensApp
//
//  Created by Xtreme Dev on 2/3/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensBlogCell.h"

#import "LensAuthor.h"

@implementation LensBlogCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)configureCellForPost:(LensPost*)post{
    
    _postId = post.objectID;
    
    [self.titleLabel setText:post.title];
    [self.excerptText setText:post.excerpt];
    [self.authorLabel setText:post.author.name];
    
    UILabel * label = (UILabel*)[self viewWithTag:100];
    [label setText:post.title];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
