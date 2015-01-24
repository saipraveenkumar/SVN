//
//  UserDataModel.m
//  CERSAI14
//
//  Created by Rohit Yermalkar on 02/05/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "UserDataModel.h"
#import "StringID.h"
#import "NSString+SBJSON.h"
#import "NSObject+NSClassMethod.h"


#define REGISTER_URL @"RegisterUserv2?name=%@&password=%@&email=%@&PhoneNumber=%@"
#define LOGIN_URL @"LoginUsuario?email=%@&contrasenia=%@"
#define LOGIN_FACEBOOK_URL @"{\"Email\":\"%@\",\"Password\":\"%@\",\"LoginType\":\"%@\"}"
#define FORGOT_URL @"ForgotPasswordEmail?email=%@"
#define UPDATE_URL @"UpdateProfileEmails?email=%@&password=%@&ProfileEmails=%@"


@implementation UserDataModel
// Singleton Object
static UserDataModel *sUserDataModel = nil;


@synthesize userPassword = mUserPassword;
@synthesize userName = mUserName;
@synthesize userEmail = mUserEmail;
@synthesize userActive = mUserActive;
@synthesize userAlias = mUserAlias;
@synthesize userID = mUserID;
@synthesize userTelephone = mUserTelephone;
@synthesize userMessage = mUserMessage;
@synthesize userRegistered = mUserRegistered;
@synthesize facebook = mFacebook;
@synthesize twitter= mTwitter;
@synthesize whatsapp= mWhatsapp;
@synthesize userSOSEmail = mUserSOSEmail;
@synthesize userNotificationCount = mUserNotificationCount;



#pragma mark -

+ (UserDataModel *)getUserDataModel
{
    @synchronized(self)
    {
        if(sUserDataModel == nil)
        {
            sUserDataModel = [[UserDataModel alloc] init];
        }
        return sUserDataModel;
    }
}



- (BOOL)callLoginWebservice:(UserLoginParam *)param{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    NSString *lLoginParams = [NSString stringWithFormat:LOGIN_URL,param.userName,param.userPassword];
    NSString *newString = [lLoginParams stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,newString];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mLoginConnection = [[Connection alloc] initWithURL: lURL];
    [mLoginConnection addJSONHeader];
    
    [mLoginConnection setOwner:self];
    [mLoginConnection ConnectionStart];
    
    return lResult;
}

- (BOOL)callRegisterWebservice:(UserRegisterParam *)param{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    NSString *lLoginParams = [NSString stringWithFormat:REGISTER_URL,param.userName,param.userPassword,param.userEmail,param.userPhone];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,lLoginParams];
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mRegisterConnection = [[Connection alloc] initWithURL: lURL];
    [mRegisterConnection addJSONHeader];
    
    [mRegisterConnection setOwner:self];
    [mRegisterConnection ConnectionStart];
    
    return lResult;
}


- (BOOL)callForgotPasswordWebservice:(UserRegisterParam *)param{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    NSString *lLoginParams = [NSString stringWithFormat:FORGOT_URL,param.userEmail];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,lLoginParams];
    
    
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mRecoveryConnection = [[Connection alloc] initWithURL: lURL];
    [mRecoveryConnection addJSONHeader];
    
    [mRecoveryConnection setOwner:self];
    [mRecoveryConnection ConnectionStart];
    
    return lResult;
}

- (BOOL)callUpdateProfileWebservice:(NSString *)sosMail{
    BOOL lResult = false;
    [self resetConnection];
    [self resetData];
    
    //NSString *lLoginParams = [NSString stringWithFormat:UPDATE_URL,param.userEmail,param.userPassword,param.userSOSEmail];
    NSString *lLoginParams = [NSString stringWithFormat:UPDATE_URL,[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedeMail"],[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedPassword"],sosMail];
    NSString *lServiceURL1 = [NSString stringWithFormat:@"%@%@",lServiceURL,lLoginParams];
    
    
    NSURL *lURL = [[NSURL alloc] initWithString: lServiceURL1];
    
    mProfileConnection = [[Connection alloc] initWithURL: lURL];
    [mProfileConnection addJSONHeader];
    
    [mProfileConnection setOwner:self];
    [mProfileConnection ConnectionStart];
    
    return lResult;
}




- (BOOL)isUserloggedIn
{
    return (mUserID);
}

- (BOOL)isUserRegistered
{
    return (mUserRegistered);
}


- (void)resetConnection{
    if(mLoginConnection != nil)
    {
        [mLoginConnection setOwner:nil];
        mLoginConnection = nil;
    }
    else if(mRegisterConnection != nil)
    {
        [mRegisterConnection setOwner:nil];
        mRegisterConnection = nil;
    }
    else if(mRecoveryConnection != nil)
    {
        [mRecoveryConnection setOwner:nil];
        mRecoveryConnection = nil;
    }
    else if(mProfileConnection != nil)
    {
        [mProfileConnection setOwner:nil];
        mProfileConnection = nil;
    }
}

