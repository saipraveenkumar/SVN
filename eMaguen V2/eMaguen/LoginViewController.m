//
//  LoginViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "LoginViewController.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
//#import <FacebookSDK/FacebookSDK.h>
#import "MyAppAppDelegate.h"
#import "UserDataModel.h"
#import "StringID.h"
#import "SendLoc.h"

#define NAME_LENGTH 50
#define PASSWORD_MIN_LENGTH 6
#define PASSWORD_MAX_LENGTH 16

#define LOGIN_FACEBOOK_URL @"{\"Email\":\"%@\",\"Password\":\"%@\",\"LoginType\":\"%@\"}"

MyAppAppDelegate *mAppDelegate;

static NSString *kPrefKeyForUpdatedUsername             = @"kPrefKeyForUpdatedUsername";
static NSString *kPrefKeyForUpdatedPassword             = @"kPrefKeyForUpdatedPassword";
static NSString *kPrefKeyForUpdatedeMail             = @"kPrefKeyForUpdatedeMail";
static NSString *kPrefKeyForUpdatedFlag                 = @"kPrefKeyForUpdatedFlag";
static NSString *kPrefKeyForPhone                       = @"kPrefKeyForPhone";
//for choosing groups view or pending list view
static NSString *kPrefKeyForOptionSelection             = @"kPrefKeyForOptionSelection";
static NSString *kPrefKeyForUserLogin             = @"kPrefKeyForUserLogin";
static NSString *kPrefKeyForCoId             = @"kPrefKeyForCoId";
static NSString *kPrefKeyForNotificationCount             = @"kPrefKeyForNotificationCount";
static NSString *kPrefKeyForAlarmZoneIds             = @"kPrefKeyForAlarmZoneIds";

//NSString *mobileNo;


@interface LoginViewController ()
{
    int flag;
    NSString *lUsername;
    NSString *lPassword;
    UIColor *blueColor;
    UITapGestureRecognizer *tap;
    BOOL isUserLoggedInFacebook;
    NSArray *facebookUserRegDetails;
}

@end

@implementation LoginViewController
@synthesize lTxtFieldPassword,lTxtFieldUsername;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
    }
    return self;
}

- (void) addNotificationHandlers{
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: USER_LOGIN_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: USER_LOGIN_FAILED object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: USER_LOGIN_FACEBOOK_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: USER_LOGIN_FACEBOOK_FAILED object: nil];
}

- (void) removeNotificationHandlers{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)onLoginFinish:(NSNotification*) lNotification{
    [self hideProgressIndicator];
    UserDataModel *lUserData = [UserDataModel getUserDataModel];
    if(![lUserData isUserloggedIn])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:lUserData.userMessage delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
//        UserDataModel *lUserData = [UserDataModel getUserDataModel];
        NSLog(@"%@-%@",lUserData.userEmail,lUserData.userName);
        [lData setValue:lUserData.userName forKey: kPrefKeyForUpdatedUsername];
        
        NSUserDefaults *lUserDefaults = [NSUserDefaults standardUserDefaults];
        [lUserDefaults setValue:lUserData.userTelephone forKey: kPrefKeyForPhone];
        [lUserDefaults setValue:@"0" forKey: kPrefKeyForOptionSelection];
        [lUserDefaults setValue:lUserData.userNotificationCount forKey:kPrefKeyForNotificationCount];
        //user Login or not
        [lUserDefaults setValue:@"1" forKey:kPrefKeyForUserLogin];
        [lUserDefaults setValue:[NSString stringWithFormat:@"%d",lUserData.userID] forKey:kPrefKeyForCoId];
        NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[lUserDefaults objectForKey:kPrefKeyForAlarmZoneIds]];
        [arr addObject:[lUserDefaults objectForKey:kPrefKeyForCoId]];
        
        [[SendLoc getSendLoc] initializeAllValuesForSharingLocation];
        
        [mAppDelegate registerForPushWithTag:arr];
        
        [mAppDelegate setHomeVCAsWindowRootVC];
        arr = nil;
    }
}

- (void)onLoginFailed:(NSNotification*) lNotification{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    [self getUpdatedCredentials];
    
    mAppDelegate.userLocSharing = NO;
    
    if(flag == 0){
        lSwtRcrdUsrPwd.on = NO;
        lSwtRcrdUsrPwd.thumbTintColor = [UIColor whiteColor];
    }
    else{
        lSwtRcrdUsrPwd.on = YES;
        lSwtRcrdUsrPwd.onTintColor = [UIColor whiteColor];
        lSwtRcrdUsrPwd.thumbTintColor = [UIColor grayColor];
    }
    lSwtRcrdUsrPwd.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
    [lblLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    if(iPhone5)
        [lblLogin setBackgroundImage:[UIImage imageNamed:@"i5_button_off.png"] forState:UIControlStateHighlighted];
    else if(iPhone)
        [lblLogin setBackgroundImage:[UIImage imageNamed:@"i4_button_off.png"] forState:UIControlStateHighlighted];
    
    lTxtFieldPassword.delegate = self;
    lTxtFieldUsername.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"TestNotification"]){
        NSLog (@"Successfully received the test notification!");
        [self hideProgressIndicator];
    }
}

