//
//  PagedViewController.m
//  GeekyOnboarding
//
//  Created by Abhijeet Mishra on 05/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "PagedViewController.h"
#import "IFTTTAnimator.h"
#import "IFTTTAlphaAnimation.h"
#import "IFTTTLayerStrokeEndAnimation.h"
#import "IFTTTHideAnimation.h"
#import "IFTTTPathPositionAnimation.h"
#import "IFTTTConstraintMultiplierAnimation.h"
#import "IFTTTFrameAnimation.h"
#import "IFTTTRotationAnimation.h"
#import "IFTTTScaleAnimation.h"
#import "CommonConstants.h"
#import <Masonry/Masonry.h>


@interface PagedViewController () <UICollisionBehaviorDelegate>

@property (nonatomic) UIDynamicAnimator* bounceAnimator;
@property (nonatomic) UIGravityBehavior* gravityBehavior;

@property (nonatomic) UIImageView* geekSetsLogoImageView;
@property (nonatomic) NSLayoutConstraint *geekSetsVerticalConstraint;

@property (nonatomic) UIImageView* amazonImageView;
@property (nonatomic) UIImageView* ciscoImageView;
@property (nonatomic) UIImageView* facebookImageView;
@property (nonatomic) UIImageView* googleImageView;
@property (nonatomic) UIImageView* microsoftImageView;
@property (nonatomic) UIImageView* oracleImageView;
@property (nonatomic) UIImageView* yahooImageView;

@property (nonatomic) UIImageView* onboardingArrow;

@property (nonatomic) UIImageView* arrowListIntro;
@property (nonatomic) UIImageView* arrowListPrimary;
@property (nonatomic) UIImageView* arrowListSecondary;
@property (nonatomic) UIImageView* arrowInfoTickListImageView;
@property (nonatomic) UIImageView* arrowInforLoginImageView;

@property (nonatomic) UIImageView* onboardingIntroImageView;
@property (nonatomic) UIImageView* primaryListImageView;
@property (nonatomic) UIImageView* secondaryListImageView;
@property (nonatomic) UIImageView* tickListImageView;
@property (nonatomic) UIImageView* loginOnboardingImageView;

@property (nonatomic) UIImageView* syncImageView;

@property (nonatomic) UIButton* startButton;

@property (nonatomic) UIView* dashedLineView;

@property (nonatomic) UILabel* primaryListLabel;

@property (nonatomic) CAShapeLayer *dashedLineLayer1;
@property (nonatomic) UIImageView* arrowImageView;

@property (nonatomic) BOOL isEvenRotation;

@property (nonatomic) int collisionCount;

@property (nonatomic) IFTTTPathPositionAnimation *arrowFlyingAnimation;

@property (nonatomic) UIPageControl* pageControl;

@end

@implementation PagedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureViews];
    [self configureAnimations];
    [self configurePageControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageOffSetChanged:) name:NOTIFICATION_TYPE_ONBOARDING_PAGE_OFFSET object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarHidden = YES;
    //[self bounceGeekSetsImageView];
    self.view.userInteractionEnabled = NO;
     [self animateGeekSetsImageView];
}

