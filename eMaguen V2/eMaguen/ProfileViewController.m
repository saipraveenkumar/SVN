//
//  ProfileViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ProfileViewController.h"
#import "MyAppAppDelegate.h"
#import "HomeViewController.h"
#import "SendLoc.h"

static NSString *kPrefKeyForLocationService             = @"kPrefKeyForLocationService";

MyAppAppDelegate *mAppDelegate;


@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    NSUserDefaults *lServiceStatus = [NSUserDefaults standardUserDefaults];
    int status = [[lServiceStatus objectForKey:@"kPrefKeyForLocationService"] intValue];
    
    if(status== 0){
        lSwitchService.on = NO;
        lblServiceStatus.text = @"Compartir mi posición - No";
    }
    else{
        lSwitchService.on = YES;
        lblServiceStatus.text = @"Compartir mi posición - Si";
    }
    lSwitchService.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
  
    [lSwitchService addTarget:self action:@selector(setServiceState:) forControlEvents:UIControlEventValueChanged];
    
}

- (IBAction)setServiceState:(id)sender{
    SendLoc *loc = [SendLoc getSendLoc];
    NSUserDefaults *lServiceStatus = [NSUserDefaults standardUserDefaults];
    if(lSwitchService.on){
        NSLog(@"On");
        lblServiceStatus.text = @"Compartir mi posición - Si";
        [lServiceStatus setValue:@"1" forKey:@"kPrefKeyForLocationService"];
        [loc shareCurrentLocation];
    }
    else{
        NSLog(@"Off");
        lblServiceStatus.text = @"Compartir mi posición - No";
        [lServiceStatus setValue:@"0" forKey:@"kPrefKeyForLocationService"];
        [loc stopShareLocation];
    }
}

- (IBAction)BnMyProfileTapped:(id)sender{
    [mAppDelegate setMyProfileVCAsWindowRootVC];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
