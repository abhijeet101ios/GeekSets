//
//  GeekyWebViewController.m
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 29/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "GeekyWebViewController.h"
#import "DZNWebViewController.h"
#import "CommonConstants.h"

@interface GeekyWebViewController () <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic) DZNWebViewController* webViewController;

@end

@implementation GeekyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = APP_COLOR;
    [self setUpImageBackButton];
}

- (void) viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void) viewDidAppear:(BOOL)animated {
    [self loadWebViewControllerForURL:self.url];
}

- (void) loadWebViewControllerForURL:(NSString*) url {
    self.webViewController = [[DZNWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    UINavigationController *NC = [[UINavigationController alloc] initWithRootViewController:self.webViewController];
    
    self.webViewController.supportedWebNavigationTools = DZNWebNavigationToolAll;
    self.webViewController.supportedWebActions = DZNWebActionAll;
    //WVC.webNavigationPrompt = DZNWebNavigationPromptAll;
    self.webViewController.showLoadingProgress = YES;
    self.webViewController.allowHistory = YES;
    self.webViewController.hideBarsWithGestures = YES;
    
    [NC willMoveToParentViewController:self];
    self.webViewController.view.frame =  NC.view.frame = self.containerView.frame;
    
    [self addChildViewController:NC];
    [self.view addSubview:NC.view];
    [NC didMoveToParentViewController:self];
}

- (void)setUpImageBackButton
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
    [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    UIBarButtonItem *barBackButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = barBackButtonItem;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    //    self.navigationItem.hidesBackButton = YES;
}
- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    if (self.webViewController.webView.canGoBack) {
        [self.webViewController.webView goBack];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dealloc {
    self.webViewController = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
