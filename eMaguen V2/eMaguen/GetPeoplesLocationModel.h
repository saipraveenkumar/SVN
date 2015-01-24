//
//  GetPeoplesLocationModel.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 28/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"
@interface GetPeoplesLocationModel : NSObject<ConnectionDelegate>
{
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    NSArray                    *mPeopleLocation;
}
@property (nonatomic, retain) NSArray *peopleLocation;
+ (GetPeoplesLocationModel *)getGetPeoplesLocationModel;
- (BOOL)callGetPeoplesLocationModelWebserviceWithUserId:(NSString*)userId;
@end
