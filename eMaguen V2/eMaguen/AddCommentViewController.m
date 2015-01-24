//
//  AddCommentViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "AddCommentViewController.h"
#import "AddCommentModel.h"
#import "UserDataModel.h"
#import "StringID.h"
#import "GetNotificationListModel.h"
#import "MyAppAppDelegate.h"

#define MAX_LENGTH 300

MyAppAppDelegate *mAppDelegate;


@interface AddCommentViewController (){
    int mBlogId, tblIndex;
    NSArray *lArray;
    UITapGestureRecognizer *tap;
    UIAlertView *alertBox;
}

@end


@implementation AddCommentViewController


-(void) setEventID:(int)lEventID{
    mBlogId  = lEventID;
//    tblIndex = index;
    NSLog(@"eventid and index:%d",mBlogId);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
        [self addProgressIndicator];
        [self hideProgressIndicator];
        GetNotificationListModel *lGetNotificationListModel = [GetNotificationListModel getGetNotificationListModel];
        lArray = [[NSArray alloc] initWithArray:lGetNotificationListModel.arrayNotifications];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: ADD_COMMENTS_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: ADD_COMMENTS_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"El comentario se agregó exitosamente." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    alertBox.tag = 1;
    [alertBox show];
}

-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        NSDictionary *lArray1;
        for(NSDictionary *dict in lArray){
            if([[dict objectForKey:@"Id"] intValue] == mBlogId){
                lArray1 = dict;
            }
        }
        [mAppDelegate setCommentsVCAsWindowRootVCWithEventId:[[lArray1 objectForKey:@"Id"] intValue] andNotificationTitle:[lArray1 objectForKey:@"Titulo"]];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    lTextView.delegate = self;
    
    lTextView.layer.borderColor = [[UIColor grayColor]CGColor];
    lTextView.layer.cornerRadius = 5.0f;
    lTextView.layer.borderWidth = 1.0f;
    [lTextView setFont:[UIFont systemFontOfSize:14]];
    
    [lTextView becomeFirstResponder];
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
}

- (void) cancel{
//    NSLog(@"Cancel");
    [lTextView resignFirstResponder];
}

- (void) save{
//    NSLog(@"Save");
    [lTextView resignFirstResponder];
}

-( IBAction)BnSubmitTapped:(id)sender{
    [lTextView resignFirstResponder];
    
    if((lTextView.text.length == 0) || [lTextView.text isEqualToString:@" "]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Por favor introduce comentario." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
    
    AddCommentParam *lAddCommentParam = [[AddCommentParam alloc] init];
    
    NSString *testString = lTextView.text;
    NSString *newString = [testString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    lAddCommentParam.userComments = newString;

//    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    lAddCommentParam.userName  = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedUsername"];
    lAddCommentParam.userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedPassword"];
    lAddCommentParam.blogId = [NSString stringWithFormat:@"%d",mBlogId];
    lAddCommentParam.coPropId = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForCoId"];
    
    AddCommentModel *lAddCommentModel = [AddCommentModel getAddCommentModel];
    [lAddCommentModel callAddCommentWebservice:lAddCommentParam];
    
    [self showProgressIndicator];
    mLabelLoading.text = @"Agregando...";
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if(lTextView==textView)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-\"\"0123456789 "];
        for (int i = 0; i < [text length]; i++)
        {
            unichar c = [text characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
            else{
                if(textView.text.length == 0){
                    switch (c) {
                        case '_':
                        case '-':
                        case ' ':
                        case '"':
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
    
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= MAX_LENGTH || returnKey;
}

-( IBAction)BnBackTapped:(id)sender{
    [lTextView resignFirstResponder];
    [mAppDelegate setNotificationDetailVCAsWindowRootVCWithEventId:mBlogId];
}

@end
