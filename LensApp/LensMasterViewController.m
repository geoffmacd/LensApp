//
//  LensMasterViewController.m
//  LensApp
//
//  Created by Xtreme Dev on 1/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensMasterViewController.h"

#import "LensDetailViewController.h"
#import "LensNetworkController.h"
#import "LensStory.h"
#import "LensBlogCell.h"
#import "LensListCell.h"
#import "LensSlideView.h"

@interface LensMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation LensMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

-(void)viewWillAppear:(BOOL)animated{
    
    //retrieve current posts
    [[LensNetworkController sharedNetwork] getCurrentPosts];
    
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//
//    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
//    [offsetComponents setMonth:-1];
//
//    [[LensNetworkController sharedNetwork] getArchivePosts:[NSDate date] withEnd:[gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    self.detailViewController = (LensDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //observe persistence changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextWasSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification object:nil];
    //refresh finishes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshComplete)
                                                 name:@"refresh" object:nil];
    
    
    listMode = NO;
    
    
    if(listMode)
       [self.tableView setRowHeight:110];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    UIRefreshControl * refresh = [[UIRefreshControl alloc] init];
    self.refreshControl = refresh;
    [refresh addTarget:self action:@selector(getArchives) forControlEvents:UIControlEventValueChanged];
    
}

-(void)getArchives{
    
    //get more
    [[LensNetworkController sharedNetwork] getArchivePosts];
}

-(void)refreshComplete{
    [self.refreshControl endRefreshing];
}

-(void)contextWasSaved:(NSNotification*)notification{
    
//    [self.refreshControl endRefreshing];
    
    //merge
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(!listMode)
        cell = [tableView dequeueReusableCellWithIdentifier:@"LensBlogCell" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"LensListCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        LensPost *post = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
//        [[LensNetworkController sharedNetwork] getStoryForPost:post.objectID];
//        [[LensNetworkController sharedNetwork] triggerRemainingAssets:post.objectID];
//        [[LensNetworkController sharedNetwork] getIconForPost:post.objectID];
        //        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //
        //        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        //        [offsetComponents setYear:-1];
        //
        //        [[LensNetworkController sharedNetwork] getArchivePosts:[NSDate date] withEnd:[gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0]];
        
        LensStory * story = post.story;
        self.detailViewController.html = story.htmlContent;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        LensPost *post = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
//        [[LensNetworkController sharedNetwork] getStoryForPost:post.objectID];
//        [[LensNetworkController sharedNetwork] triggerRemainingAssets:post.objectID];
//        [[LensNetworkController sharedNetwork] getIconForPost:post.objectID];
//        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//        
//        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
//        [offsetComponents setYear:-1];
//
//        [[LensNetworkController sharedNetwork] getArchivePosts:[NSDate date] withEnd:[gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0]];
        
        
        [[segue destinationViewController] setHtml:post.story.htmlContent];
        [[segue destinationViewController] setPostId:post.objectID];
        [[segue destinationViewController] setIconName:[post.iconUrl lastPathComponent] ];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];//descending from latest
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if(!listMode)
        [self configureBlogCell:(LensBlogCell *)cell atIndexPath:indexPath];
    else
        [self configureListCell:(LensListCell *)cell atIndexPath:indexPath];
}

- (void)configureBlogCell:(LensBlogCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LensPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell configureCellForPost:post];
}

- (void)configureListCell:(LensListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LensPost *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell configureCellForPost:post];
}
@end
