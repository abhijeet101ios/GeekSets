//
//  Utility.h
//  GeekSets
//
//  Created by Abhijeet Mishra on 20/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonConstants.h"

@interface Utility : NSObject

+ (Utility*) sharedInsance;
- (NSString*) ab_getUserID;
- (void) ab_migrateDB;

- (BOOL) getIsAdDisabled:(adType) adType;
- (void) setIsAdDisabled:(BOOL) isDisabled forAdType:(adType) adType;

@end
