//
//  AppDelegate.h
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 23/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import <UIKit/UIKit.h>

@import GoogleMobileAds;

@import Firebase;

#import <GoogleSignIn/GoogleSignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

