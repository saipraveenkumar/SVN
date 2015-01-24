//
//  NotificationsViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 11/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "NotificationsViewController.h"
#import "ListTableCell.h"
#import "StringID.h"
#import "MyAppAppDelegate.h"
#import "GetNotificationListModel.h"
#import "LeftController.h"
#import "QueryManagerModel.h"
#import "FMResultSet.h"

//#define INSERT_NOTIFI_ID @"insert into Notificaion values ('%@',%d)"
#define NOTIFI_EXISTS @"select distinct nid from Notificaion where uid = '%@'"


MyAppAppDelegate *mAppDelegate;


@interface NotificationsViewController (){
    NSArray *lArray;
    NSUserDefaults *lData;
    NSMutableDictionary *lStoreReadNotifi;
    NSMutableArray *lReadNotifArray;
}

@end

@implementation NotificationsViewController

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
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_NOTIFICATIONS_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_NOTIFICATIONS_FAILED object: nil];
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
    
    GetNotificationListModel *lGetNotificationListModel = [GetNotificationListModel getGetNotificationListModel];
    lArray = [[NSArray alloc] initWithArray:lGetNotificationListModel.arrayNotifications];
    NSLog(@"Data:\n\n\n%@",lGetNotificationListModel.arrayNotifications);
    [mTableView reloadData];
    [self hideProgressIndicator];
}



- (void)viewDidLoad{
    [super viewDidLoad];
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    lReadNotifArray = [[NSMutableArray alloc]init];
    lStoreReadNotifi = [[NSMutableDictionary alloc]init];
    [self addProgressIndicator];
    [self hideProgressIndicator];
    
    lData = [NSUserDefaults standardUserDefaults];
    
    GetNotificationListModel *lGetNotificationListModel = [GetNotificationListModel getGetNotificationListModel];
    [lGetNotificationListModel callGetNotificationsWebservice];
    [self showProgressIndicator];
    mLabelLoading.text = @"Cargando...";
    [mTableView setShowsVerticalScrollIndicator:NO];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [lArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    height = 125;
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"tblCellView";
    ListTableCell *cell = (ListTableCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        NSArray * MyCustomCellNib;
        MyCustomCellNib = [[NSBundle mainBundle] loadNibNamed:@"ListTableCell_iPhone" owner:self options:nil];
        cell = (ListTableCell *)[MyCustomCellNib lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *lArray1 = [lArray objectAtIndex:indexPath.row];
    
    NSString *lDateTime = [NSString stringWithFormat:@"Fecha / Hora: %@",[lArray1 objectForKey:@"Fecha"]];
    NSString *lComments = [NSString stringWithFormat:@"%d Comentarios",[[lArray1 objectForKey:@"Comentarios"] intValue]];
    NSString *lTitle = [lArray1 objectForKey:@"Titulo"];
    NSString *lDescription = [lArray1 objectForKey:@"Contenido"];
    NSString *lType = [lArray1 objectForKey:@"type"];
    
    lType = [lType lowercaseString];
    lType = [lType stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    QueryManagerModel *lQuery = [QueryManagerModel getQueryManagerModel];
    NSString *sqlQuery = [NSString stringWithFormat:NOTIFI_EXISTS,[lData objectForKey:@"kPrefKeyForUpdatedUsername"]];
    FMResultSet *mResultSet = [lQuery getResultsFromDB:sqlQuery];
    //    int choose;
    //    while([mResultSet next]){
    ////        NSLog(@"%@",[mResultSet stringForColumn:@"nid"]);
    ////        NSLog(@"%@",[lArray1 objectForKey:@"Id"]);
    //        if([[mResultSet stringForColumn:@"nid"] intValue] == [[lArray1 objectForKey:@"Id"] intValue]){
    ////        if([[mResultSet stringForColumn:@"nid"] isEqualToString:[lArray1 objectForKey:@"Id"]]){
    ////            NSLog(@"%@,%@",[mResultSet stringForColumn:@"nid"],[lArray1 objectForKey:@"Id"]);
    //            choose = 1;
    //            break;
    //        }
    //        else{
    //            choose = 0;
    //        }
    //    }
    int choose = 0;
    if([mResultSet columnCount] > 0){
        while([mResultSet next]){
            NSLog(@"%d",[[mResultSet stringForColumn:@"nid"] intValue]);
            if([[mResultSet stringForColumn:@"nid"] intValue] == [[lArray1 objectForKey:@"Id"] intValue]){
                choose = 1;
                break;
            }
        }
    }
    //    NSLog(@"Count:%d",[mResultSet columnCount]);
    //    NSLog(@"Choose:%d",choose);
//    NSLog(@"Count:%d",[mResultSet columnCount]);
//    NSLog(@"Choose:%d",choose);
    if(choose == 1){
        cell.labelTitle.textColor = [UIColor grayColor];
        cell.labelDescription.textColor = [UIColor grayColor];
        cell.labelDateTime.textColor = [UIColor grayColor];
        cell.labelComments.textColor = [UIColor grayColor];
    }
    else{
        cell.labelTitle.textColor = [UIColor blackColor];
        cell.labelDescription.textColor = [UIColor blackColor];
        cell.labelDateTime.textColor = [UIColor blackColor];
        cell.labelComments.textColor = [UIColor blackColor];
    }
    cell.type.image  = [UIImage imageNamed:@"notification.png"];
    cell.labelDateTime.text = lDateTime;
    cell.labelComments.text = lComments;
    cell.labelTitle.text = lTitle;
    cell.labelDescription.text = lDescription;
    
    if([[lArray1 objectForKey:@"Comentarios"] intValue]){
        //        cell.labelComments.textColor = [UIColor blueColor];
        UIButton *lButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 85, 83, 21)];
        [lButton setBackgroundColor:[UIColor clearColor]];
        lButton.tag = indexPath.row;
        [lButton addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:lButton];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *lArray1 = [lArray objectAtIndex:indexPath.row];
    NSLog(@"The index is:%@",lArray1);
    
//    QueryManagerModel *lQuery = [QueryManagerModel getQueryManagerModel];
//    NSString *sqlQuery = [NSString stringWithFormat:INSERT_NOTIFI_ID,[lData objectForKey:@"kPrefKeyForUpdatedUsername"],[[lArray1 objectForKey:@"Id"] intValue]];
//    BOOL result = [lQuery executeQuery:sqlQuery];
//    NSLog(@"%hhd",result);
    
    
    [mAppDelegate setNotificationDetailVCAsWindowRootVCWithEventId:[[lArray1 objectForKey:@"Id"] intValue]];
}

- (void)call:(UIButton *)sender
{
    //    NSLog(@"%d",[sender tag]);
    NSDictionary *lArray1 = [lArray objectAtIndex:[sender tag]];
    //    NSLog(@"Notification view:%d,%d",[[lArray1 objectForKey:@"Id"] intValue],[sender tag]);
    [mAppDelegate setCommentsVCAsWindowRootVCWithEventId:[[lArray1 objectForKey:@"Id"] intValue] andNotificationTitle:[lArray1 objectForKey:@"Titulo"]];
}


@end
