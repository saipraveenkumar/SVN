//
//  PendingInvitViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 04/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "PendingInvitViewController.h"
#import "MyAppAppDelegate.h"
#import "PendingNotiTableViewCell.h"

MyAppAppDelegate *mAppAppDelegate;

@interface PendingInvitViewController ()

@end

@implementation PendingInvitViewController
- (void)setData:(NSArray *)notificationsPend{
    mNotificationsPending = notificationsPend;
    NSLog(@"Notifications Pending:\n\n%@",mNotificationsPending);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mAppAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    if((int)[mNotificationsPending count]>0){
        [lTableView reloadData];
    }
    else{
        lTableView.hidden = YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No invitaciones pendientes..!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    
    // Do any additional setup after loading the view.
}

- (IBAction)BnLoadGroups:(id)sender{
    NSUserDefaults *lSelection = [NSUserDefaults standardUserDefaults];
    [lSelection setValue:@"1" forKey:@"kPrefKeyForOptionSelection"];
    [mAppAppDelegate setGroupsListVCAsWindowRootVC];
    [self deallocMemory];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mNotificationsPending count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    height = 125;
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *MyIdentifier = @"tblCellView";
    PendingNotiTableViewCell *cell = (PendingNotiTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        NSArray * MyCustomCellNib;
        MyCustomCellNib = [[NSBundle mainBundle] loadNibNamed:@"PendingNotiTableViewCell" owner:self options:nil];
        cell = (PendingNotiTableViewCell *)[MyCustomCellNib lastObject];
        cell.backgroundColor = [UIColor clearColor];
    }
//    cell.labelGroup.text = @"test";
    NSDictionary *dict = [mNotificationsPending objectAtIndex:indexPath.row];
    cell.labelGroup.text = [dict objectForKey:@"Name"];
    cell.labelOwner.text = [dict objectForKey:@"OwnerName"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [mAppAppDelegate setPeopleAcceptInvitationVCWithDetails:[mNotificationsPending objectAtIndex:indexPath.row]];
    [self deallocMemory];
}

- (void)deallocMemory{
    mNotificationsPending = nil;
}

@end
