//
//  AlarmNumber1Model.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 16/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"
@interface CountryNumberModel : NSObject<ConnectionDelegate>{
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    NSDictionary                *mCountryNumber;
    NSArray                     *mAlarmData;
}
@property (nonatomic, retain) NSDictionary *countryNumber;
+ (CountryNumberModel *)getCountryNumberModel;
- (BOOL)callGetCountryNumberWebserviceWithMobileNo:(NSArray*)mobileNumber;
@end
