//
//  LensListCell.m
//  LensApp
//
//  Created by Xtreme Dev on 2/3/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensListCell.h"

@implementation LensListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setPost:(LensPost *)post{
    self.post = post;
    
    //set image, icon,date,title,
    
}

-(LensPost *)post{
    return self.post;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
