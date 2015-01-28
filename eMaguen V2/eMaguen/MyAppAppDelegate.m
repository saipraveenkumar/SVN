//
//  MyAppAppDelegate.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "MyAppAppDelegate.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "PasswordRecoverViewController.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "ContactViewController.h"
#import "NotificationsViewController.h"
#import "EventsViewController.h"
#import "AddEventViewController.h"
#import "ShareEventViewController.h"
#import "NotificationDetailViewController.h"
#import "CommentsViewController.h"
#import "AddCommentViewController.h"
#import "MyProfileViewController.h"
#import "AddEventDetailsViewController.h"
#import "ShowEventDetailsViewController.h"
#import "ShowEventCommentsViewController.h"
#import "ShowEventAddCommentViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DDMenuController.h"
#import "LeftController.h"
#import "AddAlarmViewController.h"
#import "ChooseAlarmViewController.h"
#import "AddAlarmLocationViewController.h"
#import "AddPeopleToAlarmViewController.h"
#import "ConfigureAlarmViewController.h"
#import "SendReqViewController.h"
#import "PeopleViewController.h"
#import "EditAlarmViewController.h"
#import "EditAlarmMapViewController.h"
#import "PeopleOnMapViewController.h"
#import "PeopleGroupViewController.h"
#import "AddGroupViewController.h"
#import "PendingInvitViewController.h"
#import "PeopleAcceptInvitationViewController.h"
#import "GroupMapViewController.h"
#import "MobileNumberViewController.h"
#import "SendLoc.h"
#import "StringID.h"
#import "RootViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioSession.h>

#define CONFIG_ALARM_URL @"{\"AlarmPhoneNumber\":\"%@\"}"

BOOL iPad;
BOOL iPhone;
BOOL iPhone5;
BOOL locationDetermined;
NSDictionary *payload;
NSArray *lUniqueTag;

@implementation MyAppAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self addNotificationHandlers];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    iPad = NO;
    iPhone = NO;
    iPhone5 = NO;
    locationDetermined = NO;
    
    iPhone      = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone  && [UIScreen mainScreen].bounds.size.height == 480.0;
    iPad        = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    iPhone5     = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setLoginVCAsWindowRootVC];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) addNotificationHandlers{
    [self removeNotificationHandlers];
}

- (void) removeNotificationHandlers{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 NSLog(@"%@",user);
                 int countFlag = 0;
                 for(NSString *str in [user allKeys]){
                     if([str isEqualToString:@"email"]){
                         ++countFlag;
                     }
                     else if ([str isEqualToString:@"name"]){
                         ++countFlag;
                     }
                     if(countFlag == 2){
                         break;
                     }
                 }
                 if(countFlag == 2){
                     NSString *name, *email;
                     if([[user objectForKey:@"name"] length]>50){
                         name = [[user objectForKey:@"name"] substringWithRange:NSMakeRange(0, 49)];//sending only 49 characters of name
                     }
                     else{
                         name = [user objectForKey:@"name"];
                     }
                     email = [user objectForKey:@"email"];
                     [[[LoginViewController alloc]init] loginFacebookConnection:[NSArray arrayWithObjects:[user objectForKey:@"email"], name, [user objectForKey:@"id"], @"2", nil]];
                 }
                 else{
                     [[NSNotificationCenter defaultCenter]
                      postNotificationName:@"TestNotification"
                      object:self];
                     [[[LoginViewController alloc]init] showErrorAlert];
                 }
             }
         }];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        NSLog(@"Session closed");
    }
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
            } else {
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TestNotification"
         object:self];
    }
}

- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"Aceptar!"
                      otherButtonTitles:nil] show];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillResignActive:(UIApplication *)application{
    NSLog(@"to background");
}

- (void)applicationWillTerminate:(UIApplication *)application{
    //Clearing facebook session values
    [FBSession.activeSession closeAndClearTokenInformation];
}

- (void)registerForPushWithTag:(NSArray *)uniqueTag{
    lUniqueTag = uniqueTag;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIRemoteNotificationTypeNewsstandContentAvailability) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:
