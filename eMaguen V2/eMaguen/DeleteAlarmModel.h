//
//  DeleteAlarmModel.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 21/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"

@interface DeleteAlarmModel : NSObject<ConnectionDelegate>{
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    NSString                    *mAlarmDelete;
}
@property (nonatomic, retain) NSString *alarmDelete;
+ (DeleteAlarmModel *)getDeleteAlarmModel;
- (BOOL)callGetAddAlarmWebservice:(NSArray*)alarmDeleteDetails;

@end
