//
//  LensArchiveParse.h
//  LensApp
//
//  Created by Geoff MacDonald on 1/31/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensRequest.h"


@interface LensArchiveParse : LensRequest

- (instancetype)initWithData:(NSData *)parseData;

@end
