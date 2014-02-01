//
//  LensDetailViewController.h
//  LensApp
//
//  Created by Xtreme Dev on 1/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LensDetailViewController : UIViewController <UISplitViewControllerDelegate,UIWebViewDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSString * html;

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
