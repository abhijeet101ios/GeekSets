//
//  GSAnalytics.m
//  GeekSets
//
//  Created by Abhijeet Mishra on 22/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "GSAnalytics.h"

@import Firebase;

@implementation GSAnalytics

static GSAnalytics* sharedInstance;

+ (GSAnalytics*) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GSAnalytics alloc] init];
    });
    return sharedInstance;
}

- (void) setEventName:(NSString*) eventName withKeys:(NSDictionary*) keys {
    [FIRAnalytics logEventWithName:eventName parameters:keys];
}


@end
