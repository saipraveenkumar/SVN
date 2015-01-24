//
//  UserDataModel.h
//  CERSAI14
//
//  Created by Rohit Yermalkar on 02/05/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

#import "Reachability.h"
@class UserLoginParam;
@class UserRegisterParam;


@interface UserDataModel : NSObject<ConnectionDelegate> {
    
    Connection                  *mLoginConnection;
    Connection                  *mRegisterConnection;
    Connection                  *mRecoveryConnection;
    Connection                  *mProfileConnection;
    Connection                  *mLoginFacebookConnection;
    NetworkStatus               mNetworkStatus;
    
    int                         mUserID;
    NSString                    *mUserName;
    NSString                    *mUserTelephone;
    NSString                    *mUserEmail;
    NSString                    *mUserAlias;
    NSString                    *mUserPassword;
    NSString                    *mUserActive;
    NSString                    *mUserMessage;
    NSString                    *mUserSOSEmail;
    BOOL                        mUserRegistered;
    NSString                    *mUserNotificationCount;
    
    
    int                         mFacebook;
    int                         mTwitter;
    int                         mWhatsapp;
    

}

@property (nonatomic) int facebook;
@property (nonatomic) int twitter;
@property (nonatomic) int whatsapp;

@property (nonatomic, readonly) int userID;
@property (nonatomic, readonly) BOOL userRegistered;
@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *userTelephone;
@property (nonatomic, retain) NSString *userEmail;
@property (nonatomic, readonly) NSString *userAlias;
@property (nonatomic, readonly) NSString *userPassword;
@property (nonatomic, readonly) NSString *userActive;
@property (nonatomic, readonly) NSString *userMessage;
@property (nonatomic, readonly) NSString *userSOSEmail;
@property (nonatomic, readonly) NSString *userNotificationCount;


- (BOOL)isUserloggedIn;
- (BOOL)isUserRegistered;
+ (UserDataModel *)getUserDataModel;
- (BOOL)callLoginWebservice:(UserLoginParam *)param;
- (BOOL)callRegisterWebservice:(UserRegisterParam *)param;
- (BOOL)callForgotPasswordWebservice:(UserRegisterParam *)param;
- (BOOL)callUpdateProfileWebservice:(NSString *)sosMail;
- (void) logoutUser;

@end


@interface UserLoginParam : NSObject
{
    NSString            *mUserPassword;
    NSString            *mUserName;
}

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userPassword;


@end


@interface UserRegisterParam : NSObject
{
    NSString            *mUserPassword;
    NSString            *mUserName;
    NSString            *mUserPhone;
    NSString            *mUserEmail;
    NSString            *mUserSOSEmail;
    
}

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userPassword;
@property (nonatomic, copy) NSString *userPhone;
@property (nonatomic, copy) NSString *userEmail;
@property (nonatomic, copy) NSString *userSOSEmail;


@end