- (void) configureViews {
  
    self.geekSetsLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"geeksets_logo"]];
    self.geekSetsLogoImageView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.geekSetsLogoImageView.layer.shadowOffset = CGSizeMake(3, 3);
    self.geekSetsLogoImageView.layer.shadowOpacity = 0.6;
    self.geekSetsLogoImageView.layer.shadowRadius = 1.0;
    
    self.onboardingIntroImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding_intro_screen"]];
    self.primaryListImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"primary_list"]];
    self.secondaryListImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"secondary_list"]];
    self.tickListImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick_list"]];
    self.loginOnboardingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_onboarding"]];
    
    self.amazonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"amazon"]];
    self.ciscoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cisco"]];
    self.facebookImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebook"]];
    self.googleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"google"]];
    self.microsoftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"microsoft"]];
    self.oracleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"oracle"]];
    self.yahooImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yahoo"]];
    
    self.onboardingArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding_arrow"]];
    
    BOOL isSmallDevice = (IS_IPHONE_4_OR_LESS || IS_IPHONE_5);
    
    self.arrowListIntro = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isSmallDevice?(@"arrow_info_intro"):(@"big_arrow_info_intro"))]];
    self.arrowListPrimary = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isSmallDevice?(@"arrow_info_primary"):(@"big_arrow_info_primary"))]];
    self.arrowListSecondary = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isSmallDevice?(@"arrow_info_secondary"):(@"big_arrow_info_secondary"))]];
    self.arrowInfoTickListImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isSmallDevice?(@"arrow_info_tick_list"):(@"big_arrow_info_tick_list"))]];
    self.arrowInforLoginImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(isSmallDevice?(@"arrow_info_login"):(@"big_arrow_info_login"))]];
    
    self.arrowListIntro.hidden = YES;
    
    self.dashedLineView = [UIView new];
    
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    
    self.syncImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sync"]];
    self.syncImageView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.syncImageView.layer.shadowOffset = CGSizeMake(3, 3);
    self.syncImageView.layer.shadowOpacity = 0.6;
    self.syncImageView.layer.shadowRadius = 1.0;
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 60)];
    [self.startButton setImage:[UIImage imageNamed:@"start_button"] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.geekSetsLogoImageView.contentMode = self.arrowListIntro.contentMode = self.primaryListImageView.contentMode = self.amazonImageView.contentMode = self.ciscoImageView.contentMode = self.facebookImageView.contentMode = self.googleImageView.contentMode = self.microsoftImageView.contentMode = self.oracleImageView.contentMode = self.yahooImageView.contentMode = self.secondaryListImageView.contentMode = self.arrowListPrimary.contentMode = self.secondaryListImageView.contentMode = self.tickListImageView.contentMode = self.arrowImageView.contentMode = self.arrowInfoTickListImageView.contentMode = self.loginOnboardingImageView.contentMode = self.arrowInforLoginImageView.contentMode = self.startButton.contentMode = self.onboardingArrow.contentMode = self.onboardingIntroImageView.contentMode = self.syncImageView.contentMode = UIViewContentModeScaleAspectFit;
  
    self.onboardingIntroImageView.alpha = self.onboardingIntroImageView.alpha = 0.5f;
    
    [self.contentView addSubview:self.arrowListIntro];
    [self.contentView addSubview:self.onboardingIntroImageView];
    [self.contentView addSubview:self.geekSetsLogoImageView];
    [self.contentView addSubview:self.ciscoImageView];
    [self.contentView addSubview:self.primaryListImageView];
    [self.contentView addSubview:self.facebookImageView];
    [self.contentView addSubview:self.googleImageView];
    [self.contentView addSubview:self.microsoftImageView];
    [self.contentView addSubview:self.oracleImageView];
    [self.contentView addSubview:self.yahooImageView];
    [self.contentView addSubview:self.amazonImageView];
    [self.contentView addSubview:self.secondaryListImageView];
    [self.contentView addSubview:self.arrowListPrimary];
    [self.contentView addSubview:self.arrowListSecondary];
    [self.contentView addSubview:self.tickListImageView];
    [self.contentView addSubview:self.onboardingArrow];
    [self.contentView addSubview:self.dashedLineView];
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.arrowInfoTickListImageView];
    [self.contentView addSubview:self.loginOnboardingImageView];
    [self.contentView addSubview:self.arrowInforLoginImageView];
    [self.contentView addSubview:self.syncImageView];
    [self.contentView addSubview:self.startButton];
}

- (void) configureAnimations {
    [self configureGeekSetsLogoImageView];
    [self configureOnboardingIntroImageView];
    [self configurePrimaryListView];
    [self configureAmazonImageView];
    [self configureCiscoImageView];
    [self configureFacebookImageView];
    [self configureGoogleImageView];
    [self configureMicrosoftImageView];
    [self configureOracleImageView];
    [self configureYahooImageView];
    [self configureSecondaryListImageView];
    [self configureOnboardingArrow];
    [self configureArrowListIntroImageView];
    [self configureArrowListPrimaryImageView];
    [self configureArrowListSecondaryImageView];
    [self configureTickListImageView];
    [self configureDashedLineView];
    [self configureArrowInfoTickListImageView];
    [self configureLoginOnboardingImageView];
    [self configureArrowInfoLoginImageView];
    [self configureSyncImageView];
    [self configureStartButton];
    [self animateCurrentFrame];
}

