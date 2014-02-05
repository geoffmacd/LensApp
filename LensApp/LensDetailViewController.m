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
    [self.webview loadHTMLString:self.post.story.htmlContent baseURL:nil];
    
    [self setTitle:_post.title];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController.view setTintColor:[UIColor grayColor]];
    
    [self.webview setBackgroundColor:[UIColor blackColor]];
    
    [self configureView];
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
