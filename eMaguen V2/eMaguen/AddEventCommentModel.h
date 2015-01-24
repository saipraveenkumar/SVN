//
//  AddEventCommentModel.h
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 30/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"
@class AddEventCommentParam;

@interface AddEventCommentModel : NSObject<ConnectionDelegate>
{
    Connection                  *mRecoveryConnection;
    NetworkStatus               mNetworkStatus;
}
+ (AddEventCommentModel *)getAddEventCommentModel;
- (BOOL)callAddEventCommentWebservice:(AddEventCommentParam *)param;


@end


@interface AddEventCommentParam : NSObject
{
    NSString            *mUserPassword;
    NSString            *mUserName;
    NSString            *mUserComments;
    NSString            *mBlogId;
    NSString            *mCoPropId;
    
    
}

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userPassword;
@property (nonatomic, copy) NSString *userComments;
@property (nonatomic, copy) NSString *blogId;
@property (nonatomic, copy) NSString *coPropId;
@end
