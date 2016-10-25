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
    self.loginView.hidden = !showLoginScreen;
}

- (void) ab_showLogoutScreen:(BOOL) showLogoutScreen {
    self.logoutView.hidden = !showLogoutScreen;
    if (showLogoutScreen) {
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
    self.navigationController.navigationBarHidden = NO;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
