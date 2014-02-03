//
//  LensMasterViewController.h
//  LensApp
//
//  Created by Xtreme Dev on 1/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LensDetailViewController;

#import <CoreData/CoreData.h>
#import "LensPost.h"

@interface LensMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>{
    BOOL listMode;
}

@property (strong, nonatomic) LensDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
