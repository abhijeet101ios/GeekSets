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
#define KEY_NO_OF_SETS_OPENED @"noOfSetsOpened"

//ad related values
#define KEY_IS_INTERSTITIAL_AD_DISABLED @"isInterstitialAdDisabled"
#define KEY_IS_TOPIC_LIST_BANNER_AD_DISABLED @"isTopicListBannerAdDisabled"
#define KEY_IS_SET_LIST_BANNER_AD_DISABLED @"isSetListBannerAdDisabled"
#define KEY_IS_WEB_VIEW_BANNER_AD_DISABLED @"isWebViewBannerAdDisabled"

//analytics events
#define EVENT_ANALYTICS_LOGIN_PRESSED @"login_pressed"
#define EVENT_ANALYTICS_NOT_NOW_PRESSED @"not_now_pressed"
#define EVENT_ANALYTICS_LOGOUT_PRESSED @"logout_pressed"
#define EVENT_ANALYTICS_COMPANY_SEARCH_PRESSED @"company_search_pressed"
#define EVENT_ANALYTICS_COMPANY_LIST_REORDERED @"company_list_reordered"
#define EVENT_ANALYTICS_COMPANY_SELECTED @"company_selected"
#define EVENT_ANALYTICS_COMPANY_BACK_PRESSED @"company_back_pressed"
#define EVENT_ANALYTICS_SET_BACK_PRESSED @"set_back_pressed"
#define EVENT_ANALYTICS_LOGIN_SUCCESS @"login_success"
#define EVENT_ANALYTICS_LOGIN_FAILURE @"login_failure"


//analytics keys
#define KEY_ANALYTICS_TIMESTAMP @"timestamp"
#define KEY_ANALYTICS_USERID @"userID"
#define KEY_ANALYTICS_COMPANY_NAME @"company_name"
#define KEY_ANALYTICS_FIRST_COMPANY @"first_company"
#define KEY_ANALYTICS_SECOND_COMPANY @"second_company"
#define KEY_ANALYTICS_THIRD_COMPANY @"third_company"
#define KEY_ANALYTICS_TIME_SPENT @"time_spent"
#define KEY_ANALYTICS_NO_OF_SETS_OPENED @"no_of_sets_opened"
#define KEY_ANALYTICS_SET_NAME @"set_name"







