//
//  LensCollectionViewController.h
//  LensApp
//
//  Created by Xtreme Dev on 2/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCollectionCellIdent    @"CollectionCell"

@class LensDetailViewController;

@interface LensCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) LensDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
