//
//  ConfigAddAlarmViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 15/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "SendReqViewController.h"
#import "MyAppAppDelegate.h"

#define NO_CONTACT @"Sin Contacto"

MyAppAppDelegate *mAppDelegate;

@interface SendReqViewController (){
    NSArray *mAlarmDetails;
    NSMutableArray *mobileNo;
    NSString *mAlarmName;
}
@end

@implementation SendReqViewController

- (void)setData:(NSArray *)alarmDetails{
    mAlarmDetails = alarmDetails;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    mobileNo = [[NSMutableArray alloc]init];
    lblMobileNumber1.hidden = YES;
    lblMobileNumber2.hidden = YES;
    lblMobileNumber3.hidden = YES;
    for(int i = 1; i<=[[mAlarmDetails subarrayWithRange:NSMakeRange(1, [mAlarmDetails count] - 1)] count];i++){
        if (i == 1){
            [mobileNo addObject:[[mAlarmDetails objectAtIndex:i] objectForKey:@"phone"]];
            lblMobileNumber1.text = [[mAlarmDetails objectAtIndex:i] objectForKey:@"name"];
            lblMobileNumber1.hidden = NO;
        }
        else if (i == 2){
            [mobileNo addObject:[[mAlarmDetails objectAtIndex:i] objectForKey:@"phone"]];
            lblMobileNumber2.text = [[mAlarmDetails objectAtIndex:i] objectForKey:@"name"];
            lblMobileNumber2.hidden = NO;
        }
        else if (i == 3){
            [mobileNo addObject:[[mAlarmDetails objectAtIndex:i] objectForKey:@"phone"]];
            lblMobileNumber3.text = [[mAlarmDetails objectAtIndex:i] objectForKey:@"name"];
            lblMobileNumber3.hidden = NO;
        }
    }
    NSLog(@"Mobile Numbers:%@",mobileNo);
    mAlarmDetails = nil;
}

- (IBAction)BnSendTapped:(id)sender{
    NSUserDefaults *lUDefaults = [NSUserDefaults standardUserDefaults];
    //testing message
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Atención" message:@"Su dispositivo no admite SMS!" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }

//    NSArray *recipents = mobileNos;
    NSString *message = [NSString stringWithFormat:@"%@ te ha agregado como contacto para informarte sobre su Alarma. Instala eMaguén desde aquí www.emaguen.com/mobile",[lUDefaults stringForKey:@"kPrefKeyForUpdatedUsername"]];

    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:mobileNo];
    [messageController setBody:message];

    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;

        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Atención" message:@"Error al enviar SMS!" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }

        case MessageComposeResultSent:{
            [mAppDelegate setChooseAlarmViewController];
        }
            break;

        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)BnNoTapped:(id)sender{
    [mAppDelegate setChooseAlarmViewController];
}

@end
