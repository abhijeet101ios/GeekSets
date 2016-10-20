//
//  Utility.m
//  GeekSets
//
//  Created by Abhijeet Mishra on 20/10/16.
//  Copyright © 2016 Abhijeet Mishra. All rights reserved.
//

#import "Utility.h"
#import "CommonConstants.h"

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
    if ( [FIRAuth auth].currentUser) {
        //logged in user
        return [FIRAuth auth].currentUser.email;
    }
    else {
        //guest user
        if (![self ab_getGuestUserID]) {
            [self ab_setGuestUserID];
        }
        [self ab_getGuestUserID];
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
       
        NSDictionary* migratedDataDictionary = @{};
        
        [[self.userDatabaseRef child:userKey] updateChildValues:emptyDict];
        
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


@end