- (void) configurePageControl {
    
    CGFloat screenCenterX = [UIScreen mainScreen].bounds.size.width/2;
    CGFloat pageControlYPosition = [UIScreen mainScreen].bounds.size.height - 40;
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(screenCenterX - 60, pageControlYPosition, 120, 40)];
    self.pageControl.currentPageIndicatorTintColor = APP_COLOR;
    self.pageControl.pageIndicatorTintColor = APP_COMPLEMENTARY_COLOR;
    self.pageControl.numberOfPages = 5;
    self.pageControl.hidden = YES;
    [self.view addSubview:self.pageControl];
}

- (void)rotateSyncImageView
{
    [UIView animateWithDuration:4.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGAffineTransform transform = CGAffineTransformMakeRotation(self.isEvenRotation?(0):M_PI);
        self.isEvenRotation = !self.isEvenRotation;
        self.syncImageView.transform = transform;
    } completion:NULL];
}

- (void) configureGeekSetsLogoImageView {
   
    [self keepView:self.geekSetsLogoImageView onPages:@[@(0)] atTimes:@[@(0)]];
    [self.geekSetsLogoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@60);
        make.height.equalTo(@60);
    }];
    
   CGFloat verticalConstraintMargin = (IS_IPHONE_6_PLUS)?(-16):((IS_IPHONE_6)?(-12):((IS_IPHONE_5)?(-16):(-16)));
    
    self.geekSetsVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.geekSetsLogoImageView
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.contentView
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:1.f constant:verticalConstraintMargin];
    [self.contentView addConstraint:self.geekSetsVerticalConstraint];
    [self.contentView layoutIfNeeded];
}

#define COLLISION_BEHAVIOR_IDENTIFIER @"invisibleBehaviour"

- (void) bounceGeekSetsImageView {
    self.bounceAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.geekSetsLogoImageView]];
    [self.bounceAnimator addBehavior:self.gravityBehavior];
    
    
    UICollisionBehavior* collisionBehavior =
    [[UICollisionBehavior alloc] initWithItems:@[self.geekSetsLogoImageView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    
    CGFloat wallYValue = self.geekSetsLogoImageView.frame.origin.y + self.geekSetsLogoImageView.frame.size.height + 40;
    
    //add invisible boundary
    CGPoint startPoint = CGPointMake(0, wallYValue);
    [collisionBehavior addBoundaryWithIdentifier:COLLISION_BEHAVIOR_IDENTIFIER fromPoint:startPoint toPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, wallYValue)];
    collisionBehavior.collisionDelegate = self;
    [self.bounceAnimator addBehavior:collisionBehavior];
    
    UIDynamicItemBehavior *elasticityBehavior =
    [[UIDynamicItemBehavior alloc] initWithItems:@[self.geekSetsLogoImageView]];
    elasticityBehavior.elasticity = 0.7f;
    [self.bounceAnimator addBehavior:elasticityBehavior];
}

//collisionbehavior delegate methods
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(nullable id <NSCopying>)identifier atPoint:(CGPoint)p {
    if ([(NSString*)identifier isEqualToString:COLLISION_BEHAVIOR_IDENTIFIER]) {
        self.collisionCount++;
        if (self.collisionCount == 2) {
            [self.bounceAnimator removeAllBehaviors];
            [self animateGeekSetsImageView];
        }
    }
}

- (void) animateGeekSetsImageView {
    
    CGFloat animateMargin = (IS_IPHONE_6_PLUS)?(-80):((IS_IPHONE_6)?(-80):((IS_IPHONE_5)?(-60):((IS_IPAD_PRO_12INCH)?(-180):((IS_IPAD)?(-120):(-48)))));
    
    [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.geekSetsVerticalConstraint.constant = animateMargin;
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.onboardingIntroImageView.alpha = self.onboardingIntroImageView.alpha = 1;
            self.arrowListIntro.hidden = NO;
            self.geekSetsLogoImageView.layer.shadowOpacity = 0;
            [self.contentView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
            self.pageControl.hidden = NO;
        }];
    }];
}

