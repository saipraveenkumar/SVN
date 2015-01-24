//
//  ContactViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ContactViewController.h"
#import "MyAppAppDelegate.h"

MyAppAppDelegate *mAppDelegate;

@interface ContactViewController ()

@end

@implementation ContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
//    self.navigationController.navigationBarHidden = YES;
}

-(IBAction)BnCallTapped:(id)sender{
    
    NSURL *phoneURL;
    
    if([sender tag] == 1){
        phoneURL = [NSURL URLWithString:@"tel:911"];
    }
    else if([sender tag] == 2){
        phoneURL = [NSURL URLWithString:@"tel:911"];
    }
    else{
        phoneURL = [NSURL URLWithString:@"tel:104"];
    }
    
    NSString *model = [[UIDevice currentDevice] model];
    
    if([model isEqualToString:@"iPhone"]){
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No se puede colocar una llamada." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    
}

    
@end
