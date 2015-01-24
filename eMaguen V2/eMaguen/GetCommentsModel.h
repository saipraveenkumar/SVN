//
//  GetCommentsModel.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"


@interface GetCommentsModel : NSObject<ConnectionDelegate>{
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    NSMutableArray              *mArrayComments;
    
    
}


@property (nonatomic, retain) NSMutableArray *arrayComments;



+ (GetCommentsModel *)getCommentsModel;
- (BOOL)callGetCommentsWebserviceWithEventId:(int)lEventId;
@end