- (void) configureOnboardingIntroImageView {
    [self keepView:self.onboardingIntroImageView onPages:@[@(0)] atTimes:@[@(0)]];
    [self.onboardingIntroImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.width.lessThanOrEqualTo(self.scrollView);
        make.width.equalTo(self.scrollView).multipliedBy(0.5).with.priorityHigh();
        make.height.equalTo(self.scrollView).multipliedBy(0.7).with.priorityHigh();
    }];
    // grow the onboarding list into the background between pages 0 and 1
    IFTTTScaleAnimation *onboardingListScaleAnimation = [IFTTTScaleAnimation animationWithView:self.onboardingIntroImageView];
    [onboardingListScaleAnimation addKeyframeForTime:-1 scale:0.5 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [onboardingListScaleAnimation addKeyframeForTime:0 scale:1];
    [onboardingListScaleAnimation addKeyframeForTime:1 scale:0.5];
    [self.animator addAnimation:onboardingListScaleAnimation];
}

- (void) configurePrimaryListView {
    [self keepView:self.primaryListImageView onPages:@[@(1),@(-1)] atTimes:@[@(1),@(2)]];
    [self.primaryListImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.width.lessThanOrEqualTo(self.scrollView);
        make.width.equalTo(self.scrollView).multipliedBy(0.5).with.priorityHigh();
        make.height.equalTo(self.scrollView).multipliedBy(0.7).with.priorityHigh();
    }];
 
    // grow the primary list into the background between pages 0 and 1
    IFTTTScaleAnimation *primaryListScaleAnimation = [IFTTTScaleAnimation animationWithView:self.primaryListImageView];
    [primaryListScaleAnimation addKeyframeForTime:0 scale:0.5 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [primaryListScaleAnimation addKeyframeForTime:1 scale:1];
    [primaryListScaleAnimation addKeyframeForTime:2 scale:0.5];
    [self.animator addAnimation:primaryListScaleAnimation];
}

- (void) configureAmazonImageView {
    [self keepView:self.amazonImageView onPages:@[@(1.38),@(2)] atTimes:@[@(1),@(2)]];
    
    [self.amazonImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.primaryListImageView.mas_centerY);
    }];
    
    IFTTTHideAnimation *amazonHideAnimation = [IFTTTHideAnimation animationWithView:self.amazonImageView hideAt:1.99];
    [self.animator addAnimation:amazonHideAnimation];
    
    CGFloat scale = (IS_IPHONE_6_PLUS)?(2.5):((IS_IPHONE_6)?(2.5):((IS_IPHONE_5)?(2):(2)));
    
    //shrink the secondary list into the background between pages 0 and 1
    IFTTTScaleAnimation *amazonScaleAnimation = [IFTTTScaleAnimation animationWithView:self.amazonImageView];
    [amazonScaleAnimation addKeyframeForTime:0.95 scale:1 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [amazonScaleAnimation addKeyframeForTime:1.9 scale:scale];
  //  [amazonScaleAnimation addKeyframeForTime:1.99 scale:0.5];
    [amazonScaleAnimation addKeyframeForTime:0 scale:0.01];
    [self.animator addAnimation:amazonScaleAnimation];
}

- (void) configureCiscoImageView {
    [self keepView:self.ciscoImageView onPages:@[@(0.64),@(4),@(6)] atTimes:@[@(1),@(2),@(4)]];
    
    [self.ciscoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.primaryListImageView.mas_top).offset(100);
    }];
    IFTTTScaleAnimation* ciscoScaleAnimation = [IFTTTScaleAnimation animationWithView:self.ciscoImageView];
    [ciscoScaleAnimation addKeyframeForTime:0 scale:0.01];
    [ciscoScaleAnimation addKeyframeForTime:0.9 scale:1.0];
    [self.animator addAnimation:ciscoScaleAnimation];
}

