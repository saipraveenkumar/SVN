//
//  MyApp.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 16/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"
@interface ListAlarmsModel : NSObject<ConnectionDelegate>{
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    NSMutableArray              *mArrayAlarms;
}
@property (nonatomic, retain) NSMutableArray *arrayAlarms;
+ (ListAlarmsModel *)getListAlarmModel;
- (BOOL)callGetListAlarmWebserviceWithMobileNo:(NSString*)mobileNumber;
@end