(NSData *)deviceToken {
    MSClient *client = [MSClient clientWithApplicationURLString:@"https://newemaguen.azure-mobile.net/" applicationKey:@"XpbfYxFvdZSCnvQVstAWAsGIVGhfWi21"];
    NSLog(@"Unique Tags:%@",lUniqueTag);
    [client.push registerNativeWithDeviceToken:deviceToken tags:lUniqueTag completion:^(NSError *error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
        else{
            NSLog(@"Registered for push notification");
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:
(NSError *)error {
    NSLog(@"Failed to register for remote notifications: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:
(NSDictionary *)userInfo {
    
    NSUserDefaults *lUserData = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@", userInfo);
    payload = [userInfo objectForKey:@"aps"];
    NSLog(@"PayLoad: %@",payload);
    
    if([[lUserData objectForKey:@"kPrefKeyForUserLogin"] intValue] == 1){
        NSLog(@"User Login");
        AudioServicesPlaySystemSound(1002);
        if([[payload objectForKey:@"type"] intValue] == 5){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:[payload objectForKey:@"alert"] delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:[payload objectForKey:@"alert"] delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Aceptar", nil];
            [alert show];
        }
    }
    else{
        if([[payload objectForKey:@"type"] intValue] == 2){
            [self setPeopleAcceptInvitationVCWithDetails:payload];
        }
        else{
            [self setLoginVCAsWindowRootVC];
        }
    }
}

- (int)alertSharingLocation{
    int value = 0;
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForLocationService"] intValue] != 1){
        value =1;
    }
    else if (![CLLocationManager locationServicesEnabled]){
        value = 2;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        value = 3;
    }
    return value;
//    if(i == 1){
//        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"Attention" message:alertMessage delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:alertOkButton , nil];
//        alertBox.tag = 101;
//        [alertBox show];
//    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 101){
        if(buttonIndex == 1){
            if([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)){
                NSUserDefaults *lSetCellIndex = [NSUserDefaults standardUserDefaults];
                [lSetCellIndex setObject:@"3" forKey:@"kPrefKeyForCellIndex"];
                [self setProfileVCAsWindowRootVC];
            }
            else{
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                    [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
                }
                else{
                    [[[UIAlertView alloc]initWithTitle:@"Attention" message:@"Turn on Location Services to perform any action.\nSettings -> Privacy -> Location Services (ON)" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil] show];
                }
            }
        }
    }
    else{
        if(buttonIndex == 1){
            if ([[payload objectForKey:@"type"] intValue] == 1){
                [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"kPrefKeyForCellIndex"];
                [self setNotificationDetailVCAsWindowRootVCWithEventId:[[payload objectForKey:@"NotificationID"] intValue]];
            }
            else if([[payload objectForKey:@"type"] intValue] == 2){
                [[NSUserDefaults standardUserDefaults] setObject:@"6" forKey:@"kPrefKeyForCellIndex"];
                [self setPeopleAcceptInvitationVCWithDetails:payload];
            }
            else if ([[payload objectForKey:@"type"] intValue] == 3){
                [[NSUserDefaults standardUserDefaults] setObject:@"6" forKey:@"kPrefKeyForCellIndex"];
                [self setGroupsListVCAsWindowRootVC];
            }
            else if ([[payload objectForKey:@"type"] intValue] == 4){//
                [[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"kPrefKeyForCellIndex"];
                if(!viewFroPush)
                    viewFroPush = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
                viewFroPush.alpha = 0.5;
                viewFroPush.backgroundColor = [UIColor blackColor];
                [self.window.rootViewController.view addSubview:viewFroPush];
                NSString* lBGIndicator = [[NSBundle mainBundle] pathForResource:@"bg_loading.png" ofType:nil inDirectory:@""];
                if(!imageView)
                    imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:lBGIndicator]];
                imageView.center = self.window.rootViewController.view.center;
                [self.window.rootViewController.view addSubview:imageView];
                if(!activityView)
                    activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                activityView.center = self.window.rootViewController.view.center;
                activityView.transform = CGAffineTransformMakeScale(1.50, 1.50);
                [activityView startAnimating];
                [self.window.rootViewController.view addSubview:activityView];
                [self performSelectorInBackground:@selector(callEditAlarmWebService) withObject:nil];
            }
        }
    }
}

- (void)callEditAlarmWebService{
    NSString *urlString = [NSString stringWithFormat:@"%@AlarmDetalhe",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:CONFIG_ALARM_URL,[payload objectForKey:@"alarmphonenumber"]];
    
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    NSData *myJSONData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [body appendData:[NSData dataWithData:myJSONData]];
    [request setHTTPBody:body];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    [activityView stopAnimating];
    [imageView removeFromSuperview];
    if(returnString.length > 0){
        NSLog(@"Output: %@",returnString);
        returnString = [returnString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        returnString = [returnString substringToIndex:[returnString length] - 1];
        returnString = [returnString substringFromIndex:1];
        NSData* data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSLog(@"Response: %@",dict);
        NSError *error;
        NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@",lJSONArray);
        [self setConfigureAlarmVCWithAlarmName:[NSArray arrayWithObjects:[lJSONArray objectForKey:@"AlarmName"], [lJSONArray objectForKey:@"AlarmPhoneNumber"], [lJSONArray objectForKey:@"Lat"], [lJSONArray objectForKey:@"Lang"], [lJSONArray objectForKey:@"Number1"], [lJSONArray objectForKey:@"Number2"], [lJSONArray objectForKey:@"Number3"], [lJSONArray objectForKey:@"Number4"], [lJSONArray objectForKey:@"Number5"], [lJSONArray objectForKey:@"UserName"], [lJSONArray objectForKey:@"UserNumber"], [lJSONArray objectForKey:@"OwnerNumber"], nil]];
    }
    else{
        NSLog(@"Fail in fetching the alarm details.");
    }
}

+(MyAppAppDelegate*) getAppDelegate
{
    static MyAppAppDelegate* sAppDelegate = nil;
    if(!sAppDelegate)
    {
        UIApplication *lApplication = [UIApplication sharedApplication];
        if([lApplication.delegate isKindOfClass: [MyAppAppDelegate class]])
        {
            sAppDelegate = (MyAppAppDelegate*)lApplication.delegate;
        }
    }
    return sAppDelegate;
}

- (void) clearXibResources{
    self.window.rootViewController.view = nil;
}

- (void)setMobileVCAsWindowRootVCWithFBUserDetails:(NSArray*)fbUserDetails{
    [self clearXibResources];
    MobileNumberViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[MobileNumberViewController alloc] initWithNibName:@"MobileNumberViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[MobileNumberViewController alloc] initWithNibName:@"MobileNumberViewController" bundle:nil];
    }
    [lHomeVC setFBUserData:fbUserDetails];
    self.window.rootViewController = lHomeVC;
}

- (void)setAddGroupVCAsWindowRootVC{
    [self clearXibResources];
    AddGroupViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[AddGroupViewController alloc] initWithNibName:@"AddGroupViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[AddGroupViewController alloc] initWithNibName:@"AddGroupViewController" bundle:nil];
    }
    self.window.rootViewController = lHomeVC;
}

- (void)setAddAlarmViewController{
    [self clearXibResources];
    AddAlarmViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[AddAlarmViewController alloc] initWithNibName:@"AddAlarmViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[AddAlarmViewController alloc] initWithNibName:@"AddAlarmViewController" bundle:nil];
    }
    self.window.rootViewController = lHomeVC;
}

- (void)setPeopleLocationVCWithMobileNumber:(NSArray*)personDetails{
    [self clearXibResources];
    PeopleOnMapViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[PeopleOnMapViewController alloc] initWithNibName:@"PeopleOnMapViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[PeopleOnMapViewController alloc] initWithNibName:@"PeopleOnMapViewController" bundle:nil];
    }
    [lHomeVC setPersonDetails:personDetails];
    self.window.rootViewController = lHomeVC;
}

