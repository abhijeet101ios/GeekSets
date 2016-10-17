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
#import "IFTTTRotationAnimation.h"
#import "IFTTTScaleAnimation.h"
#import "CommonConstants.h"
#import <Masonry/Masonry.h>


@interface PagedViewController ()

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

@property (nonatomic) UIButton* startButton;

@property (nonatomic) UIView* dashedLineView;

@property (nonatomic) UILabel* primaryListLabel;

@property (nonatomic, strong) CAShapeLayer *dashedLineLayer;
@property (nonatomic) UIImageView* arrowImageView;

@property (nonatomic, strong) IFTTTPathPositionAnimation *arrowFlyingAnimation;

@end

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

@implementation PagedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureViews];
    [self configureAnimations];
}

- (void) configureViews {
  
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
    
    self.arrowListIntro = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_info_intro"]];
    self.arrowListPrimary = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_info_primary"]];
    self.arrowListSecondary = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_info_secondary"]];
    self.arrowInfoTickListImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_info_tick_list"]];
    self.arrowInforLoginImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_info_login"]];
    
    self.onboardingIntroImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onboarding_intro_screen"]];
    
    self.dashedLineView = [UIView new];
    
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 60)];
    [self.startButton setImage:[UIImage imageNamed:@"start_button"] forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
   self.arrowListIntro.contentMode = self.primaryListImageView.contentMode = self.amazonImageView.contentMode = self.ciscoImageView.contentMode = self.facebookImageView.contentMode = self.googleImageView.contentMode = self.microsoftImageView.contentMode = self.oracleImageView.contentMode = self.yahooImageView.contentMode = self.secondaryListImageView.contentMode = self.arrowListPrimary.contentMode = self.secondaryListImageView.contentMode = self.tickListImageView.contentMode = self.arrowImageView.contentMode = self.arrowInfoTickListImageView.contentMode = self.loginOnboardingImageView.contentMode = self.arrowInforLoginImageView.contentMode = self.startButton.contentMode = self.onboardingArrow.contentMode = self.onboardingIntroImageView.contentMode = UIViewContentModeScaleAspectFit;
  
    [self.contentView addSubview:self.arrowListIntro];
    [self.contentView addSubview:self.onboardingIntroImageView];
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
    [self.contentView addSubview:self.startButton];
}

- (void) configureAnimations {
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
    [self configureStartButton];
    [self animateCurrentFrame];
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
    [amazonScaleAnimation addKeyframeForTime:1.99 scale:scale];
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
  //  [secondaryListScaleAnimation addKeyframeForTime:1 scale:0.5 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
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
    [self keepView:self.tickListImageView onPages:@[@(3.2)] atTimes:@[@(3)]];
    
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
    self.dashedLineLayer = [self dashedLineLayer];
    [self.dashedLineView.layer addSublayer:self.dashedLineLayer];
    
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
    self.arrowFlyingAnimation = [IFTTTPathPositionAnimation animationWithView:self.arrowImageView path:self.dashedLineLayer.path];
    [self.arrowFlyingAnimation addKeyframeForTime:2 animationProgress:0];
    [self.arrowFlyingAnimation addKeyframeForTime:3 animationProgress:1];
    [self.animator addAnimation:self.arrowFlyingAnimation];
    
    //hide the dashes upon completion
    IFTTTHideAnimation *dashLinenHideAnimation = [IFTTTHideAnimation animationWithView:self.dashedLineView hideAt:2.9];
    [self.animator addAnimation:dashLinenHideAnimation];
    
    // Change the stroke end of the dashed line airplane path to match the plane's current position
    IFTTTLayerStrokeEndAnimation *planePathAnimation = [IFTTTLayerStrokeEndAnimation animationWithLayer:self.dashedLineLayer];
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
    CGFloat endXCoordinate = (IS_IPHONE_6_PLUS)?(400):((IS_IPHONE_6)?(360):((IS_IPHONE_5)?(320):(320)));
    
    CGFloat startXCoordinate = (IS_IPHONE_6_PLUS)?(100):((IS_IPHONE_6)?(84):((IS_IPHONE_5)?(84):(84)));
    
    CGFloat yCoordinate = (IS_IPHONE_6_PLUS)?(-470):((IS_IPHONE_6)?(-420):((IS_IPHONE_5)?(-364):(-306)));
    
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
    [self keepView:self.onboardingArrow onPages:@[@(2.85)] atTimes:@[@(3)]];
    
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
    [arrowVerticalAnimation addKeyframeForTime:3 multiplier:0.03f];
    [self.animator addAnimation:arrowVerticalAnimation];
    
    IFTTTHideAnimation* arrowHideAnimation = [IFTTTHideAnimation animationWithView:self.onboardingArrow showAt:2.5];
    [self.animator addAnimation:arrowHideAnimation];
}

- (void) configureArrowInfoTickListImageView {
    [self keepView:self.arrowInfoTickListImageView onPages:@[@(3.2)] atTimes:@[@(3)]];
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
    
    [self.arrowInforLoginImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginOnboardingImageView.mas_bottom).offset(-40);
    }];
}

- (void) configureStartButton {
    [self keepView:self.startButton onPages:@[@(4)] atTimes:@[@(4)]];
    
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-20);
    }];
    
    IFTTTScaleAnimation *startButtonScaleAnimation = [IFTTTScaleAnimation animationWithView:self.startButton];
    [startButtonScaleAnimation addKeyframeForTime:3 scale:0.1 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [startButtonScaleAnimation addKeyframeForTime:4 scale:1 withEasingFunction:IFTTTEasingFunctionEaseInQuad];
    [self.animator addAnimation:startButtonScaleAnimation];
}

- (void) startButtonPressed:(UIButton*) startButton {
     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_WALKTHROUGH_SEEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIApplication sharedApplication].statusBarHidden = NO;
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

@end
