//
//  GetEventsModel.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 13/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"


@interface GetEventsModel : NSObject<ConnectionDelegate>{
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    NSMutableArray              *mArrayEvents;
    
    
}


@property (nonatomic, retain) NSMutableArray *arrayEvents;



+ (GetEventsModel *)getGetEventsModel;
- (BOOL)callGetEventsWebservice;

@end
