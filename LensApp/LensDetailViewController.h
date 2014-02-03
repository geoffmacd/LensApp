//
//  LensDetailViewController.h
//  LensApp
//
//  Created by Xtreme Dev on 1/24/2014.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LensDetailViewController : UIViewController <UISplitViewControllerDelegate,UIWebViewDelegate>

@property (strong, nonatomic) NSString * html;
@property (copy) NSString * iconName;
@property (strong, nonatomic) NSManagedObjectID * postId;

@property (weak, nonatomic) IBOutlet UIView *slideView;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@end