- (void) configureFacebookImageView {
    
    CGFloat margin = (IS_IPHONE_6_PLUS)?(100):((IS_IPHONE_6)?(100):((IS_IPHONE_5)?(100):(60)));
    
    [self keepView:self.facebookImageView onPages:@[@(1.26),@(4),@(5)] atTimes:@[@(1),@(2),@(4)]];
    
    [self.facebookImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.primaryListImageView.mas_top).offset(margin);
    }];
    IFTTTScaleAnimation* facebookScaleAnimation = [IFTTTScaleAnimation animationWithView:self.facebookImageView];
    [facebookScaleAnimation addKeyframeForTime:0 scale:0.01];
    [facebookScaleAnimation addKeyframeForTime:1.0 scale:1.0];
    [self.animator addAnimation:facebookScaleAnimation];
}

- (void) configureGoogleImageView {
    [self keepView:self.googleImageView onPages:@[@(1.34),@(4),@(5)] atTimes:@[@(1),@(2),@(4)]];
    
    [self.googleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.primaryListImageView.mas_bottom).offset(-80);
    }];
    IFTTTScaleAnimation* googleScaleAnimation = [IFTTTScaleAnimation animationWithView:self.googleImageView];
    [googleScaleAnimation addKeyframeForTime:0 scale:0.01];
    [googleScaleAnimation addKeyframeForTime:1.0 scale:1.0];
    [self.animator addAnimation:googleScaleAnimation];
}

- (void) configureMicrosoftImageView {
    [self keepView:self.microsoftImageView onPages:@[@(0.64),@(3),@(6)] atTimes:@[@(1),@(2),@(3)]];
    
    [self.microsoftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.primaryListImageView.mas_centerY).offset(-4);
    }];
    IFTTTScaleAnimation* microsoftScaleAnimation = [IFTTTScaleAnimation animationWithView:self.microsoftImageView];
    [microsoftScaleAnimation addKeyframeForTime:0 scale:0.01];
    [microsoftScaleAnimation addKeyframeForTime:0.5 scale:1.0];
    [self.animator addAnimation:microsoftScaleAnimation];
}

- (void) configureOracleImageView {
    
    CGFloat topMargin = (IS_IPHONE_6_PLUS)?(-60):((IS_IPHONE_6)?(-60):((IS_IPHONE_5)?(-60):(-20)));
    
    [self keepView:self.oracleImageView onPages:@[@(0.68),@(3.5),@(6)] atTimes:@[@(1),@(2),@(3)]];
    
    [self.oracleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.primaryListImageView.mas_bottom).offset(topMargin);
    }];
    IFTTTScaleAnimation* oracleScaleAnimation = [IFTTTScaleAnimation animationWithView:self.oracleImageView];
    [oracleScaleAnimation addKeyframeForTime:0 scale:0.01];
    [oracleScaleAnimation addKeyframeForTime:1.0 scale:1.0];
    [self.animator addAnimation:oracleScaleAnimation];
}

- (void) configureYahooImageView {
    
    CGFloat topMargin = (IS_IPHONE_6_PLUS)?(24):((IS_IPHONE_6)?(24):((IS_IPHONE_5)?(24):(4)));
    
    [self keepView:self.yahooImageView onPages:@[@(0.85),@(4),@(5)] atTimes:@[@(1),@(2),@(4)]];
    
    [self.yahooImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.primaryListImageView.mas_top).offset(topMargin);
    }];
    IFTTTScaleAnimation* yahooScaleAnimation = [IFTTTScaleAnimation animationWithView:self.yahooImageView];
    [yahooScaleAnimation addKeyframeForTime:0 scale:0.01];
    [yahooScaleAnimation addKeyframeForTime:0.7 scale:1.0];
    [self.animator addAnimation:yahooScaleAnimation];
}

