//
//  LensAuthor.h
//  LensApp
//
//  Created by Xtreme Dev on 1/28/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LensPost.h"

@interface LensAuthor : NSManagedObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet * posts;


@end
