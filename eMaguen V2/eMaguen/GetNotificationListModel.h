//
//  GetNotificationListModel.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 11/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"


@interface GetNotificationListModel : NSObject<ConnectionDelegate> {

    Connection                  *mLoginConnection;
    Connection                  *mNotificationDetailConnection;
    NetworkStatus               mNetworkStatus;
    NSMutableArray              *mArrayNotifcations;
    NSDictionary                *mNotificationData;
}

@property (nonatomic, retain) NSMutableArray *arrayNotifications;
@property (nonatomic, retain) NSDictionary *notificationData;
    
    
+ (GetNotificationListModel *)getGetNotificationListModel;
- (BOOL)callGetNotificationsWebservice;
- (BOOL)callGetNotificationDetailWebservice:(NSString *)notificationId;


@end
