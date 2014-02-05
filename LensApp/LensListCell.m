//
//  LensListCell.m
//  LensApp
//
//  Created by Xtreme Dev on 2/3/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensListCell.h"

#import "LensAuthor.h"
#import "UIImage+UILensImage.h"

@implementation LensListCell

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self configure];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self configure];
    }
    return self;
}

-(void)configure{
    
    
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    _authorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

-(void)configureCellForPost:(LensPost*)post{
    
    _postId = post.objectID;
    
    [self.titleLabel setText:post.title];
    [self.excerptLabel setText:post.excerpt];
    [self.authorLabel setText:post.author.name];
    
    //must use last path component because file name is not saved until request
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.iconView setImage:[UIImage lensIconNamed:[post.iconUrl lastPathComponent] withPost:_postId]];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString * dateStr = [formatter stringFromDate:post.date];
    [self.dateLabel setText:dateStr];
}

-(LensPost *)post{
    return self.post;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
