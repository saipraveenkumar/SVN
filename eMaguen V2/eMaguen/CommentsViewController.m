//
//  CommentsViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 14/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentsListCell.h"
#import "StringID.h"
#import "MyAppAppDelegate.h"
#import "GetCommentsModel.h"
MyAppAppDelegate *mAppDelegate;


@interface CommentsViewController ()
{
    int mEventID;
    NSArray *lArray;
    NSString* notificationTitle;
}

@end

@implementation CommentsViewController

-(void) setEventID:(int)lEventID andNotificationTitle:(NSString *)notifiTitle{
    mEventID  = lEventID;
    notificationTitle = notifiTitle;
    NSLog(@"%d,%d",mEventID,lEventID);
    [self getData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
        [self addProgressIndicator];
        [self hideProgressIndicator];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_COMMENTS_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_COMMENTS_FAILED object: nil];
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

- (void) loadData{
    GetCommentsModel *lGetCommentsModel = [GetCommentsModel getCommentsModel];
    lArray = [[NSArray alloc] initWithArray:lGetCommentsModel.arrayComments];
    NSLog(@"Comm:%@",lArray);
    lblEventTitle.text = notificationTitle;
//    lTableView.rowHeight = UITableViewAutomaticDimension;
    [lTableView reloadData];
}

- (IBAction)BnBackTapped{
    [mAppDelegate setNotificationsVCAsWindowRootVC];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UIColor *blueColor = [self colorFromHexString:@"#2871B4"];
    lblTitleBgClr.backgroundColor = blueColor;
}

- (void) getData{
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    GetCommentsModel *lGetCommentsModel = [GetCommentsModel getCommentsModel];
    [lGetCommentsModel callGetCommentsWebserviceWithEventId:mEventID];
    [self showProgressIndicator];
    mLabelLoading.text = @"Buscando...";

}

//- (IBAction)BnAddTapped:(id)sender{
//    [mAppDelegate setAddCommentsVCAsWindowRootVCWithEventId:mEventID];
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [lArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    height = 189;
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"tblCellView";
    CommentsListCell *cell = (CommentsListCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        NSArray * MyCustomCellNib;
        MyCustomCellNib = [[NSBundle mainBundle] loadNibNamed:@"CommentsListCell_iPhone" owner:self options:nil];
        cell = (CommentsListCell *)[MyCustomCellNib lastObject];
    }
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *lArray1 = [lArray objectAtIndex:indexPath.row];
    
    NSString *lDateTimeString =[lArray1 objectForKey:@"Fecha"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSDate *dateTimeString = [format dateFromString:lDateTimeString];
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSString *date = [format stringFromDate:dateTimeString];
    [format setDateFormat:@"HH:mm"];
    
    NSString *time = [format stringFromDate:dateTimeString];
    
    
    NSString *lDateTime = [NSString stringWithFormat:@"%@",date];
    NSString *lTime = [NSString stringWithFormat:@"%@",time];
    
    NSString *lAuthor = [lArray1 objectForKey:@"CoPropietarioNmb"] ;
    NSString *lDescription = [lArray1 objectForKey:@"Texto"];
    
    cell.labelDateTime.text = lDateTime;
    cell.labelTime.text = lTime;
    cell.labelAuthor.text = lAuthor;
    cell.labelDescription.text = [lDescription stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    cell.labelAuthor.textColor = [self colorFromHexString:@"#2871b4"];

    return cell;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (IBAction)BnAddComment:(id)sender{
//    NSLog(@"%d",mEventID);
//    NSLog(@"Array:%@",lArray);
//    GetCommentsModel *lGetCommentsModel = [GetCommentsModel getCommentsModel];
//    NSArray *tmpNotArray = [[NSArray alloc] initWithArray:lGetCommentsModel.arrayComments];
//    
//    
//    if([lArray count]  < tableIndex){
////        NSDictionary *lArray1;
////        lArray1 = [lArray objectAtIndex:tableIndex];
////        NSLog(@"Blog,event,tableindex:%d,%d,%d",[[lArray1 objectForKey:@"Blog"] intValue],mEventID,tableIndex);
//////    lArray1 = [lArray objectAtIndex:tableIndex];
//    [mAppDelegate setAddCommentsVCAsWindowRootVCWithEventId:mEventID and:tableIndex];
//    }
//    else
//    {
//    NSLog(@"---------\n\n\n\n%@",lArray);
//        NSDictionary *lArray1;
//    for(NSDictionary *dict in lArray){
//        if([[dict valueForKey:@"Id"] intValue] == mEventID){
//            lArray1 = dict;
//        }
//    }
//        NSLog(@"Blog,event,tableindex:%d,%d,%d",[[lArray1 objectForKey:@"Blog"] intValue],mEventID,tableIndex);
        [mAppDelegate setAddCommentsVCAsWindowRootVCWithEventId:mEventID];
//    }
//
////    NSLog(@"%@",lArray1);
////    NSLog(@"comm:%d,%d",[[lArray1 objectForKey:@"Id"] intValue],tableIndex);
////    [mAppDelegate setAddCommentsVCAsWindowRootVCWithEventId:[[lArray1 objectForKey:@"Id"] intValue] and:tableIndex];
////    [[lArray1 objectForKey:@"Id"] intValue];
}


@end
