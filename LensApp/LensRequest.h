//
//  LensRequest.h
//  LensApp
//
//  Created by Xtreme Dev on 1/30/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LensRequest : NSOperation

@property (copy) NSString * xmlString;
@property NSManagedObjectContext * context;

/**
 * instantiates with data and new context created from app delegate
 * @author Geoff MacDonald
 *
 */
- (instancetype)initWithData:(NSData *)parseData;

/**
 * saves thread specific object context which will cause views to be notified
 * @author Geoff MacDonald
 *
 */
-(void)saveContext;

@end
