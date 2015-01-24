//
//  GetEventsCommentsModel.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 30/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"
@interface GetEventsCommentsModel : NSObject<ConnectionDelegate>
{
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    NSMutableArray              *mArrayEventsComments;
}
@property (nonatomic, retain) NSMutableArray *arrayEventsComments;



+ (GetEventsCommentsModel *)getEventsCommentsModel;
- (BOOL)callGetEventsCommentsWebserviceWithEventId:(int)lEventId;
@end
