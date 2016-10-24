//
//  GSAnalytics.h
//  GeekSets
//
//  Created by Abhijeet Mishra on 22/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSAnalytics : NSObject

+ (GSAnalytics*) sharedInstance;

- (void) setEventName:(NSString*) eventName withKeys:(NSDictionary*) keys;

@end