- (void)showErrorAlert{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error. Try again." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)BnLoginFacebookTapped:(id)sender{
    [self addProgressIndicator];
    [self showProgressIndicator];
    mLabelLoading.text = @"Autorizando...";
    //    // If the session state is any of the two "open" states when the button is clicked
    //    if (FBSession.activeSession.state == FBSessionStateOpen
    //        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
    //
    //        // Close the session and remove the access token from the cache
    //        // The session state handler (in the app delegate) will be called automatically
    [FBSession.activeSession closeAndClearTokenInformation];
    //
    //        // If the session state is not any of the two "open" states when the button is clicked
    //    } else {
    //        // Open a session showing the user the login UI
    //        // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Retrieve the app delegate
         MyAppAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];
     }];
    //    }
}

- (IBAction)BnLoginTapped:(id)sender{
    [self.view endEditing:YES];
    if(lTxtFieldUsername.text.length == 0 || lTxtFieldPassword.text.length == 0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Información" message:@"Todos los campos son obligatorios." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        UserLoginParam *lUserLoginParam = [[UserLoginParam alloc] init];
        lUserLoginParam.userName = lTxtFieldUsername.text;
        lUserLoginParam.userPassword = lTxtFieldPassword.text;
        
        UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
        [lUserDataModel callLoginWebservice:lUserLoginParam];
        [self addProgressIndicator];
        [self showProgressIndicator];
        mLabelLoading.text = @"Autorizando...";
        [self setUpdatedCredentials];
    }
}

- (void) setUpdatedCredentials{
    NSUserDefaults *lUserDefaults = [NSUserDefaults standardUserDefaults];
    lUsername = [NSString stringWithFormat:@"%@",lTxtFieldUsername.text];
    lPassword = [NSString stringWithFormat:@"%@",lTxtFieldPassword.text];
    NSString *lFlag = [NSString stringWithFormat:@"%d",flag];
    
    [lUserDefaults setValue: lUsername forKey: kPrefKeyForUpdatedeMail];
    [lUserDefaults setValue: lPassword forKey: kPrefKeyForUpdatedPassword];
    [lUserDefaults setValue: lFlag forKey: kPrefKeyForUpdatedFlag];
    
    [lUserDefaults synchronize];
    
}

- (void) getUpdatedCredentials{
    NSUserDefaults *lUserDefaults = [NSUserDefaults standardUserDefaults];
    lUsername = [lUserDefaults valueForKey:kPrefKeyForUpdatedeMail];
    lPassword = [lUserDefaults valueForKey:kPrefKeyForUpdatedPassword];
    NSString *lFlag = [lUserDefaults valueForKey:kPrefKeyForUpdatedFlag];
    
    flag = [lFlag intValue];
    lTxtFieldUsername.text = @"";
    lTxtFieldPassword.text = @"";
    lblRecordPassword.text = @"Recordar Contraseña";
    
    if(flag == 1){
        lTxtFieldUsername.text = lUsername;
        lTxtFieldPassword.text = lPassword;
        lblRecordPassword.text = @"No Recordar Contraseña";
    }
}

-(IBAction)switchRecordUsrPwd:(id)sender{
    if(lSwtRcrdUsrPwd.on){
        lSwtRcrdUsrPwd.onTintColor = [UIColor whiteColor];
        lSwtRcrdUsrPwd.thumbTintColor = [UIColor grayColor];
        flag = 1;
        lTxtFieldUsername.text = lTxtFieldUsername.text;
        lTxtFieldPassword.text = lTxtFieldPassword.text;
        lblRecordPassword.text = @"No Recordar Contraseña";
    }
    else{
        lSwtRcrdUsrPwd.tintColor = [UIColor whiteColor];
        lSwtRcrdUsrPwd.thumbTintColor = [UIColor whiteColor];
        flag = 0;
        lTxtFieldUsername.text = @"";
        lTxtFieldPassword.text = @"";
        lblRecordPassword.text = @"Recordar Contraseña";
    }
}