- (void) configureSecondaryListImageView {
    [self keepView:self.secondaryListImageView onPages:@[@(2)] atTimes:@[@(2)]];
    
    [self.secondaryListImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.width.lessThanOrEqualTo(self.scrollView);
        make.width.equalTo(self.scrollView).multipliedBy(0.5).with.priorityHigh();
        make.height.equalTo(self.scrollView).multipliedBy(0.7).with.priorityHigh();
    }];
    
    IFTTTHideAnimation *secondaryListHideAnimation = [IFTTTHideAnimation animationWithView:self.secondaryListImageView hideAt:1];
    [self.animator addAnimation:secondaryListHideAnimation];

    IFTTTHideAnimation *secondaryListShowAnimation = [IFTTTHideAnimation animationWithView:self.secondaryListImageView showAt:1.99];
    [self.animator addAnimation:secondaryListShowAnimation];
    
    // grow the secondary list into the background between pages 0 and 1
    IFTTTScaleAnimation *secondaryListScaleAnimation = [IFTTTScaleAnimation animationWithView:self.secondaryListImageView];
    [secondaryListScaleAnimation addKeyframeForTime:1.9 scale:0.5];
    [secondaryListScaleAnimation addKeyframeForTime:2 scale:1];
    [secondaryListScaleAnimation addKeyframeForTime:3 scale:0.5];
    [self.animator addAnimation:secondaryListScaleAnimation];
}

- (void) configureArrowListIntroImageView {
    [self keepView:self.arrowListIntro onPages:@[@(0)] atTimes:@[@(0)]];
    [self.arrowListIntro mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.onboardingIntroImageView.mas_bottom).offset(20);
    }];
}

- (void) configureArrowListPrimaryImageView {
    [self keepView:self.arrowListPrimary onPages:@[@(1)] atTimes:@[@(1)]];
    
    [self.arrowListPrimary mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.primaryListImageView.mas_bottom).offset(20);
    }];
}

- (void) configureArrowListSecondaryImageView {
    [self keepView:self.arrowListSecondary onPages:@[@(2)] atTimes:@[@(2)]];
    
    [self.arrowListSecondary mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.secondaryListImageView.mas_bottom).offset(20);
    }];
}

- (void) configureTickListImageView {
    [self keepView:self.tickListImageView onPages:@[@(3)] atTimes:@[@(3)]];
    
    [self.tickListImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.width.lessThanOrEqualTo(self.scrollView);
        make.width.equalTo(self.scrollView).multipliedBy(0.5).with.priorityHigh();
        make.height.equalTo(self.scrollView).multipliedBy(0.7).with.priorityHigh();
    }];
    IFTTTScaleAnimation *arrowTickListScaleAnimation = [IFTTTScaleAnimation animationWithView:self.tickListImageView];
    [arrowTickListScaleAnimation addKeyframeForTime:2 scale:0.5 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [arrowTickListScaleAnimation addKeyframeForTime:3 scale:1 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [arrowTickListScaleAnimation addKeyframeForTime:4 scale:0.5 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [self.animator addAnimation:arrowTickListScaleAnimation];
}

- (void) configureDashedLineView {
    
    // Set up the view that contains the airplane view and its dashed line path view
    self.dashedLineLayer1 = [self dashedLineLayer];
    [self.dashedLineView.layer addSublayer:self.dashedLineLayer1];
    
    [self.dashedLineView addSubview:self.arrowImageView];
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.dashedLineView.mas_centerY);
        make.right.equalTo(self.dashedLineView.mas_centerX);
    }];
    
    [self.dashedLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scrollView).offset(55);
        make.width.and.height.equalTo(self.arrowImageView);
    }];
    
    // Keep the left edge of the planePathView at the center of pages 1 and 2
    [self keepView:self.dashedLineView onPages:@[@(2.5)] atTimes:@[@(2)] withAttribute:IFTTTHorizontalPositionAttributeLeft];
    
    // Fly the plane along the path
    self.arrowFlyingAnimation = [IFTTTPathPositionAnimation animationWithView:self.arrowImageView path:self.dashedLineLayer1.path];
    [self.arrowFlyingAnimation addKeyframeForTime:2 animationProgress:0];
    [self.arrowFlyingAnimation addKeyframeForTime:3 animationProgress:1];
    [self.animator addAnimation:self.arrowFlyingAnimation];
    
    // Hide the dashes upon completion
    IFTTTHideAnimation *dashLinenHideAnimation = [IFTTTHideAnimation animationWithView:self.dashedLineView hideAt:2.9];
    [self.animator addAnimation:dashLinenHideAnimation];
    
    // Change the stroke end of the dashed line airplane path to match the plane's current position
    IFTTTLayerStrokeEndAnimation *planePathAnimation = [IFTTTLayerStrokeEndAnimation animationWithLayer:self.dashedLineLayer1];
    [planePathAnimation addKeyframeForTime:2 strokeEnd:0];
    [planePathAnimation addKeyframeForTime:3 strokeEnd:1];
    [self.animator addAnimation:planePathAnimation];
    
    // Fade the plane path view in after page 1 and fade it out again after page 2.5
    IFTTTAlphaAnimation *planeAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.dashedLineView];
    [planeAlphaAnimation addKeyframeForTime:2.06f alpha:0];
    [planeAlphaAnimation addKeyframeForTime:2.08f alpha:1];
    [planeAlphaAnimation addKeyframeForTime:3.5f alpha:1];
    [planeAlphaAnimation addKeyframeForTime:4.f alpha:0];
    [self.animator addAnimation:planeAlphaAnimation];
}

