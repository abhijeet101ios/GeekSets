//
//  Utility.m
//  GeekSets
//
//  Created by Abhijeet Mishra on 20/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "Utility.h"
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@import Firebase;

@interface Utility ()

@property (nonatomic) FIRDatabaseReference* userDatabaseRef;

@end

@implementation Utility

static Utility* sharedInstance;

+ (Utility*) sharedInsance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Utility alloc] init];
    });
    return sharedInstance;
}

- (NSString*) ab_getUserID {
    if ([FIRAuth auth].currentUser) {
        //logged in user
        return [[[FIRAuth auth].currentUser.email componentsSeparatedByString:@"."] firstObject];
    }
    else {
        //guest user
        if (![self ab_getGuestUserID]) {
            [self ab_setGuestUserID];
        }
      return [self ab_getGuestUserID];
    }
    return nil;
}

- (void) ab_setGuestUserID {
    NSString* uniqueID = [self randomStringWithLength:10];
    [[NSUserDefaults standardUserDefaults] setValue:uniqueID forKey:UNIQUE_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) ab_getGuestUserID {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UNIQUE_ID];
}

- (void) ab_migrateDB {
    [self.userDatabaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        id data = snapshot.value;
        
        NSString* uniqueID =  [self ab_getUserID];
        
        NSString* userKey = @"users";
        
        //fetch list data
        NSDictionary* userDataDictionary = data[userKey][uniqueID];
       
        NSDictionary* migratedDataDictionary = @{[FIRAuth auth].currentUser.email:userDataDictionary};
        
        [[self.userDatabaseRef child:userKey] updateChildValues:migratedDataDictionary];
        
    }];
}

- (NSString *) randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((u_int32_t)[letters length])]];
    }
    return randomString;
}

#pragma mark - Ad related info storage

- (NSString*) getKeyForAdType:(adType) adType {
    NSString* adKeyString;
    
    switch (adType) {
        case interstitialAd:
            adKeyString = KEY_IS_INTERSTITIAL_AD_DISABLED;
            break;
            
        case bannerAdTopicList:
            adKeyString = KEY_IS_TOPIC_LIST_BANNER_AD_DISABLED;
            break;
            
        case bannerAdSetList:
            adKeyString = KEY_IS_SET_LIST_BANNER_AD_DISABLED;
            break;
            
        case bannerAdWebView:
            adKeyString = KEY_IS_WEB_VIEW_BANNER_AD_DISABLED;
            break;
        default:
            return nil;
    }
    return adKeyString;
}

- (BOOL) getIsAdDisabled:(adType) adType {
    NSString* adKeyString = [self getKeyForAdType:adType];
    if (!adKeyString) {
        return YES;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:adKeyString];
}

- (void) setIsAdDisabled:(BOOL) isDisabled forAdType:(adType) adType {
    
    NSString* adKeyString = [self getKeyForAdType:adType];
    
    if (!adKeyString) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:isDisabled forKey:adKeyString];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Notification methods

#pragma mark Push Notification

- (void) registerForPushNotifications {
    [self ab_registerForPushNotificationsForApplication:[UIApplication sharedApplication]];
}

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
        [[UNUserNotificationCenter currentNotificationCenter] setDelegate:(AppDelegate*)[UIApplication sharedApplication].delegate];
        // For iOS 10 data message (sent via FCM)
        [[FIRMessaging messaging] setRemoteMessageDelegate:(AppDelegate*)[UIApplication sharedApplication].delegate];
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

#pragma mark - Topic List First Invocation 


- (BOOL) isTopicListSubsequentInvocation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_TOPIC_LIST_SUBSEQUENT_INVOCATION];
}
- (void) setTopicListSubsequentInvocation {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_TOPIC_LIST_SUBSEQUENT_INVOCATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
