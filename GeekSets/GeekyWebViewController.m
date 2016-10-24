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
#import "Utility.h"

@import GoogleMobileAds;

@interface GeekyWebViewController () <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic) DZNWebViewController* webViewController;

@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@property (nonatomic) NSTimer* bannerAdTimer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerAdHeight;

@end

@implementation GeekyWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = APP_COLOR;
    [self setUpImageBackButton];
    
    BOOL isBannerAdDisabled = [[Utility sharedInsance] getIsAdDisabled:bannerAdWebView];
    if (isBannerAdDisabled) {
        self.bannerAdHeight.constant = 0;
    }
    else {
      [self createBannerAdTimer];   
    }
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
    self.webViewController.showLoadingProgress = YES;
    self.webViewController.allowHistory = YES;
    self.webViewController.hideBarsWithGestures = YES;
    
    [NC willMoveToParentViewController:self];
    self.webViewController.view.frame =  NC.view.frame = self.containerView.frame;
    
    [self addChildViewController:NC];
    [self.view addSubview:NC.view];
    [NC didMoveToParentViewController:self];
}

#pragma mark - Banner Ads

- (void) createBannerAdTimer {
    [self createBannerAd:nil];
    self.bannerAdTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(createBannerAd:) userInfo:nil repeats:YES];
}

- (void) createBannerAd:(NSTimer*) timer {
    self.bannerView.adUnitID = @"ca-app-pub-3743202420941577/2951813244";
    self.bannerView.rootViewController = self;
    self.bannerView.adSize = kGADAdSizeSmartBannerPortrait ;
    [self.bannerView loadRequest:[GADRequest request]];
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
    self.bannerAdTimer = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
