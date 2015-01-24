//
//  MyAppAppDelegate.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"

@class DDMenuController;

@interface MyAppAppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>{
    UIActivityIndicatorView *activityView;
    UIImageView *imageView;
    UIView *viewFroPush;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DDMenuController *menuController;
@property (nonatomic, readwrite) BOOL userLocSharing;

+(MyAppAppDelegate*) getAppDelegate;

- (int)alertSharingLocation;
- (void)setLoginVCAsWindowRootVC;
- (void)setMobileVCAsWindowRootVCWithFBUserDetails:(NSArray*)fbUserDetails;
- (void)setRegisterVCAsWindowRootVC:(NSArray *)userData;
- (void)setPasswordRecoveryVCAsWindowRootVC;
- (void)setHomeVCAsWindowRootVC;
- (void)setProfileVCAsWindowRootVC;
- (void)setMyProfileVCAsWindowRootVC;
- (void)setContactVCAsWindowRootVC;
- (void)setNotificationsVCAsWindowRootVC;
- (void)setEventsVCAsWindowRootVC;
- (void)setAddEventVCAsWindowRootVC;
- (void)setAddEventDetailsVCAsWindowRootVC:(float)latt and:(float)longi;
- (void)setShareEventVCAsWindowRootVC:(NSString *)category andDateTime:(NSString*)dateTime andDescription:(NSString*)description andImage:(NSString*)image andUrl:(NSString*)url;
- (void)setNotificationDetailVCAsWindowRootVCWithEventId:(int)lEventID;
- (void)setCommentsVCAsWindowRootVCWithEventId:(int)lEventID andNotificationTitle:(NSString*)notifiTitle;
- (void)setAddCommentsVCAsWindowRootVCWithEventId:(int)lEventID;
- (void)ShowEventDetailsVCAsWindowRootVC:(NSString*)eventId;
- (void)ShowEventCommentsViewController:(int)lEventID;
- (void)setShowEventAddCommentViewController:(int)lEventId;
- (void)setAddAlarmViewController;
- (void)setAddAlarmLocationVCWithAlarmDetails:(NSArray*)alarmDetails;
- (void)setChooseAlarmViewController;
- (void)setAddPeopleToAlarmViewController:(NSArray*)alarmDetails;
- (void)setConfigureAlarmVCWithAlarmName:(NSArray *)alarmDetails;
- (void)setSendRequestVCWithMobileNumbers:(NSArray*)alarmDetails;
- (void)setPeopleViewController:(NSArray*)groupDetails;
- (void)setEditAlarmVCWithAlarmNameNumber:(NSArray*)alarmDetails;
- (void)setEditAlarmMapVCWithAlarmDetails:(NSArray*)alarmDetails;
- (void)setPeopleLocationVCWithMobileNumber:(NSArray*)personDetails;
- (void)setGroupsListVCAsWindowRootVC;
- (void)setAddGroupVCAsWindowRootVC;
- (void)setPendingNotifiVCAsWindowRootVC:(NSArray*)pendingNotifications;
- (void)setPeopleAcceptInvitationVCWithDetails:(NSDictionary*)invitationDetails;
- (void)registerForPushWithTag:(NSArray *)uniqueTag;
- (void)setGroupMapVCWithGroupDetails:(NSArray *)groupDetails;
//-(void)setHomeVCAsWindowRootVCWithFlipAnimation;


- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end
