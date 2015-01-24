//
//  AddEventModel.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 11/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "Reachability.h"

@class EventAddParam;
@interface AddEventModel : NSObject<ConnectionDelegate> {
    Connection                  *mLoginConnection;
    NetworkStatus               mNetworkStatus;
    
}
+ (AddEventModel *)getAddEventModel;
- (BOOL)callAddEventWebservice:(EventAddParam *)param;
@end

@interface EventAddParam : NSObject
{
    int                         mCategoryId;
    int                         mBarrioId;
    NSString                    *mUserName;
    NSString                    *mUserPassword;
    NSString                    *mName;
    NSString                    *mLocation;
    NSString                    *mDateTime;
    NSString                    *mDescription;
    NSString                    *mLatitutde;
    NSString                    *mLongitude;
    NSString                    *mImage;
//    NSData                    *mImage;
    
}

@property (nonatomic) int categoryID;
@property (nonatomic) int barrioID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userPassword;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *dateTime;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *image;
//@property (nonatomic, copy) NSData *image;



@end


