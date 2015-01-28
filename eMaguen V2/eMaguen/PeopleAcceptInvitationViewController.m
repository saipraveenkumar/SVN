//
//  PeopleSendInvitationViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 27/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "PeopleAcceptInvitationViewController.h"
#import "StringID.h"
#import "MyAppAppDelegate.h"

#define ACCEPT_INVITE_URL @"{\"Id\":\"%@\",\"MemberPhone\":\"%@\",\"MembershipFlag\":\"%@\"}"

MyAppAppDelegate *mAppAppDelegate;

@interface PeopleAcceptInvitationViewController (){
    NSDictionary *mInvitationDetails;
    NSString *idValue;
    int option, notificationType;
    UIAlertView *alertBox;
}

@end

@implementation PeopleAcceptInvitationViewController

- (void)setInvitaionDetails:(NSDictionary*)invitationDetails{
    mInvitationDetails = invitationDetails;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self)
//    {
//        [self addNotificationHandlers];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mAppAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    notificationType = 0;
    
    NSArray *arr = [mInvitationDetails allKeys];
    NSLog(@"All Keys:%@",arr);
    
    for (NSString *str in arr){
        if([str isEqualToString:@"type"]){
            notificationType = 1;
        }
    }
    
    if(notificationType == 0){
        lblName.text = [NSString stringWithFormat:@"%@ quiere que pertenezcas a su Grupo %@ en eMaguen",[mInvitationDetails objectForKey:@"OwnerName"],[mInvitationDetails objectForKey:@"Name"]];
    }
    else{
        lblName.text = [mInvitationDetails objectForKey:@"alert"];
    }
}

- (IBAction)BnStatusTapped:(id)sender{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* myButton = (UIButton*)sender;
        [self addProgressIndicator];
        [self showProgressIndicator];
        if(myButton.tag == 1){
            option = 1;
            if(notificationType == 1){
                idValue = [mInvitationDetails objectForKey:@"id"];
                [self performSelectorInBackground:@selector(callAcceptInvitationWebService) withObject:nil];
            }
            else{
                idValue = [mInvitationDetails objectForKey:@"Id"];
                [self performSelectorInBackground:@selector(callAcceptInvitationWebService) withObject:nil];
            }
            mLabelLoading.text = @"Aceptando...";
        }
        else{
            option = 0;
            if(notificationType == 1){
                idValue = [mInvitationDetails objectForKey:@"id"];
                [self performSelectorInBackground:@selector(callAcceptInvitationWebService) withObject:nil];
            }
            else{
                idValue = [mInvitationDetails objectForKey:@"Id"];
                [self performSelectorInBackground:@selector(callAcceptInvitationWebService) withObject:nil];
            }
            mLabelLoading.text = @"Rechazando...";
        }
    }
}

- (void)callAcceptInvitationWebService{
    NSUserDefaults *lUserData = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@AceptarGroupInvitacion",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:ACCEPT_INVITE_URL,idValue,[lUserData objectForKey:@"kPrefKeyForUpdatedeMail"],@"true"];
    
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
    
    //        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *lJson = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
    NSLog(@"Output: %@",lJson);
    [self hideProgressIndicator];
    if(option == 1){
        if([[lJson objectForKey:@"Response"] isEqualToString:@"Success"]){
            alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Invitación Aceptada." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            alertBox.tag = 3;
            [alertBox show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Su invitación no fue enviada. Inténtelo nuevamente." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else if (option == 0){
        if([[lJson objectForKey:@"Response"] isEqualToString:@"Success"]){
            alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Invitación rechazada." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            alertBox.tag = 2;
            [alertBox show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No podemos enviar la invitación ahora, inténtelo más tarde." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No podemos cumplir con su requerimiento, inténtelo más tarde." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        alertBox.tag = 1;
        [alertBox show];
    }
    [self deallocMemory];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        [mAppAppDelegate setGroupsListVCAsWindowRootVC];
    }
    else if (alertView.tag == 2){
        if(notificationType == 1){
            NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
            if([[lData objectForKey:@"kPrefKeyForUserLogin"] intValue] == 1){
                [mAppAppDelegate setGroupsListVCAsWindowRootVC];
            }
            else{
                [mAppAppDelegate setLoginVCAsWindowRootVC];
            }
        }
        else{
            [mAppAppDelegate setGroupsListVCAsWindowRootVC];
        }
    }
    else if (alertView.tag == 3){
        if(notificationType == 1){
            NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
            if([[lData objectForKey:@"kPrefKeyForUserLogin"] intValue] == 1){
                [mAppAppDelegate setGroupsListVCAsWindowRootVC];
            }
            else{
                [mAppAppDelegate setLoginVCAsWindowRootVC];
            }
        }
        else{
            [mAppAppDelegate setGroupsListVCAsWindowRootVC];
        }
    }
}

- (void)deallocMemory{
//    mInvitationDetails = nil;
}

@end
