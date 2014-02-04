//
//  LensDetailViewController.m
//  LensApp
//
//  Created by Xtreme Dev on 1/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import "LensDetailViewController.h"

#import "LensStory.h"
#import "UIImage+UILensImage.h"
#import "LensAppDelegate.h"

@interface LensDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation LensDetailViewController

#pragma mark - Managing the detail item

-(void)setthis:(LensPost*)post{
    // Update the view.
    _post = post;
    [self configureView];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the post
    LensAppDelegate * appDel = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext * newContext = [appDel threadContext];
    
    [self.slideView setPost:self.post withContext:newContext];
    [self.webview loadHTMLString:self.post.story.htmlContent baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    UINavigationItem * title = [[UINavigationItem alloc] init];
    UIBarButtonItem * custom = [[UIBarButtonItem alloc] initWithImage:[UIImage lensIconNamed:self.post.iconFile withPost:self.post.objectID] style:UIBarButtonItemStylePlain target:nil action:nil];
    [title setLeftBarButtonItem:custom];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
