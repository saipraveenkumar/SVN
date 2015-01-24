//
//  GetEventsCommentsCountModel.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 31/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"
@interface GetEventsCommentsCountModel : NSObject<ConnectionDelegate>
{
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    NSMutableDictionary              *mArrayEventsCommentsCount;
}

@property (nonatomic, retain) NSMutableDictionary *arrayEventsCommentsCount;

+ (GetEventsCommentsCountModel *)getEventsCommentsCountModel;
- (BOOL)callGetEventsCommentsCountWebserviceWithEventId:(NSString*)lEventId;
@end