- (void)setGroupMapVCWithGroupDetails:(NSArray *)groupDetails{
    [self clearXibResources];
    GroupMapViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[GroupMapViewController alloc] initWithNibName:@"GroupMapViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[GroupMapViewController alloc] initWithNibName:@"GroupMapViewController" bundle:nil];
    }
    [lHomeVC setGroupDetails:groupDetails];
    self.window.rootViewController = lHomeVC;
}

- (void)setPeopleAcceptInvitationVCWithDetails:(NSDictionary*)invitationDetails{
    [self clearXibResources];
    PeopleAcceptInvitationViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[PeopleAcceptInvitationViewController alloc] initWithNibName:@"PeopleAcceptInvitationViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[PeopleAcceptInvitationViewController alloc] initWithNibName:@"PeopleAcceptInvitationViewController" bundle:nil];
    }
    [lHomeVC setInvitaionDetails:invitationDetails];
    self.window.rootViewController = lHomeVC;
}

- (void)setGroupsListVCAsWindowRootVC{
    [self clearXibResources];
    PeopleGroupViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[PeopleGroupViewController alloc] initWithNibName:@"PeopleGroupViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[PeopleGroupViewController alloc] initWithNibName:@"PeopleGroupViewController" bundle:nil];
    }
    //    [lHomeVC setSelectionValue:selectionValue];
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
}

