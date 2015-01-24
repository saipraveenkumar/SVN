//
//  ShowEventAddCommentViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 29/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ShowEventAddCommentViewController.h"
#import "AddEventCommentModel.h"
#import "UserDataModel.h"
#import "StringID.h"
#import "GetNotificationListModel.h"
#import "MyAppAppDelegate.h"
#import "GetEventsModel.h"
#import "GetEventsCommentsModel.h"

#define MAX_LENGTH 300

MyAppAppDelegate *mAppDelegate;

@interface ShowEventAddCommentViewController ()
{
    NSArray *lArray;
    int mEventId;
    NSString *lDateTime;
    NSString *lTitle;
    NSString *lDescription;
    NSString *lCategory;
    NSString *lImage;
    UIAlertView *alertCommentSuccess;
    UITapGestureRecognizer *tap;
}
@end

@implementation ShowEventAddCommentViewController

-(void)setEventID:(int)lEventID{
    mEventId = lEventID;
    [self loadEventData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: ADD_EVENT_COMMENTS_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: ADD_EVENT_COMMENTS_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self callSuccessEvent];
}

-(void)callSuccessEvent{
    [mAppDelegate ShowEventDetailsVCAsWindowRootVC:[NSString stringWithFormat:@"%d",mEventId]];
}


-(void)loadEventData{
    GetEventsModel *lGetEventsModel = [GetEventsModel getGetEventsModel];
    lArray = [[NSArray alloc]initWithArray:lGetEventsModel.arrayEvents];
    for(int i = 0; i<[lArray count]; i++){
        if([[[lArray objectAtIndex:i] objectForKey:@"Id"] intValue] == mEventId){
            NSDictionary *lArray1 = [lArray objectAtIndex:i];
            lDateTime = [lArray1 objectForKey:@"Fecha"];
            lTitle = [lArray1 objectForKey:@"BarrioNmb"];
            lDescription = [lArray1 objectForKey:@"Descripcion"];
            lCategory = [lArray1 objectForKey:@"Categoria"];
            lImage = [lArray1 objectForKey:@"Foto"];
        }
    }
}


-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)viewDidLoad {
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

-( IBAction)BnSubmitTapped:(id)sender{
    
    [lTextView resignFirstResponder];
    if((lTextView.text.length == 0) || [lTextView.text isEqualToString:@" "]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Por favor introduce comentario" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        AddEventCommentParam *lAddEventCommentParam = [[AddEventCommentParam alloc] init];
        
        NSString *testString = lTextView.text;
        lAddEventCommentParam.userComments = testString;
        lAddEventCommentParam.userName  = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedUsername"];
        lAddEventCommentParam.userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedPassword"];
        lAddEventCommentParam.blogId = [NSString stringWithFormat:@"%d",mEventId];
        lAddEventCommentParam.coPropId = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForCoId"];
        [self addProgressIndicator];
        [self showProgressIndicator];
        mLabelLoading.text = @"Agregando...";
        AddEventCommentModel *lAddEventCommentModel = [AddEventCommentModel getAddEventCommentModel];
        [lAddEventCommentModel callAddEventCommentWebservice:lAddEventCommentParam];
    }
}

-( IBAction)BnBackTapped:(id)sender{
    [mAppDelegate ShowEventDetailsVCAsWindowRootVC:[NSString stringWithFormat:@"%d",mEventId]];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
