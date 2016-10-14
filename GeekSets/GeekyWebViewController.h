//
//  GeekyWebViewController.h
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 29/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GeekyWebViewController : UIViewController

@property (nonatomic) NSString* url;

- (void) loadWebViewControllerForURL:(NSString*) url;

@end
