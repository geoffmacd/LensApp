//
//  LensDetailViewController.h
//  LensApp
//
//  Created by Xtreme Dev on 1/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LensSlideView.h"
#import "LensPost.h"

@interface LensDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property LensPost * post;

@property (weak, nonatomic) IBOutlet UIWebView *webview;

-(void)setthis:(LensPost*)post;

@end
