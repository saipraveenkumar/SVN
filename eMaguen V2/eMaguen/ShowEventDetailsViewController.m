//
//  ShowEventDetailsViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 27/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ShowEventDetailsViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"
#import "GetEventsModel.h"
#import "UserDataModel.h"
#import "GetEventsCommentsCountModel.h"

MyAppAppDelegate *mAppDelegate;
//GetEventsCommentsModel *lGetEventsCommentsModel;

@interface ShowEventDetailsViewController ()
{
    int  commentsCount;
    NSArray *tempArray;
    NSString *eventDateTime, *eventTitle, *eventDescription, *eventCategory, *eventImage, *mEventId;
    UIActivityIndicatorView *activityView;
}
@end

@implementation ShowEventDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        commentsCount = 0;
        [self addNotificationHandlers];
        [self addProgressIndicator];
        [self showProgressIndicator];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_EVENTS_COMMENTS_COUNT_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_EVENTS_COMMENTS_COUNT_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self loadData];
}

-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

-(void)setDetails:(NSString*)eventId{
    mEventId = eventId;
    GetEventsCommentsCountModel *lGetEventsCommentsCountModel = [GetEventsCommentsCountModel getEventsCommentsCountModel];
    [lGetEventsCommentsCountModel callGetEventsCommentsCountWebserviceWithEventId:mEventId];
    mLabelLoading.text = @"Buscando...";
    NSLog(@"The event id:%@",mEventId);
}

-(void)loadData{
    
    GetEventsCommentsCountModel *lGetEventsCommentsCountModel = [GetEventsCommentsCountModel getEventsCommentsCountModel];
    NSMutableDictionary *lArray = [[NSMutableDictionary alloc]initWithDictionary:lGetEventsCommentsCountModel.arrayEventsCommentsCount];
    NSLog(@"Dict:%@",lArray);
    commentsCount = [[lArray objectForKey:@"CantidadComentarios"] intValue];
    lDateTime.text = [NSString stringWithFormat:@"Fecha / Hora: %@",[lArray objectForKey:@"Fecha"]];//eventDateTime
    lBlogTitle.text = @"";
    
    
    lDescription.text = [[lArray objectForKey:@"Descripcion"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    lDescription.text = [lDescription.text stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
    lDescription.text = [lDescription.text stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    lDescription.text = [lDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    
    eventImage = [lArray objectForKey:@"Foto"];
    if([eventImage isEqualToString:@""] || [eventImage isEqualToString:@" "]){
        lImage.image = [UIImage imageNamed:@"placeholder.png"];
    }
    else{
        activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.color = [UIColor blackColor];
        activityView.transform = CGAffineTransformMakeScale(1.50, 1.50);
        activityView.center=lImage.center;
        [activityView startAnimating];
        [self.view addSubview:activityView];
        [self loadImageName:eventImage];
    }
    lImage.contentMode = UIViewContentModeScaleToFill;
    int categoryId = [[lArray objectForKey:@"Categoria"] intValue];
//    NSLog(@"Category:%d",categoryId);
    if(categoryId == 68){
        lImageType.image = [UIImage imageNamed:@"notification.png"];
    }
    else if(categoryId == 70){
        lImageType.image = [UIImage imageNamed:@"robo.png"];
    }
    else if(categoryId == 71){
        lImageType.image = [UIImage imageNamed:@"choque.png"];
    }
    else if(categoryId == 72){
        lImageType.image = [UIImage imageNamed:@"sospechoso.png"];
    }
    else if(categoryId == 73){
        lImageType.image = [UIImage imageNamed:@"obras.png"];
    }
    else{
        lImageType.image = [UIImage imageNamed:@"notification.png"];
    }
    [lBnComm setTitle:[NSString stringWithFormat:@"%d Comentarios",commentsCount] forState:UIControlStateNormal];
    if(commentsCount==0){
        lBnComm.enabled = NO;
    }
    else{
        lBnComm.enabled = YES;
    }
    lBnAddComm.hidden = NO;
    lImageType.hidden = NO;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    lBnAddComm.hidden = YES;
    lImageType.hidden = YES;
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    //[self loadData];
    
    lDescription.textAlignment = NSTextAlignmentJustified;
    [lDescription setFont:[UIFont systemFontOfSize:14]];
}

-(IBAction)BnAddComment:(id)sender{
//    NSLog(@"Event Details -> Event id :%d",mEventId);
    [mAppDelegate setShowEventAddCommentViewController:[mEventId intValue]];
}

-(IBAction)BnComments:(id)sender{
    [mAppDelegate ShowEventCommentsViewController:[mEventId intValue]];
}

-(IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setEventsVCAsWindowRootVC];
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
