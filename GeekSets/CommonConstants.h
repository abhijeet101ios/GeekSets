//
//  CommonConstants.h
//  AmozonPracticeApp
//
//  Created by Abhijeet Mishra on 03/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#ifndef CommonConstants_h
#define CommonConstants_h


#endif /* CommonConstants_h */

typedef enum {
    interstitialAd,
    bannerAdTopicList,
    bannerAdSetList,
    bannerAdWebView    
} adType;

//device type macros
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4_OR_LESS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)

//general constants
#define APP_COLOR [UIColor colorWithRed:0 green:194.0/255.0 blue:109.0/255.0 alpha:0.8]
#define UNIQUE_ID @"unique_id"
#define DIVIDER_KEY @"divider101"
#define KEY_SETS @"sets"
#define KEY_NAME @"name"
#define KEY_URL @"url"
#define KEY_COMPLETED @"completed"
#define KEY_OPENED @"opened"
#define KEY_SET_ORDER @"setOrder"
#define KEY_IS_LOGIN_SCREEN_SEEN @"isLoginScreenShown"
#define KEY_IS_WALKTHROUGH_SEEN @"isWalkthroughSeen"
#define KEY_IS_TOPIC_LIST_COACH_MARK_SEEN @"isTopicListCoachMarkSeen"
#define KEY_IS_TOPIC_LIST_REORDER_COACH_MARK_SEEN @"isTopicListReorderCoachMarkSeen"
#define KEY_IS_SET_LIST_COACH_MARK_SEEN @"isSetListCoachMarkSeen"
#define KEY_IS_TICK_LIST_COACH_MARK_SEEN @"isTickListCoachMarkSeen"
#define KEY_IS_TOPIC_LIST_SUBSEQUENT_INVOCATION @"isTopicListSubsequentInvocation"

//ad related values
#define KEY_IS_INTERSTITIAL_AD_DISABLED @"isInterstitialAdDisabled"
#define KEY_IS_TOPIC_LIST_BANNER_AD_DISABLED @"isTopicListBannerAdDisabled"
#define KEY_IS_SET_LIST_BANNER_AD_DISABLED @"isSetListBannerAdDisabled"
#define KEY_IS_WEB_VIEW_BANNER_AD_DISABLED @"isWebViewBannerAdDisabled"
