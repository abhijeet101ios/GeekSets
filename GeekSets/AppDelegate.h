//
//  AppDelegate.h
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 23/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@import GoogleMobileAds;

@import Firebase;

#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

