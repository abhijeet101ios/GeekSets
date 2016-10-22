//
//  PagedViewController.h
//  GeekyOnboarding
//
//  Created by Abhijeet Mishra on 05/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//



#import "IFTTTAnimatedPagingScrollViewController.h"

@protocol PagedViewControllerDelegate <NSObject>

- (void) dismissButtonPressed;

@end

@interface PagedViewController : IFTTTAnimatedPagingScrollViewController

@property (nonatomic, weak) id <PagedViewControllerDelegate> pagedViewControllerDelegate;

@end
