//
//  PeopleViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 18/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "PeopleGroupViewController.h"
#import "StringID.h"
#import "MyAppAppDelegate.h"
#import "GroupsTableCell.h"
#import "SWTableViewCell.h"

#define DELETEGROUP_URL @"{\"Alias\":\"%@\",\"Id\":\"%@\"}"

MyAppAppDelegate *mAppDelegate;


@interface PeopleGroupViewController (){
    NSMutableArray *lGroupsArray;
    NSMutableDictionary *lGroupsDictionary;
    int option,index;
    NSString *deleteGroupName, *mGroupId;
}

@end

@implementation PeopleGroupViewController

- (void)loadGroupsTable{
    lGroupsArray = [[NSMutableArray alloc] initWithArray:[lGroupsDictionary objectForKey:@"groupsList"]];
    if([[lGroupsDictionary objectForKey:@"groupsCount"] intValue]<=0){
        [lTableView reloadData];
        lTableView.hidden = YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No tiene grupos creados, puede crear uno apretando “ + ”" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        [lTableView reloadData];
        lTableView.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    lTableView.hidden = YES;
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    [self addProgressIndicator];
    [self showProgressIndicator];
    mLabelLoading.text = @"Cargando...";
    [self performSelectorInBackground:@selector(callGetListGroupsWebservice) withObject:nil];
}

- (IBAction)BnAddGroupTapped:(id)sender{
    [mAppDelegate setAddGroupVCAsWindowRootVC];
    [self deallocMemory];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [lGroupsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    height = 60;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
    }
    
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    NSDictionary *lArray1 = [lGroupsArray objectAtIndex:indexPath.row];
    NSLog(@"%@",lArray1);
    cell.textLabel.text = [lArray1 objectForKey:@"Name"];// stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *lGroupDetails = [lGroupsArray objectAtIndex:indexPath.row];
    [mAppDelegate setPeopleViewController:[NSArray arrayWithObjects:[lGroupDetails objectForKey:@"Id"],[lGroupDetails objectForKey:@"Name"], nil]];
    [self deallocMemory];
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

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)indexCell
{
    switch (indexCell) {
        case 0:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [lTableView indexPathForCell:cell];
            NSDictionary *deleteCellDict = [lGroupsArray objectAtIndex:cellIndexPath.row];
            
            [self addProgressIndicator];
            [self showProgressIndicator];
            option = 1;
            index = (int)cellIndexPath.row;
            deleteGroupName = [deleteCellDict objectForKey:@"Name"];
            mGroupId = [deleteCellDict objectForKey:@"Id"];
            mLabelLoading.text = @"Borrando...";
            [self performSelectorInBackground:@selector(callDeleteGroupWebService) withObject:nil];
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


- (void)deallocMemory{
    lGroupsArray = nil;
    lGroupsDictionary = nil;
    deleteGroupName = nil;
}

- (void)callGetListGroupsWebservice{
    NSUserDefaults *lGetUserData = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@ListaGroup",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:@"{\"Alias\":\"%@\"}",[lGetUserData objectForKey:@"kPrefKeyForUpdatedUsername"]];
    
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
    if(returnString.length > 0){
        //            NSLog(@"Output: %@",returnString);
        //            returnString = [returnString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        //            returnString = [returnString substringToIndex:[returnString length] - 1];
        //            returnString = [returnString substringFromIndex:1];
        NSData* data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSLog(@"Response: %@",dict);
        NSError *error;
        NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@",lJSONArray);
        lGroupsDictionary = [[NSMutableDictionary alloc]initWithDictionary:lJSONArray];
        [self hideProgressIndicator];
        @try {
            if([[lGroupsDictionary objectForKey:@"responseMessage"] isEqualToString:@"Success"]){
                NSLog(@"%@",[lGroupsDictionary objectForKey:@"pendingInvitationsCount"]);
                if([[lGroupsDictionary objectForKey:@"pendingInvitationsCount"] intValue]>0){
                    NSUserDefaults *lSelectionData = [NSUserDefaults standardUserDefaults];
                    if([[lSelectionData objectForKey:@"kPrefKeyForOptionSelection"] intValue] == 0){
                        [mAppDelegate setPendingNotifiVCAsWindowRootVC:[lGroupsDictionary objectForKey:@"pendingInvitaitonsList"]];
                    }
                    else{
                        [self loadGroupsTable];
                    }
                }
                else{
                    [self loadGroupsTable];
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:deleteGroupName message:@"No es posible obtener datos." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
        }
        @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:deleteGroupName message:@"No es posible obtener datos." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        [self showNetworkError];
    }
}

- (void)callDeleteGroupWebService{
    NSUserDefaults *lGetUserData = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@EliminarGroup",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:DELETEGROUP_URL,[lGetUserData objectForKey:@"kPrefKeyForUpdatedUsername"],mGroupId];
    
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
            [self callGetListGroupsWebservice];
        }
        else{
            [lTableView reloadData];
//            SCLAlertView *alert = [[SCLAlertView alloc] init];
//            [alert addButton:@"Aceptar" actionBlock:^{
//                [lTableView reloadData];
//            }];
//            [alert showError:self title:deleteGroupName
//                    subTitle:@"Eliminado sin éxito"
//            closeButtonTitle:nil duration:0.0f];

        }
    }
    else{
        [self showNetworkError];
    }
}

@end
