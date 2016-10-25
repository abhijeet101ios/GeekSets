//
//  LoginViewController.m
//  GeekSets
//
//  Created by Abhijeet Mishra on 24/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "LoginViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "CommonConstants.h"
#import "GSAnalytics.h"

#define NO_OF_VIEWS 500
#define TAG_MULTIPLIER (NO_OF_VIEWS + 1)

@import Firebase;

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *logoutView;
@property (weak, nonatomic) IBOutlet UIImageView *loggedInUserImageView;
@property (weak, nonatomic) IBOutlet UILabel *logoutMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loginImageVIew;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (nonatomic) UIView *randomImageBaseView;

@property (nonatomic) NSTimer* imageTimer;

@property (nonatomic) int currentImageViewNo;
@property (nonatomic) int removedSubViews;
@property (nonatomic) NSMutableArray* imageViewArray;

@end

@implementation LoginViewController

#pragma mark - IBOutlets

- (void) viewDidLoad {
    
    self.activityIndicatorView.hidden = YES;
    [self.activityIndicatorView stopAnimating];
    
    [self gk_updateSignInButtonUI];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:NOTIFICATION_TYPE_USER_LOGGED_IN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logineFailure) name:NOTIFICATION_TYPE_USER_LOGGED_IN_FAILED object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    if ([FIRAuth auth].currentUser) {
        //logged in
        [self ab_showLoginScreen:NO];
        [self ab_showLogoutScreen:YES];
    }
    else {
        //guest user
        [self ab_showLoginScreen:YES];
        [self ab_showLogoutScreen:NO];
    }
}

#pragma mark - UI update methods

- (void) gk_updateSignInButtonUI {
    
    CGFloat spacing = 12;
    
    self.signInButton.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, spacing);
    self.signInButton.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
}

- (IBAction)loginPressed:(UIButton *)sender {
    [self.activityIndicatorView startAnimating];
    
    [[GIDSignIn sharedInstance] signIn];
}

- (IBAction)logoutPressed:(UIButton *)sender {
    
    NSString* userEmail = [FIRAuth auth].currentUser.email;
    NSString* timeStamp = [self ab_getCurrentTimestamp];
    
    NSMutableDictionary* keyDictionary = [@{} mutableCopy];
    
    if (userEmail) {
        [keyDictionary setValue:userEmail forKey:KEY_ANALYTICS_USERID];
    }
    [keyDictionary setValue:timeStamp forKey:KEY_ANALYTICS_TIMESTAMP];
    
    [self ab_setEventName:EVENT_ANALYTICS_LOGOUT_PRESSED forKeys:[keyDictionary mutableCopy]];
    
    NSError* error;
    [[FIRAuth auth] signOut:&error];
    [self ab_showLogoutScreen:NO];
    [self ab_showLoginScreen:YES];
}
- (IBAction)logoutNotNowPressed:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:KEY_IS_LOGIN_SCREEN_SEEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewController];
}
- (IBAction)loginNotNowPressed:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:KEY_IS_LOGIN_SCREEN_SEEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self ab_setEventName:EVENT_ANALYTICS_NOT_NOW_PRESSED forKeys:@{KEY_ANALYTICS_TIMESTAMP:[self ab_getCurrentTimestamp]}];
    [self dismissViewController];
}

#pragma mark - Analytics Methods

- (NSString*) ab_getCurrentTimestamp {
    return [NSString stringWithFormat:@"%f",[NSDate timeIntervalSinceReferenceDate]];
}

- (void) ab_setEventName:(NSString*) eventName forKeys:(NSDictionary*) keys {
    [[GSAnalytics sharedInstance] setEventName:eventName withKeys:keys];
}

#pragma mark - Login callback methods

- (void) loginSuccess {
    //log in success
    [self dismissViewController];
}