- (void)setPendingNotifiVCAsWindowRootVC:(NSArray*)pendingNotifications{
    [self clearXibResources];
    PendingInvitViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[PendingInvitViewController alloc] initWithNibName:@"PendingInvitViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[PendingInvitViewController alloc] initWithNibName:@"PendingInvitViewController" bundle:nil];
    }
    [lHomeVC setData:pendingNotifications];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
    //    self.window.rootViewController = lHomeVC;
}

- (void)setAddAlarmLocationVCWithAlarmDetails:(NSArray*)alarmDetails{
    [self clearXibResources];
    AddAlarmLocationViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[AddAlarmLocationViewController alloc] initWithNibName:@"AddAlarmLocationViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[AddAlarmLocationViewController alloc] initWithNibName:@"AddAlarmLocationViewController" bundle:nil];
    }
    [lHomeVC setDetails:alarmDetails];
    self.window.rootViewController = lHomeVC;
}

- (void)setEditAlarmVCWithAlarmNameNumber:(NSArray*)alarmDetails{
    [self clearXibResources];
    EditAlarmViewController* lHomeVC;
    //    if(!lHomeVC){
    if(iPhone5){
        lHomeVC= [[EditAlarmViewController alloc] initWithNibName:@"EditAlarmViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[EditAlarmViewController alloc] initWithNibName:@"EditAlarmViewController" bundle:nil];
    }
    //    }
    [lHomeVC setDetails:alarmDetails];
    self.window.rootViewController = lHomeVC;
}

- (void)setEditAlarmMapVCWithAlarmDetails:(NSArray *)alarmDetails{
    [self clearXibResources];
    
    EditAlarmMapViewController* lHomeVC;
    if(iPhone5){
        lHomeVC= [[EditAlarmMapViewController alloc] initWithNibName:@"EditAlarmMapViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[EditAlarmMapViewController alloc] initWithNibName:@"EditAlarmMapViewController" bundle:nil];
    }
    [lHomeVC setAlarmDetails:alarmDetails];
    @try {
        //        self.window.rootViewController = nil;
        self.window.rootViewController = lHomeVC;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    //    self.window.rootViewController = lHomeVC;
}

- (void)setSendRequestVCWithMobileNumbers:(NSArray*)alarmDetails{
    [self clearXibResources];
    SendReqViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[SendReqViewController alloc] initWithNibName:@"SendReqViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[SendReqViewController alloc] initWithNibName:@"SendReqViewController" bundle:nil];
    }
    [lHomeVC setData:alarmDetails];
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
}

- (void)setPeopleViewController:(NSArray*)groupDetails{
    [self clearXibResources];
    PeopleViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[PeopleViewController alloc] initWithNibName:@"PeopleViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[PeopleViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil];
    }
    [lHomeVC setGroupDetails:groupDetails];
    self.window.rootViewController = lHomeVC;
}

- (void)setAddPeopleToAlarmViewController:(NSArray*)alarmDetails{
    [self clearXibResources];
    AddPeopleToAlarmViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[AddPeopleToAlarmViewController alloc] initWithNibName:@"AddPeopleToAlarmViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[AddPeopleToAlarmViewController alloc] initWithNibName:@"AddPeopleToAlarmViewController" bundle:nil];
    }
    [lHomeVC setData:alarmDetails];
    self.window.rootViewController = lHomeVC;
}


- (void)setLoginVCAsWindowRootVC{
    [self clearXibResources];
    LoginViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }
    self.window.rootViewController = lHomeVC;
}
- (void)setRegisterVCAsWindowRootVC:(NSArray*)userData{
    [self clearXibResources];
    RegisterViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[RegisterViewController alloc] initWithNibName:@"RegisterViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    }
    [lHomeVC setDetails:userData];
    self.window.rootViewController = lHomeVC;
    
}
- (void)setPasswordRecoveryVCAsWindowRootVC{
    [self clearXibResources];
    PasswordRecoverViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[PasswordRecoverViewController alloc] initWithNibName:@"PasswordRecoverViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[PasswordRecoverViewController alloc] initWithNibName:@"PasswordRecoverViewController" bundle:nil];
    }
    self.window.rootViewController = lHomeVC;
}

