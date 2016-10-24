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
@property (weak, nonatomic) IBOutlet GIDSignInButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *loginMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loginImageVIew;

@end

@implementation LoginViewController

#pragma mark - IBOutlets

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
    [self dismissViewController];
}
- (IBAction)loginNotNowPressed:(UIButton *)sender {
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

#pragma mark - Dismiss screen Methods

- (void) dismissViewController {
    [self.navigationController popViewControllerAnimated:NO];
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
    return UIInterfaceOrientationMaskAll;
}

- (void) viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

@end
