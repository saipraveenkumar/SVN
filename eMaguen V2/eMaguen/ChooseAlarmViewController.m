//
//  ConfigAlarmViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 14/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ChooseAlarmViewController.h"
#import "StringID.h"
#import "MyAppAppDelegate.h"
#import "ListAlarmsModel.h"
#import "ConfigureAlarmViewController.h"
#import "DeleteAlarmModel.h"
#import "SWTableViewCell.h"

MyAppAppDelegate *mAppDelegate;

@interface ChooseAlarmViewController (){
    NSMutableArray *alarmArray;
    int option,index;
    NSString *deleteAlarmName, *deleteAlarmNumber;
}

@end

@implementation ChooseAlarmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
    }
    return self;
}

-(void) addNotificationHandlers {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_LIST_ALARM_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_LIST_ALARM_FAILED object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_DELETEALARM_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_DELETEALARM_FAILED object: nil];
}

-(void) removeNotificationHandlers {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification {
    if(option == 1){
        [self hideProgressIndicator];
        [alarmArray removeObjectAtIndex:index];
        [lTableView reloadData];
        DeleteAlarmModel *lDeleteAlarm = [DeleteAlarmModel getDeleteAlarmModel];
        if([lDeleteAlarm.alarmDelete isEqualToString:@"Success"]){
                    [mAppDelegate setChooseAlarmViewController];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[deleteAlarmName stringByRemovingPercentEncoding] message:@"Eliminado sin éxito" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        ListAlarmsModel *lAlarmList = [ListAlarmsModel getListAlarmModel];
        [alarmArray removeAllObjects];
        alarmArray = [[NSMutableArray alloc] initWithArray:lAlarmList.arrayAlarms];
        if([alarmArray count]<=0){
            [self hideProgressIndicator];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Para agregar una alarma debe apretar “+”" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        else{
            [self loadData];
            lTableView.hidden = NO;
        }
    }
}

-(void)onLoginFailed:(NSNotification*) lNotification{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void) loadData{
    ListAlarmsModel *lAlarmList = [ListAlarmsModel getListAlarmModel];
    alarmArray = [[NSMutableArray alloc] initWithArray:lAlarmList.arrayAlarms];
    NSLog(@"list alarams:\n\n\n%@",alarmArray);
    [lTableView reloadData];
    [self hideProgressIndicator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideProgressIndicator];
    lTableView.hidden = YES;
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
//    if(!lModel){
//        lModel = [AlarmDBModel getAlarmDBModel];
//    }
//    results = [lModel fetchAlarmNumbers];
    
    [self addProgressIndicator];
    [self showProgressIndicator];
    NSUserDefaults *lLocalData = [NSUserDefaults standardUserDefaults];
    NSLog(@"Mobile No:%@",[lLocalData valueForKey:@"kPrefKeyForPhone"]);
    ListAlarmsModel *lAlarmList = [ListAlarmsModel getListAlarmModel];
    [lAlarmList callGetListAlarmWebserviceWithMobileNo:[lLocalData valueForKey:@"kPrefKeyForPhone"]];
    mLabelLoading.text = @"Cargando...";

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [alarmArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    height = 65;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
    }
    
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];

    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSDictionary *lArray1 = [alarmArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [[lArray1 objectForKey:@"AlarmName"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *lArray1 = [alarmArray objectAtIndex:indexPath.row];
    [mAppDelegate setConfigureAlarmVCWithAlarmName:[NSArray arrayWithObjects:[lArray1 objectForKey:@"AlarmName"],[lArray1 objectForKey:@"AlarmPhoneNumber"],[lArray1 objectForKey:@"Lat"], [lArray1 objectForKey:@"Lang"],[lArray1 objectForKey:@"Number1"],[lArray1 objectForKey:@"Number2"],[lArray1 objectForKey:@"Number3"],[lArray1 objectForKey:@"Number4"],[lArray1 objectForKey:@"Number5"],[lArray1 objectForKey:@"UserName"],[lArray1 objectForKey:@"UserNumber"],nil]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    //    [rightUtilityButtons sw_addUtilityButtonWithColor:
    //     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
    //                                                title:@"Delete"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Borrar"];
    
    return rightUtilityButtons;
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Set background color of cell here if you don't want default white
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)indexCell
{
    switch (indexCell) {
        case 0:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [lTableView indexPathForCell:cell];
            NSDictionary *deleteCellDict = [alarmArray objectAtIndex:cellIndexPath.row];
            [self addProgressIndicator];
            [self showProgressIndicator];
            option = 1;
            index = (int)cellIndexPath.row;
            DeleteAlarmModel *lDeleteCell = [DeleteAlarmModel getDeleteAlarmModel];
            [lDeleteCell callGetAddAlarmWebservice:[NSArray arrayWithObjects:[deleteCellDict objectForKey:@"AlarmPhoneNumber"], [deleteCellDict objectForKey:@"UserNumber"], nil]];
            deleteAlarmName = [deleteCellDict objectForKey:@"AlarmName"];
            deleteAlarmNumber = [deleteCellDict objectForKey:@"AlarmPhoneNumber"];
            mLabelLoading.text = @"Borrando...";
            
//            [lTableView reloadData];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

- (IBAction)BnAddAlarmTapped:(id)sender{
    int check = [mAppDelegate alertSharingLocation];
    if(check == 0){
        [mAppDelegate setAddAlarmViewController];
    }
    else{
        NSString *alertMessage;
        NSString *alertOkButton;
        if(check == 1){
            alertMessage = @"Comparte tu ubicación";
            alertOkButton = @"Aceptar";
        }
        else if (check == 2){
            alertMessage = @"Activar servicios de ubicación";
            alertOkButton = @"Ajustes";
        }
        else if (check == 3){
            alertMessage = @"Set Location Service to allow.";
            alertOkButton = @"Ajustes";
        }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Attention" message:alertMessage delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:alertOkButton , nil];
        alert.tag = 100 + check;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 101){
        if(buttonIndex == 1){
            NSUserDefaults *lSetCellIndex = [NSUserDefaults standardUserDefaults];
            [lSetCellIndex setObject:@"3" forKey:@"kPrefKeyForCellIndex"];
            [mAppDelegate setProfileVCAsWindowRootVC];
        }
    }
    else if (alertView.tag == 102){
        if(buttonIndex == 1){
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
            }
            else{
                [[[UIAlertView alloc]initWithTitle:@"Attention" message:@"Turn on Location Services to perform any action.\nSettings -> Privacy -> Location Services (ON)" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil] show];
            }
        }
    }
    else if (alertView.tag == 103){
        if(buttonIndex == 1){
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
            }
            else{
                [[[UIAlertView alloc]initWithTitle:@"Attention" message:@"Turn on Location Services to perform any action.\nSettings -> Privacy -> Location Services (ON)" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil] show];
            }
        }
    }
}

@end