- (void)setConfigureAlarmVCWithAlarmName:(NSArray *)alarmDetails{
    [self clearXibResources];
    ConfigureAlarmViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[ConfigureAlarmViewController alloc] initWithNibName:@"ConfigureAlarmViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[ConfigureAlarmViewController alloc] initWithNibName:@"ConfigureAlarmViewController" bundle:nil];
    }
    [lHomeVC setData:alarmDetails];
    self.window.rootViewController = lHomeVC;
}

- (void)setChooseAlarmViewController{
    [self clearXibResources];
    ChooseAlarmViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[ChooseAlarmViewController alloc] initWithNibName:@"ChooseAlarmViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[ChooseAlarmViewController alloc] initWithNibName:@"ChooseAlarmViewController" bundle:nil];
    }
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    //    rootController.rightViewController = nil;
    [rootController setRightViewController:nil];
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
}

- (void)setHomeVCAsWindowRootVC{
    [self clearXibResources];
    HomeViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[HomeViewController alloc] initWithNibName:@"HomeViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    }
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    [UIView transitionWithView:self.window
                      duration:0.5
                       options: UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        self.window.rootViewController = rootController;
                    }
                    completion:nil];
//    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
    
}
- (void)setNotificationsVCAsWindowRootVC{
    [self clearXibResources];
    NotificationsViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
    }
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
    
}

- (void)setEventsVCAsWindowRootVC{
    [self clearXibResources];
    EventsViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[EventsViewController alloc] initWithNibName:@"EventsViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[EventsViewController alloc] initWithNibName:@"EventsViewController" bundle:nil];
    }
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
    
}

- (void)ShowEventDetailsVCAsWindowRootVC:(NSString*)eventId{
    [self clearXibResources];
    ShowEventDetailsViewController* lHomeVC;
    if(iPhone5){
        lHomeVC= [[ShowEventDetailsViewController alloc] initWithNibName:@"ShowEventDetailsViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[ShowEventDetailsViewController alloc] initWithNibName:@"ShowEventDetailsViewController" bundle:nil];
    }
    [lHomeVC setDetails:eventId];
    
    self.window.rootViewController = lHomeVC;
    
}

- (void)setProfileVCAsWindowRootVC{
    [self clearXibResources];
    ProfileViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[ProfileViewController alloc] initWithNibName:@"ProfileViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    }
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
    
}
- (void)setMyProfileVCAsWindowRootVC{
    [self clearXibResources];
    MyProfileViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[MyProfileViewController alloc] initWithNibName:@"MyProfileViewController" bundle:nil];
    }
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
}

- (void)setContactVCAsWindowRootVC{
    [self clearXibResources];
    ContactViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[ContactViewController alloc] initWithNibName:@"ContactViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
    }
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
    
}

- (void)setAddEventVCAsWindowRootVC{
    [self clearXibResources];
    AddEventViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[AddEventViewController alloc] initWithNibName:@"AddEventViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[AddEventViewController alloc] initWithNibName:@"AddEventViewController" bundle:nil];
    }
    self.window.rootViewController = lHomeVC;
}

- (void)setAddEventDetailsVCAsWindowRootVC:(float)latt and:(float)longi{
    [self clearXibResources];
    AddEventDetailsViewController *lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[AddEventDetailsViewController alloc] initWithNibName:@"AddEventDetailsViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[AddEventDetailsViewController alloc] initWithNibName:@"AddEventDetailsViewController" bundle:nil];
    }
    [lHomeVC CoordDetails:latt and:longi];
    self.window.rootViewController = lHomeVC;
}

- (void)setShareEventVCAsWindowRootVC:(NSString *)category andDateTime:(NSString*)dateTime andDescription:(NSString*)description andImage:(NSString*)image andUrl:(NSString*)url{
    [self clearXibResources];
    ShareEventViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[ShareEventViewController alloc] initWithNibName:@"ShareEventViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[ShareEventViewController alloc] initWithNibName:@"ShareEventViewController" bundle:nil];
    }
    [lHomeVC DtlsToShare:category and:dateTime and:description and:image and:url];
    //    self.window.rootViewController = lHomeVC;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
    _menuController = rootController;
    LeftController *leftVC = [[LeftController alloc]init];
    rootController.leftViewController = leftVC;
    navController.navigationBarHidden= YES;
    self.window.rootViewController = rootController;
    navController = nil;
    rootController = nil;
    leftVC = nil;
    lHomeVC = nil;
    
}

