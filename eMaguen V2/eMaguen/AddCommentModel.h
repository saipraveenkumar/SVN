//
//  AddCommentModel.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 16/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"
@class AddCommentParam;



@interface AddCommentModel : NSObject<ConnectionDelegate> {

    Connection                  *mRecoveryConnection;
    NetworkStatus               mNetworkStatus;
}
+ (AddCommentModel *)getAddCommentModel;
- (BOOL)callAddCommentWebservice:(AddCommentParam *)param;


@end


@interface AddCommentParam : NSObject
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

