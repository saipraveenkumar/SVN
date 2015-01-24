//
//  AddGroupViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 26/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "AddGroupViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"

#define ADDGROUP_URL @"{\"Name\":\"%@\",\"Alias\":\"%@\"}"

MyAppAppDelegate *mAppDelegate;

#define GROUPNAME_LENGTH 15

@interface AddGroupViewController (){
    UITapGestureRecognizer *tap;
}

@end

@implementation AddGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    lGroupName.self.autocapitalizationType = UITextAutocapitalizationTypeWords;
    // Do any additional setup after loading the view.
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
}

- (IBAction)BnAddTapped:(id)sender{
    if(lGroupName.text.length != 0 && ![lGroupName.text isEqualToString:@" "]){
        [self addProgressIndicator];
        [self showProgressIndicator];
        mLabelLoading.text = @"Agregando...";
        [self performSelectorInBackground:@selector(callAddGroupWebService) withObject:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Por favor escribe el nombre del grupo." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)callAddGroupWebService{
    NSUserDefaults *lGetUserData = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@AgregarGroup",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:ADDGROUP_URL,lGroupName.text,[lGetUserData objectForKey:@"kPrefKeyForUpdatedUsername"]];
    
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
    NSLog(@"Output: %@",returnString);
    [self hideProgressIndicator];
    if(returnString.length > 0){
        if([[returnString substringWithRange:NSMakeRange(1, returnString.length-2)] isEqualToString:@"Success"]){
            [mAppDelegate setGroupsListVCAsWindowRootVC];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Agregado, sin éxito." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        [self showNetworkError];
    }
}

- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setGroupsListVCAsWindowRootVC];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //    UIAlertView *alert;
    //    [textField resignFirstResponder];
    if(textField.text.length >= GROUPNAME_LENGTH && ![textField.text isEqualToString:@""] ){
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= GROUPNAME_LENGTH || returnKey;
    }
    
    if(textField==lGroupName)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"QWERTYUIOPLKJHGFDSAZXCVBNMqwertyuioplkjhgfdsazxcvbnm0123456789 -_"];
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
                        case '_':
                        case '-':
                        case ' ':
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if([textField.text isEqualToString:@"\n"]){
        return NO;
    }
    return YES;
}

@end
