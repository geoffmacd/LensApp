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
    
    [self.contentView setBackgroundColor:[UIColor blackColor]];
}

-(void)configureCellForPost:(LensPost*)post{
    
    _postId = post.objectID;
    _context = post.managedObjectContext;
    
    [self.titleLabel setText:post.title];
    [self.excerptText setText:post.excerpt];
    [self.authorLabel setText:post.author.name];
    
    
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _authorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    _dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString * dateStr = [formatter stringFromDate:post.date];
    [self.dateLabel setText:dateStr];
    
    [self.slideView setPost:post withContext:_context];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
