//
//  AppDelegate.m
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 23/09/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "AppDelegate.h"
#import "CommonConstants.h"
#import "Utility.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <UserNotifications/UserNotifications.h>

@import Firebase;

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
    // Override point for customization after application launch.
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-3743202420941577/2951813244"];
    // Use Firebase library to configure APIs
    [FIRApp configure];
    
    [GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate = self;
    
    [[Utility sharedInsance] ab_getUserID];
    
    if( [UIDevice currentDevice].systemVersion.floatValue >= 9.0 )
    {
        //set cursor color for the search bar text field
        //not supported below iOS 9.0
        [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor darkTextColor]];
    }
    
    [self ab_registerForPushNotificationsForApplication:[UIApplication sharedApplication]];
    [Fabric with:@[[Crashlytics class]]];
 //   [[Fabric sharedSDK] setDebug: YES];
    return YES;
}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                      annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential =
        [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
                                         accessToken:authentication.accessToken];
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      // ...
                                  }];
        // ...
    } else {
        
    }
        // ...
        }
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   // [[FIRMessaging messaging] disconnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self connectToFcm];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#pragma mark - Notification methods

#pragma mark Push Notification

- (void)ab_registerForPushNotificationsForApplication:(UIApplication *)inApplication
{
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
         }
         ];
        
        // For iOS 10 display notification (sent via APNS)
        [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
        // For iOS 10 data message (sent via FCM)
        [[FIRMessaging messaging] setRemoteMessageDelegate:self];
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"APNS token :: %@",token);
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken
type:FIRInstanceIDAPNSTokenTypeSandbox];

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    ;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if ((application.applicationState == UIApplicationStateBackground)) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
        if ([userInfo isKindOfClass: [NSDictionary class]]) {
            NSDictionary *messageInfo = userInfo[@"aps"];
            
            if ([messageInfo isKindOfClass: [NSDictionary class]]) {
               // [self wp_showNotificationAlertWithMessage: messageInfo[@"alert"]];
            }
        }
    
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - iOS 10 methods

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSLog( @"Handle push from foreground" );
    // custom code to handle push while app is in the foreground
    NSLog(@"%@", notification.request.content.userInfo);
    
    NSDictionary* userInfo = notification.request.content.userInfo;
    
    UIApplication* application = [UIApplication sharedApplication];
    
    if ((application.applicationState == UIApplicationStateBackground)) {
        return;
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
        if ([userInfo isKindOfClass: [NSDictionary class]]) {
            NSDictionary *messageInfo = userInfo[@"aps"];
            
            if ([messageInfo isKindOfClass: [NSDictionary class]]) {
             //   [self wp_showNotificationAlertWithMessage: messageInfo[@"alert"]];
            }
        }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler
{
    NSLog( @"Handle push from background or closed" );
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
    NSLog(@"%@", response.notification.request.content.userInfo);
    
    NSDictionary* userInfo = response.notification.request.content.userInfo;
    
    UIApplication* application = [UIApplication sharedApplication];
    
    if ((application.applicationState == UIApplicationStateBackground)) {
        completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
        if ([userInfo isKindOfClass: [NSDictionary class]]) {
            NSDictionary *messageInfo = userInfo[@"aps"];
            
            if ([messageInfo isKindOfClass: [NSDictionary class]]) {
               // [self wp_showNotificationAlertWithMessage: messageInfo[@"alert"]];
            }
        }
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - FCM methods

- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}


#pragma mark - Random String Generator

- (NSString *) randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}

@end
