//
//  NotificationDetailViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "NotificationDetailViewController.h"
#import "MyAppAppDelegate.h"
#import "GetNotificationListModel.h"
#import "StringID.h"
#import "QueryManagerModel.h"

#define INSERT_NOTIFI_ID @"insert into Notificaion values ('%@',%d)"


MyAppAppDelegate *mAppDelegate;

NSString *lImageBaseURL = @"http://emaguen.azurewebsites.net/uploadedDocs/blog/";

@interface NotificationDetailViewController ()
{
    int mEventID;
    NSString *mDateTime;
    NSString *mComments;
    NSString *mTitle;
    NSString *mDescription;
    NSString *mImageName;
    NSDictionary *lArray1;
    UIActivityIndicatorView *activityView;
}

@end

@implementation NotificationDetailViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
        [self addProgressIndicator];
        [self showProgressIndicator];
        //        [self hideProgressIndicator];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: NOTIFICATION_DETAIL_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: NOTIFICATION_DETAIL_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self setData];
}
-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

-(void) setEventID:(int)lEventID{
    mEventID  = lEventID;
    NSLog(@"The event id in nitidetaVC:%d",mEventID);
    
    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
    QueryManagerModel *lQuery = [QueryManagerModel getQueryManagerModel];
    NSString *sqlQuery = [NSString stringWithFormat:INSERT_NOTIFI_ID,[lData objectForKey:@"kPrefKeyForUpdatedUsername"],mEventID];
    if([lQuery executeQuery:sqlQuery]){
        NSLog(@"Notification Added");
    }
    
    GetNotificationListModel *lGetNotificationListModel = [GetNotificationListModel getGetNotificationListModel];
    [lGetNotificationListModel callGetNotificationDetailWebservice:[NSString stringWithFormat:@"%d",mEventID]];
    [self showProgressIndicator];
    mLabelLoading.text = @"Cargando...";

}

- (void) setData{
    GetNotificationListModel *lGetNotificationModel = [GetNotificationListModel getGetNotificationListModel];
    lArray1 = lGetNotificationModel.notificationData;
    
    NSLog(@"%@",lArray1);

    mDateTime = [NSString stringWithFormat:@"Fecha / Hora: %@",[lArray1 objectForKey:@"Fecha"]];
    mComments = [NSString stringWithFormat:@"%d Comentarios",[[lArray1 objectForKey:@"Comentarios"] intValue]];
    mTitle = [lArray1 objectForKey:@"Titulo"];
    mDescription = [[lArray1 objectForKey:@"Contenido"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    mImageName = [lArray1 objectForKey:@"Foto"];
    
    NSString *lType = [lArray1 objectForKey:@"type"];
    lType = [lType lowercaseString];
    lType = [lType stringByReplacingOccurrencesOfString:@" " withString:@""];
    lImageType.image = [UIImage imageNamed:@"notification.png"];
    
    lDescription.text = mDescription;
    lBlogTitle.text = mTitle;
    lComments.text = mComments;
    lDateTime.text = mDateTime;
    
    
    
    if([mImageName isEqualToString:@""])
        lImage.image = [UIImage imageNamed:@"placeholder.png"];
    else
    {
        activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.color = [UIColor blackColor];
        activityView.transform = CGAffineTransformMakeScale(1.50, 1.50);
        activityView.center=lImage.center;
        [activityView startAnimating];
        
        [self.view addSubview:activityView];
        
        [self loadImageName:mImageName];
//        [self performSelector:@selector(loadImageName:) withObject:mImageName afterDelay:0.5];
    }
    
    
    lDateTime.hidden = NO;
    lBlogTitle.hidden = NO;
    lImageType.hidden = NO;
    bnAddComment.hidden = NO;
    bnShowComments.hidden = NO;
    lComments.hidden = NO;
    [self hideProgressIndicator];

}

- (void)loadImageName:(NSString*)imgName{
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imgName]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            lImage.image = [UIImage imageWithData: data];
            [activityView stopAnimating];
        });
    });
}


- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setNotificationsVCAsWindowRootVC];
}

- (IBAction)BnCommentsTapped:(id)sender{
//    NSDictionary *lArray1;
////    if([[lArray1 objectForKey:@"Comentarios"] intValue]){
//////        NSLog(@"The event id final is:%d",[[lArray1 objectForKey:@"Id"] intValue]);
//    for(NSDictionary *dict in lArray){
//        if([[dict objectForKey:@"Id"] intValue] == mEventID){
//            lArray1 = dict;
//        }
//    }
        [mAppDelegate setCommentsVCAsWindowRootVCWithEventId:[[lArray1 objectForKey:@"Id"] intValue] andNotificationTitle:[lArray1 objectForKey:@"Titulo"]];
        //[[lArray1 objectForKey:@"Id"] intValue]
//    }
}

- (IBAction)BnAddTapped:(id)sender{
//    NSDictionary *lArray1;
//    for(NSDictionary *dict in lArray){
//        if([[dict objectForKey:@"Id"] intValue] == mEventID){
//            lArray1 = dict;
//        }
//    }
    [mAppDelegate setAddCommentsVCAsWindowRootVCWithEventId:[[lArray1 objectForKey:@"Id"] intValue]];
//    //[[lArray1 objectForKey:@"Id"] intValue]
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    lDateTime.hidden = YES;
    lBlogTitle.hidden = YES;
    lImageType.hidden = YES;
    bnAddComment.hidden = YES;
    bnShowComments.hidden = YES;
    lComments.hidden = YES;
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    [self addProgressIndicator];
    [self hideProgressIndicator];
    lImage.contentMode = UIViewContentModeScaleToFill;
    
    lDescription.textAlignment = NSTextAlignmentJustified;
}


@end
