//
//  LensLayout.m
//  LensApp
//
//  Created by Xtreme Dev on 2/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensLayout.h"

@implementation LensLayout

-(instancetype)init{
    
    if(self = [super init]){
    }
    
    return self;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSMutableArray * array =[NSMutableArray arrayWithArray:[super layoutAttributesForElementsInRect:rect]];
    
    NSLog(@"%@",[array description]);
    
    
    
//    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        
//        
//        UICollectionViewLayoutAttributes * attr  = obj;
//        
//        
//        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
//        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
//        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, 45.0f * M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
//        
//        attr.transform3D = rotationAndPerspectiveTransform;
//    }];
    
    return array;
    
}


@end
