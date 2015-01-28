//
//  AddAlarmModel.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 16/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"

@class AlarmParam;

@interface AddAlarmModel : NSObject<ConnectionDelegate>{
    Connection                  *mLoginConnection;
    Connection                  *mUpdateConnection;
    NetworkStatus               mNetworkStatus;
    NSString                    *mAlarmAdd;
    NSString                    *mAlarmZoneId;
    NSString                    *mAlarmNumber;
    NSDictionary                *mAlarmSettings;
    NSArray                     *mSaveAlarmSettings;
}
@property (nonatomic, retain) NSString *alarmAdd;
@property (nonatomic, retain) NSDictionary *alarmSettings;
@property (nonatomic, copy) NSString *alarmZoneId;
+ (AddAlarmModel *)getAddAlarmModel;
- (BOOL)callGetAddAlarmWebservice:(AlarmParam *)param;
- (BOOL)callGetUpdateAlarmWebservice:(AlarmParam *)param;
@end

@interface AlarmParam : NSObject
{
    NSString            *mAlarmNumber;
    NSString            *mAlarmName;
    NSString            *mNumber1;
    NSString            *mNumber2;
    NSString            *mNumber3;
    NSString            *mNumber4;
    NSString            *mLongitude;
    NSString            *mLattitude;
    NSString            *mUsername;
    NSString            *mUserNumber;
    NSString            *mOwnerNumber;
}

@property (nonatomic, copy) NSString *alarmNumber;
@property (nonatomic, copy) NSString *alarmName;
@property (nonatomic, copy) NSString *number1;
@property (nonatomic, copy) NSString *number2;
@property (nonatomic, copy) NSString *number3;
@property (nonatomic, copy) NSString *number4;
@property (nonatomic, copy) NSString *lattitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userNumber;
@property (nonatomic, copy) NSString *ownerNumber;
@end