- (void)setNotificationDetailVCAsWindowRootVCWithEventId:(int)lEventID{
    [self clearXibResources];
    NotificationDetailViewController* lHomeVC;
    
    if(iPhone5){
        lHomeVC= [[NotificationDetailViewController alloc] initWithNibName:@"NotificationDetailViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[NotificationDetailViewController alloc] initWithNibName:@"NotificationDetailViewController" bundle:nil];
    }
    NSLog(@"The event id in root:%d",lEventID);
    [lHomeVC setEventID:lEventID];
    self.window.rootViewController = lHomeVC;
    
}
- (void)setCommentsVCAsWindowRootVCWithEventId:(int)lEventID andNotificationTitle:(NSString*)notifiTitle{
    [self clearXibResources];
    CommentsViewController* lHomeVC;
    if(iPhone5){
        lHomeVC= [[CommentsViewController alloc] initWithNibName:@"CommentsViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[CommentsViewController alloc] initWithNibName:@"CommentsViewController" bundle:nil];
    }
    [lHomeVC setEventID:lEventID andNotificationTitle:notifiTitle];
    self.window.rootViewController = lHomeVC;
    
}

-(void)ShowEventCommentsViewController:(int)lEventID{
    [self clearXibResources];
    ShowEventCommentsViewController* lHomeVC;
    if(iPhone5){
        lHomeVC= [[ShowEventCommentsViewController alloc] initWithNibName:@"ShowEventCommentsViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[ShowEventCommentsViewController alloc] initWithNibName:@"ShowEventCommentsViewController" bundle:nil];
    }
    [lHomeVC setEventID:lEventID];
    self.window.rootViewController = lHomeVC;
}

-(void)setShowEventAddCommentViewController:(int)lEventId{
    [self clearXibResources];
    ShowEventAddCommentViewController* lHomeVC;
    if(iPhone5){
        lHomeVC= [[ShowEventAddCommentViewController alloc] initWithNibName:@"ShowEventAddCommentViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[ShowEventAddCommentViewController alloc] initWithNibName:@"ShowEventAddCommentViewController" bundle:nil];
    }
    [lHomeVC setEventID:lEventId];
    self.window.rootViewController = lHomeVC;
}

- (void)setAddCommentsVCAsWindowRootVCWithEventId:(int)lEventID{
    [self clearXibResources];
    AddCommentViewController* lHomeVC;
    if(iPhone5){
        lHomeVC= [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController_iPhone5" bundle:nil];
    } else if (iPhone) {
        lHomeVC= [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:nil];
    }
    [lHomeVC setEventID:lEventID];
    self.window.rootViewController = lHomeVC;
    
}

//- (void)setAddCommentsVCAsWindowRootVCWithEventId:(int)lEventID{
//    [self clearXibResources];
//    AddCommentViewController* lHomeVC;
//    if(iPhone5){
//        lHomeVC= [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController_iPhone5" bundle:nil];
//    } else if (iPhone) {
//        lHomeVC= [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:nil];
//    }
//    [lHomeVC setEventID:lEventID];
//    self.window.rootViewController = lHomeVC;
//    
//}

@end



//- (void)setHomeVCAsWindowRootVCWithFlipAnimation{
//    [self clearXibResources];
//    HomeViewController* lHomeVC;
//
//    if(iPhone5){
//        lHomeVC= [[HomeViewController alloc] initWithNibName:@"HomeViewController_iPhone5" bundle:nil];
//    } else if (iPhone) {
//        lHomeVC= [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
//    }
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:lHomeVC];
//    DDMenuController *rootController = [[DDMenuController alloc] initWithRootViewController:navController];
//    _menuController = rootController;
//    LeftController *leftVC = [[LeftController alloc]init];
//    rootController.leftViewController = leftVC;
//
//    self.window.rootViewController = rootController;
//    navController = nil;
//    rootController = nil;
//    leftVC = nil;
//    lHomeVC = nil;
//    [UIView transitionWithView:self.window
//                      duration:0.5
//                       options: UIViewAnimationOptionTransitionFlipFromRight
//                    animations:^{
//                        self.window.rootViewController = lHomeVC;
//                    }
//                    completion:nil];
//}