- (void)resetData{
}

#pragma mark -
#pragma mark - ConnectionDelegate Method

- (void)ConnectionFinished:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [self parseResultFromConnection: connetion];
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_LOGIN_FINISHED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mRegisterConnection])
    {
        [self parseResultFromConnection: connetion];
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_REGISTER_FINISHED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mRecoveryConnection])
    {
        [self parseResultFromConnection: connetion];
        [[NSNotificationCenter defaultCenter] postNotificationName:PASSWORD_RECOVER_FINISHED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mProfileConnection])
    {
        [self parseResultFromConnection: connetion];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PROFILE_FINISHED object:self];
        [self resetConnection];
    }
}
- (void)ConnectionFailed:(Connection *)connetion{
    if([connetion isEqual: mLoginConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_LOGIN_FAILED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mRegisterConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_REGISTER_FAILED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mRecoveryConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:PASSWORD_RECOVER_FAILED object:self];
        [self resetConnection];
    }
    if([connetion isEqual: mProfileConnection])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_PROFILE_FAILED object:self];
        [self resetConnection];
    }
}

- (void)parseResultFromConnection:(Connection *)connection{
    
    NSString *lResponseBody = [[NSString alloc] initWithData:connection.ResponceData encoding:NSUTF8StringEncoding];
    if([lResponseBody length] == 0){
        mUserMessage = @"Failed at server side. Try again...!";
    }
    else{
        lResponseBody = [lResponseBody stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        lResponseBody = [lResponseBody substringToIndex:[lResponseBody length] - 1];
        lResponseBody = [lResponseBody substringFromIndex:1];
        NSLog(@"Response: %@",lResponseBody);
        
        NSData* data = [lResponseBody dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error;
        NSDictionary *lJSON = [NSJSONSerialization
                               JSONObjectWithData:data
                               options:kNilOptions
                               error:&error];
        
        if([connection isEqual: mLoginConnection]){
            NSString *lMessage = lJSON[@"Mensaje"];
            mUserMessage =lJSON[@"Mensaje"];
            if(!lMessage){
                mUserID =  [lJSON[@"Id"] intValue];
                mUserName =  lJSON[@"NomApe"];
                mUserTelephone =  lJSON[@"Telefono"];
                mUserEmail =  lJSON[@"Email"];
                mUserAlias =  lJSON[@"Alias"];
                mUserPassword =  lJSON[@"Contrasenia"];
                mUserActive =  lJSON[@"Activo"];
                mUserSOSEmail =  lJSON[@"ProfileEmails"];
                mUserNotificationCount = lJSON[@"NotificationCount"];
                NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
                if([lJSON[@"ZoneCount"] intValue] > 0){
                    NSArray *arr = lJSON[@"Zones"];
                    [lData setObject:arr forKey:@"kPrefKeyForAlarmZoneIds"];
                }
                else
                    [lData setObject:nil forKey:@"kPrefKeyForAlarmZoneIds"];
            }
            
        }
        else if([connection isEqual: mRegisterConnection]){
            mUserRegistered = 0;
            mUserMessage =lJSON[@"Mensaje"];
            if([mUserMessage isEqualToString:@"User regiestered successfully"]){
                mUserRegistered = 1;
            }
            else{
                mUserRegistered = 0;
            }
            
        }
        else if([connection isEqual: mRecoveryConnection]){
            mUserMessage =lJSON[@"Mensaje"];
            
            
        }
        else if([connection isEqual: mProfileConnection]){
            mUserMessage =lResponseBody;
        }
        
    }
}


- (void) logoutUser{
    mUserID = 0;
    mUserName = nil;
    mUserTelephone = nil;
    mUserEmail = nil;
    mUserAlias = nil;
    mUserPassword = nil;
    mUserMessage = nil;
}


@end




@implementation UserLoginParam

@synthesize userName = mUserName;
@synthesize userPassword = mUserPassword;

- (void)dealloc
{
    self.userName = nil;
    self.userPassword = nil;
}

@end


@implementation UserRegisterParam

@synthesize userName = mUserName;
@synthesize userPassword = mUserPassword;
@synthesize userPhone = mUserPhone;
@synthesize userEmail= mUserEmail;
@synthesize userSOSEmail = mUserSOSEmail;

- (void)dealloc
{
    self.userName = nil;
    self.userPassword = nil;
    self.userEmail = nil;
    self.userPhone = nil;
    self.userSOSEmail = nil;
    
    
}

@end



