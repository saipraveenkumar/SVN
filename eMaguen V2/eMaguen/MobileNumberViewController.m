//
//  MobileNumberViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 09/01/15.
//  Copyright (c) 2015 Simplicity. All rights reserved.
//

#import "MobileNumberViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"
#import "UserDataModel.h"
#import "SendLoc.h"

#define LOGIN_FACEBOOK_URL @"{\"Email\":\"%@\",\"Password\":\"%@\",\"LoginType\":\"%@\"}"

#define MOBILE_LENGTH 15

MyAppAppDelegate *mAppAppDelegate;

@interface MobileNumberViewController (){
    NSArray *mFbUserDetails;
    UITapGestureRecognizer *tap;
    UIActivityIndicatorView *activityView;
}
@end

@implementation MobileNumberViewController

- (void)setFBUserData:(NSArray *)fbUserDetails{
    mFbUserDetails = fbUserDetails;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
    }
    return self;
}

- (void) addNotificationHandlers{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: USER_REGISTER_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: USER_REGISTER_FAILED object: nil];
}

- (void) removeNotificationHandlers{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)onLoginFinish:(NSNotification*) lNotification{
    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    if(![lUserDataModel isUserRegistered])
    {
        [self hideProgressIndicator];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:lUserDataModel.userMessage delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
            NSString *urlString = [NSString stringWithFormat:@"%@LoginFacebook",lServiceURL];
            NSString *jsonString = [NSString stringWithFormat:LOGIN_FACEBOOK_URL,[mFbUserDetails objectAtIndex:0], FACEBOOK_PASSWORD, [mFbUserDetails lastObject]];
        
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
                [self hideProgressIndicator];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Temporary Error. Try again..!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
            else{
                NSData* data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
                //    NSLog(@"Response: %@",dict);
                NSError *error;
                NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSLog(@"%@",lJSONArray);
                if(([[lJSONArray objectForKey:@"Response"] intValue] == 0) || ([[lJSONArray objectForKey:@"Response"] intValue] == 1)){
                    NSUserDefaults *lUserDefaults = [NSUserDefaults standardUserDefaults];
                    NSString *lFlag = [NSString stringWithFormat:@"0"];
                    [lUserDefaults setValue:[lJSONArray objectForKey:@"Email"] forKey: @"kPrefKeyForUpdatedeMail"];
                    [lUserDefaults setValue:[lJSONArray objectForKey:@"Contrasenia"] forKey: @"kPrefKeyForUpdatedPassword"];
                    [lUserDefaults setValue:[lJSONArray objectForKey:@"Alias"] forKey: @"kPrefKeyForUpdatedUsername"];
                    [lUserDefaults setValue: lFlag forKey: @"kPrefKeyForUpdatedFlag"];
                    [lUserDefaults setValue:[lJSONArray objectForKey:@"Telefono"] forKey: @"kPrefKeyForPhone"];
                    [lUserDefaults setValue:@"0" forKey: @"kPrefKeyForOptionSelection"];
                    
                    //user Login or not
                    [lUserDefaults setValue:@"1" forKey:@"kPrefKeyForUserLogin"];
                    [lUserDefaults setValue:[lJSONArray objectForKey:@"Id"] forKey:@"kPrefKeyForCoId"];
                    [lUserDefaults setValue:[lJSONArray objectForKey:@"NotificationCount"] forKey:@"kPrefKeyForNotificationCount"];
                    NSMutableArray *arr = [[NSMutableArray alloc]init];
                    if([[lJSONArray objectForKey:@"ZoneCount"] intValue] > 0){
                        [arr arrayByAddingObjectsFromArray:[lJSONArray objectForKey:@"Zones"]];
                        [lUserDefaults setObject:arr forKey:@"kPrefKeyForAlarmZoneIds"];
                    }
                    else
                        [lUserDefaults setObject:nil forKey:@"kPrefKeyForAlarmZoneIds"];
                    [arr addObject:[lUserDefaults objectForKey:@"kPrefKeyForCoId"]];
                    
                    [[SendLoc getSendLoc] initializeAllValuesForSharingLocation];
                    
                    [mAppAppDelegate registerForPushWithTag:arr];
                    [self hideProgressIndicator];
                    [mAppAppDelegate setHomeVCAsWindowRootVC];
                }
                else if([[lJSONArray objectForKey:@"Response"] intValue] == 3){
//                    [mAppAppDelegate setMobileVCAsWindowRootVCWithFBUserDetails:facebookUserRegDetails];
                }
                
            }
        }
}

- (void)onLoginFailed:(NSNotification*) lNotification{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mAppAppDelegate = [MyAppAppDelegate getAppDelegate];
    lblName.text = [mFbUserDetails objectAtIndex:1];
    lblEmail.text = [mFbUserDetails objectAtIndex:0];
    
    lblRegister.enabled = NO;
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    if([mFbUserDetails count] == 4){
        activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.color = [UIColor blackColor];
        activityView.transform = CGAffineTransformMakeScale(1.50, 1.50);
        activityView.center=lblProfileImage.center;
        [activityView startAnimating];
        [self.view addSubview:activityView];
        lblProfileImage.contentMode = UIViewContentModeScaleToFill;
        lblProfileImage.layer.masksToBounds = YES;
        lblProfileImage.layer.opaque = NO;
        lblProfileImage.layer.cornerRadius = 20;
        [self loadImageName:[mFbUserDetails objectAtIndex:[mFbUserDetails count]-2]];
    }
}

- (void)loadImageName:(NSString*)imgName{
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",imgName]]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            lblProfileImage.image = [UIImage imageWithData:data];
            [activityView stopAnimating];
        });
    });
}

- (void)handleTap:(id)sender{
    if(lblMoibleNumber.text.length > 0){
        lblRegister.enabled = YES;
    }
    else{
        lblRegister.enabled = NO;
    }
    [self.view endEditing:YES];
}

- (IBAction)BnRegisterTapped:(id)sender{
    [self addProgressIndicator];
    UserRegisterParam *lUserLoginParam = [[UserRegisterParam alloc] init];
    lUserLoginParam.userName = [lblName.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    lUserLoginParam.userPassword = [FACEBOOK_PASSWORD stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    lUserLoginParam.userEmail = [lblEmail.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    lUserLoginParam.userPhone = lblMoibleNumber.text;
    
    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    [lUserDataModel callRegisterWebservice:lUserLoginParam];
    [self showProgressIndicator];
    mLabelLoading.text = @"Registrando...";
}

- (IBAction)BnBackTapped:(id)sender{
    [mAppAppDelegate setLoginVCAsWindowRootVC];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length >= MOBILE_LENGTH){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= MOBILE_LENGTH || returnKey;
    }
    
    if(textField==lblMoibleNumber)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
        }
        return YES;
    }
    
    return YES;
}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