- (CGPathRef)dashedLinePath
{
    CGFloat endXCoordinate = (IS_IPHONE_6_PLUS)?(400):((IS_IPHONE_6)?(310):((IS_IPHONE_5)?(320):(IS_IPAD_PRO_12INCH?(830):(((IS_IPAD)?(640):(320))))));
    
    CGFloat startXCoordinate = (IS_IPHONE_6_PLUS)?(100):((IS_IPHONE_6)?(84):((IS_IPHONE_5)?(84):(IS_IPAD_PRO_12INCH?(220):(((IS_IPAD)?(180):(84))))));
    
    CGFloat yCoordinate = (IS_IPHONE_6_PLUS)?(-470):((IS_IPHONE_6)?(-424):((IS_IPHONE_5)?(-364):(IS_IPAD_PRO_12INCH?(-864):(((IS_IPAD)?(-660):(-306))))));
    
    // Create a bezier path for the airplane to fly along
    UIBezierPath *airplanePath = [UIBezierPath bezierPath];
    [airplanePath moveToPoint: CGPointMake(startXCoordinate, yCoordinate)];
    [airplanePath addLineToPoint: CGPointMake(endXCoordinate, yCoordinate)];
    return airplanePath.CGPath;
}


- (CAShapeLayer *)dashedLineLayer
{
    // Create a shape layer to draw the airplane's path
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [self dashedLinePath];
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = APP_COLOR.CGColor;
    shapeLayer.lineDashPattern = @[@(20), @(20)];
    shapeLayer.lineWidth = 4;
    shapeLayer.miterLimit = 4;
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    return shapeLayer;
}

- (void) configureOnboardingArrow {
    [self keepView:self.onboardingArrow onPages:@[@(2.65),@(2.7),@(2.72)] atTimes:@[@(3),@(2.8),@(2.9)]];
    
   NSLayoutConstraint *arrowVerticalConstraint = [NSLayoutConstraint constraintWithItem:self.onboardingArrow
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.loginOnboardingImageView
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:1.f constant:0.f];
    [self.contentView addConstraint:arrowVerticalConstraint];
    IFTTTConstraintMultiplierAnimation *arrowVerticalAnimation = [IFTTTConstraintMultiplierAnimation animationWithSuperview:self.contentView
                                                                                                                constraint:arrowVerticalConstraint
                                                                                                                 attribute:IFTTTLayoutAttributeHeight
                                                                                                             referenceView:self.loginOnboardingImageView];
    [arrowVerticalAnimation addKeyframeForTime:2 multiplier:1.14f];
    [arrowVerticalAnimation addKeyframeForTime:3 multiplier:0.13f];
    [self.animator addAnimation:arrowVerticalAnimation];
    
    IFTTTHideAnimation* arrowHideAnimation = [IFTTTHideAnimation animationWithView:self.onboardingArrow showAt:2.1];
    [self.animator addAnimation:arrowHideAnimation];
}

- (void) configureArrowInfoTickListImageView {
    [self keepView:self.arrowInfoTickListImageView onPages:@[@(3)] atTimes:@[@(3)]];
    [self.arrowInfoTickListImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tickListImageView.mas_bottom).offset(20);
    }];
}

