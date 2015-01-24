//
//  LoginViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "RootViewController.h"

@interface LoginViewController : RootViewController<UITextFieldDelegate,FBLoginViewDelegate>
{
//    IBOutlet UITextField *lTxtFieldUsername;
//    IBOutlet UITextField *lTxtFieldPassword;
    IBOutlet UILabel *lblRecordPassword;
    IBOutlet UIButton *lblRegister;
    IBOutlet UIButton *lblLogin;
    IBOutlet UISwitch *lSwtRcrdUsrPwd;
}
@property (nonatomic,strong) IBOutlet UITextField *lTxtFieldUsername;
@property (nonatomic,strong) IBOutlet UITextField *lTxtFieldPassword;
- (IBAction)BnLoginTapped:(id)sender;
- (IBAction)BnRegisterTapped:(id)sender;
- (IBAction)BnRecoverTapped:(id)sender;
//- (void)loginFacebookConnection:(NSString *)email name:(NSString *)name;
- (void)loginFacebookConnection:(NSArray *)fbUserDetails;
- (void)showErrorAlert;
@end