- (void) logineFailure {
    //log in failure
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Dismiss screen Methods

- (void) dismissViewController {
    
    if (self.navigationController) {
      [self.navigationController popViewControllerAnimated:NO];
    }
    else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - Show Login/ Logout Methdods

- (void) ab_showLoginScreen:(BOOL) showLoginScreen {
    
    if (showLoginScreen) {
        self.imageTimer = nil;
        [self.randomImageBaseView removeFromSuperview];
        self.randomImageBaseView = nil;
    }
    
    self.loginView.hidden = !showLoginScreen;
}

- (void) ab_showLogoutScreen:(BOOL) showLogoutScreen {
    self.logoutView.hidden = !showLogoutScreen;
    if (showLogoutScreen) {
        
        [self startImageViewAddTimer];
        
        self.logoutMessageLabel.text = [FIRAuth auth].currentUser.displayName;
        if ([FIRAuth auth].currentUser.photoURL) {
            self.loggedInUserImageView.image = [UIImage imageWithData:[[NSData alloc] initWithContentsOfURL:[FIRAuth auth].currentUser.photoURL]];
        }
    }
}

#pragma mark - Orientation Methods

-(BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Status Bar Methods

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) viewWillDisappear:(BOOL)animated {
    //self.navigationController.navigationBarHidden = NO;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 

- (NSString*) getImageForIndex:(int) index {
    NSArray* imageArray = @[@"array",@"binary_tree",@"linked_list",@"queue",@"stack"];
    
    if (index < imageArray.count) {
        return imageArray[index];
    }
    else {
        return imageArray[index%(imageArray.count)];
    }
}



- (void) startImageViewAddTimer {
    
   self.randomImageBaseView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.randomImageBaseView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    [self.view addSubview:self.randomImageBaseView];
    [self.view sendSubviewToBack:self.randomImageBaseView];
    
   self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(addTimerCallback:) userInfo:nil repeats:YES];
}

- (void) addTimerCallback:(NSTimer*) timer {
    
    if (!self.imageViewArray) {
        self.imageViewArray = [@[] mutableCopy];
    }
    
    int index = self.currentImageViewNo;
    CGFloat imageWidth = [self getImageViewDimension];
    
    CGPoint originPoint = [self getRandomPoint];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originPoint.x, originPoint.y, imageWidth, imageWidth)];
    imageView.tag = (index + 1)*TAG_MULTIPLIER;
    imageView.alpha = 0;
    imageView.image = [UIImage imageNamed:[self getImageForIndex:index]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
    [self.randomImageBaseView addSubview:imageView];
    
    [self.imageViewArray addObject:imageView];
    
    self.currentImageViewNo++;
    
    if (self.currentImageViewNo == NO_OF_VIEWS) {
        [timer invalidate];
        timer = nil;
    }
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        imageView.alpha = 1.0;
        imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        
    } completion:^(BOOL finished) {
        // [self fadeOtherImagesExceptWithTags:(int)imageView.tag];
        [UIView animateWithDuration:1 delay:0 options:0 animations:^{
            imageView.alpha = 0.0;
            imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
        } completion:^(BOOL finished) {
            CGPoint originPoint = [self getRandomPoint];
            
            imageView.frame = CGRectMake(originPoint.x, originPoint.y, imageWidth, imageWidth);
            [UIView animateWithDuration:1 delay:0 options:0 animations:^{
                imageView.alpha = 1.0;
                imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            } completion:^(BOOL finished) {
                //  [self fadeOtherImagesExceptWithTags:(int)imageView.tag];
                [UIView animateWithDuration:1 delay:0 options:0 animations:^{
                    imageView.alpha = 0.0;
                    imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
                } completion:^(BOOL finished) {
                    [imageView removeFromSuperview];
                    self.removedSubViews++;
                    if (self.removedSubViews == NO_OF_VIEWS) {
                        //all subviews removed
                    }
                }];
            }];
        }];
    }];
}

- (void) fadeOtherImagesExceptWithTags:(int) visibleImageViewTag {
    for (UIView* subView in self.view.subviews) {
        if (subView.tag%TAG_MULTIPLIER == 0) {
            subView.alpha = 0.6;
        }
    }
    UIView* focusView = [self.view viewWithTag:visibleImageViewTag];
    focusView.alpha = 1.0;
}

- (CGPoint) getRandomPoint {
    CGFloat xPosition = [self getRandomXPosition];
    CGFloat yPosition = [self getRandomYPosition];
    
    CGPoint point = CGPointMake(xPosition, yPosition);
    
    if ([self checkIfOtherImageViewContainsPoint:point]) {
        return [self getRandomPoint];
    }
    return point;
}

- (void) timerVisibleCallback:(NSTimer*) timer {
    UIView* subView = [self.view viewWithTag:((NSNumber*)timer.userInfo).intValue];
    CGPoint originPoint = [self getRandomPoint];
    
    subView.frame = CGRectMake(originPoint.x, originPoint.y, [self getImageViewDimension], [self getImageViewDimension]);
    [UIView animateWithDuration:1 animations:^{
        subView.alpha = 1;
    }];
    NSLog(@"Showing view with tag:%d at time:%f",(int)subView.tag,[NSDate timeIntervalSinceReferenceDate]);
    
}

- (void) timerInvisibleCallback:(NSTimer*) timer {
    UIView* subView = [self.view viewWithTag:((NSNumber*)timer.userInfo).intValue];
    CGPoint originPoint = [self getRandomPoint];
    
    subView.frame = CGRectMake(originPoint.x, originPoint.y, [self getImageViewDimension], [self getImageViewDimension]);
    [UIView animateWithDuration:1 animations:^{
        subView.alpha = 0;
    }];
    NSLog(@"Hiding view with tag:%d at time:%f",(int)subView.tag,[NSDate timeIntervalSinceReferenceDate]);
    
}

- (CGFloat) getRandomXPosition {
    int maxX = [UIScreen mainScreen].bounds.size.width - [self getImageViewDimension];
    
    NSInteger randomNumber = arc4random() % maxX;
    
    return randomNumber;
}

- (CGFloat) getRandomYPosition {
    int maxX = [UIScreen mainScreen].bounds.size.height - [self getImageViewDimension];
    
    NSInteger randomNumber = arc4random() % maxX;
    
    return randomNumber;
}

- (BOOL) checkIfOtherImageViewContainsPoint:(CGPoint) point {
    for (UIImageView* imageView in self.imageViewArray) {
        // CGPoint locationInView = [imageView convertPoint:point fromView:imageView.window];
        if ( CGRectContainsPoint(imageView.frame, point) ) {
            // Point lies inside the bounds.
            return YES;
        }
    }
    return NO;
}


- (CGFloat) getImageViewDimension {
    //    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width/NO_OF_VIEWS;
    //    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height/NO_OF_VIEWS;
    
    
    
    return MIN(120, 120);
}

@end