- (void) configureLoginOnboardingImageView {
    [self keepView:self.loginOnboardingImageView onPages:@[@(4)] atTimes:@[@(4)]];
    [self.loginOnboardingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(20);
        make.width.lessThanOrEqualTo(self.scrollView);
        make.width.equalTo(self.scrollView).multipliedBy(0.5).with.priorityHigh();
        make.height.equalTo(self.scrollView).multipliedBy(0.7).with.priorityHigh();
    }];
    
    IFTTTScaleAnimation *loginOnboardingScaleAnimation = [IFTTTScaleAnimation animationWithView:self.loginOnboardingImageView];
    [loginOnboardingScaleAnimation addKeyframeForTime:3 scale:0.5 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [loginOnboardingScaleAnimation addKeyframeForTime:4 scale:1 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [self.animator addAnimation:loginOnboardingScaleAnimation];
}

- (void) configureArrowInfoLoginImageView {
    [self keepView:self.arrowInforLoginImageView onPages:@[@(4)] atTimes:@[@(4)]];
    
   CGFloat offSetMargin = (IS_IPHONE_6_PLUS)?(-40):((IS_IPHONE_6)?(-40):((IS_IPHONE_5)?(-40):(0)));
    
    [self.arrowInforLoginImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginOnboardingImageView.mas_bottom).offset(offSetMargin);
    }];
}

- (void) configureSyncImageView {
    
    CGFloat offSetMargin = (IS_IPHONE_6_PLUS)?(-68):((IS_IPHONE_6)?(-62):((IS_IPHONE_5)?(-52):((IS_IPAD_PRO_12INCH)?(-120):(((IS_IPAD)?(-90):(-44))))));
    
    [self keepView:self.syncImageView onPages:@[@(4)] atTimes:@[@(4)]];
    [self.syncImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.scrollView).multipliedBy(0.2).with.priorityHigh();
        make.height.equalTo(self.scrollView).multipliedBy(0.2).with.priorityHigh();
        make.top.equalTo(self.loginOnboardingImageView.mas_centerY).offset(offSetMargin).with.priorityLow();
    }];
    
    IFTTTHideAnimation* syncHideAnimation = [IFTTTHideAnimation animationWithView:self.syncImageView showAt:3.8];
    [self.animator addAnimation:syncHideAnimation];

    //animate the sync image view
    [self rotateSyncImageView];
    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(rotateSyncImageView) userInfo:nil repeats:YES];
}

- (void) configureStartButton {
    [self keepView:self.startButton onPages:@[@(4)] atTimes:@[@(4)]];
    
   CGFloat offSetMargin = (IS_IPHONE_6_PLUS)?(-50):((IS_IPHONE_6)?(-50):((IS_IPHONE_5)?(-50):(-40)));

    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).offset(offSetMargin);
    }];
}

- (void) startButtonPressed:(UIButton*) startButton {
     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_WALKTHROUGH_SEEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIApplication sharedApplication].statusBarHidden = NO;
    if ([self.pagedViewControllerDelegate respondsToSelector:@selector(dismissButtonPressed)]) {
        [self.pagedViewControllerDelegate dismissButtonPressed];
    }
}

- (NSUInteger)numberOfPages
{
    // Tell the scroll view how many pages it should have
    return 5;
}
#pragma mark - iOS8+ Resizing

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
       // [self scaleAirplanePathToSize:size];
    } completion:nil];
}

#pragma mark - iOS7 Orientation Change Resizing

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGSize newPageSize;
    
    if ((UIInterfaceOrientationIsLandscape(self.interfaceOrientation)
         && UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        || (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)
            && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))) {
            
            newPageSize = CGSizeMake(CGRectGetHeight(self.scrollView.frame), CGRectGetWidth(self.scrollView.frame));
        } else {
            newPageSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        }
    
    [UIView animateWithDuration:duration animations:^{
       // [self scaleAirplanePathToSize:newPageSize];
    } completion:nil];
}


- (void)animateCurrentFrame
{
    [self.animator animate:self.pageOffset];
}

-(BOOL)shouldAutorotate {
    return TRUE;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

#pragma mark - NSNotification based methods

- (void) pageOffSetChanged:(NSNotification*) pageOffSetNotification {
    int pageNo = [pageOffSetNotification.object intValue];
    self.pageControl.currentPage = pageNo;
}

- (void) applicationWillEnterForeground {
   // [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(rotateSyncImageView) userInfo:nil repeats:YES];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