- (IBAction)BnRegisterTapped:(id)sender{
    [lblRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if(iPhone)
    {
        UIImage *bgImage = [UIImage imageNamed:@"unite_on_iphone4.png"];
        [lblRegister setBackgroundImage:bgImage forState:UIControlStateNormal];
    }
    else
    {
        UIImage *bgImage = [UIImage imageNamed:@"unite_on_iphone5.png"];
        [lblRegister setBackgroundImage:bgImage forState:UIControlStateNormal];
    }
    [mAppDelegate setRegisterVCAsWindowRootVC:[NSArray arrayWithObjects:@"0", nil]];
}

- (IBAction)BnRecoverTapped:(id)sender{
    [mAppDelegate setPasswordRecoveryVCAsWindowRootVC];
}


- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField.text.length >= NAME_LENGTH && ![textField.text isEqualToString:@""] && textField.tag == 1){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= NAME_LENGTH || returnKey;
    }
    else if (textField.text.length >= PASSWORD_MAX_LENGTH && ![textField.text isEqualToString:@""]&& textField.tag == 2){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= PASSWORD_MAX_LENGTH || returnKey;
    }
    if(textField==lTxtFieldUsername)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAZXCVBNM0123456789._@"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
            else{
                if(textField.text.length == 0){
                    switch (c) {
                        case '.':
                        case '_':
                        case '@':
                            return NO;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        return YES;
    }
    
    return YES;
}

//Service Call Methods
//- (void)loginFacebookConnection:(NSString *)email name:(NSString *)name

- (void)loginFacebookConnection:(NSArray *)fbUserDetails{
    facebookUserRegDetails = fbUserDetails;
    
    NSString *urlString = [NSString stringWithFormat:@"%@LoginFacebook",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:LOGIN_FACEBOOK_URL,[facebookUserRegDetails objectAtIndex:0], FACEBOOK_PASSWORD, [facebookUserRegDetails lastObject]];
    
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
    //            NSLog(@"Output: %@",returnString);
    //            returnString = [returnString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    //            returnString = [returnString substringToIndex:[returnString length] - 1];
    //            returnString = [r-eturnString substringFromIndex:1];
    if([returnString length] == 0){
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TestNotification"
         object:self];
        [self showNetworkError];
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else{
        NSData* data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSLog(@"Response: %@",dict);
        NSError *error;
        NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@",lJSONArray);
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"TestNotification"
         object:self];
        if(([[lJSONArray objectForKey:@"Response"] intValue] == 0) || ([[lJSONArray objectForKey:@"Response"] intValue] == 1)){
            NSUserDefaults *lUserDefaults = [NSUserDefaults standardUserDefaults];
            flag = 0;
            NSString *lFlag = [NSString stringWithFormat:@"%d",flag];
            [lUserDefaults setValue:[lJSONArray objectForKey:@"Email"] forKey: kPrefKeyForUpdatedeMail];
            [lUserDefaults setValue:[lJSONArray objectForKey:@"Contrasenia"] forKey: kPrefKeyForUpdatedPassword];
            [lUserDefaults setValue:[lJSONArray objectForKey:@"Alias"] forKey: kPrefKeyForUpdatedUsername];
            [lUserDefaults setValue: lFlag forKey: kPrefKeyForUpdatedFlag];
            [lUserDefaults setValue:[lJSONArray objectForKey:@"Telefono"] forKey: kPrefKeyForPhone];
            [lUserDefaults setValue:@"0" forKey: kPrefKeyForOptionSelection];
            [lUserDefaults setValue:[lJSONArray objectForKey:@"NotificationCount"] forKey:kPrefKeyForNotificationCount];
            //user Login or not
            [lUserDefaults setValue:@"1" forKey:kPrefKeyForUserLogin];
            [lUserDefaults setValue:[lJSONArray objectForKey:@"Id"] forKey:kPrefKeyForCoId];
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            if([[lJSONArray objectForKey:@"ZoneCount"] intValue] > 0){
                [arr arrayByAddingObjectsFromArray:[lJSONArray objectForKey:@"Zones"]];
                [lUserDefaults setObject:arr forKey:@"kPrefKeyForAlarmZoneIds"];
            }
            else
                [lUserDefaults setObject:nil forKey:@"kPrefKeyForAlarmZoneIds"];
            [arr addObject:[lUserDefaults objectForKey:kPrefKeyForCoId]];
            
            [[SendLoc getSendLoc] initializeAllValuesForSharingLocation];
            
            [mAppDelegate registerForPushWithTag:arr];
            [mAppDelegate setHomeVCAsWindowRootVC];
        }
        else if([[lJSONArray objectForKey:@"Response"] intValue] == 3){
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"TestNotification"
             object:self];
            [mAppDelegate setMobileVCAsWindowRootVCWithFBUserDetails:facebookUserRegDetails];
        }
        
    }
}

@end
