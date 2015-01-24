//
//  LeftController.m
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LeftController.h"
#import "HomeViewController.h"
#import "SiderTableCell.h"
#import "DDMenuController.h"
#import "MyAppAppDelegate.h"
#import "RootViewController.h"
#import "UserDataModel.h"
#import "EventsViewController.h"
#import "NotificationsViewController.h"
#import "ProfileViewController.h"
#import "ContactViewController.h"
#import "SiderTableCelliPhone5.h"
#import "ChooseAlarmViewController.h"
#import "PeopleGroupViewController.h"
//#import "AddAlarmViewController.h"

static NSString *kPrefKeyForCellIndex                 = @"kPrefKeyForCellIndex";


BOOL iPad;
BOOL iPhone;
BOOL iPhone5;
NSUserDefaults *lCellDefaults;

MyAppAppDelegate *mAppDelegate;

@implementation LeftController{
    UIColor *blueColor;
}

@synthesize tableView=_tableView;

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    lCellDefaults  = [NSUserDefaults standardUserDefaults];
    
    iPad = NO;
    iPhone = NO;
    iPhone5 = NO;
    
    
    iPhone      = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 480.0;
    iPad        = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    iPhone5     = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0;
    
    blueColor = [self colorFromHexString:@"#2871b4"];
    
//    [self.view setBackgroundColor:[self colorFromHexString:@"#2871b4"]];
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = (id<UITableViewDelegate>)self;
        tableView.dataSource = (id<UITableViewDataSource>)self;
        [self.view addSubview:tableView];
        tableView.bounces = NO;
        tableView.scrollEnabled = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = blueColor;
        self.tableView = tableView;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
//    if (iPhone5) {
//        height = 58;
//    }
//    else if (iPhone){
        height = 48;
//    }
    return height;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SiderTableCell *cell;
//    SiderTableCelliPhone5 *cell1;
    static NSString *MyIdentifier = @"tblCellView";
//    if(iPhone5){
//        cell1 = (SiderTableCelliPhone5 *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
//        if (cell == nil) {
//            NSArray * MyCustomCellNib;
//            MyCustomCellNib = [[NSBundle mainBundle] loadNibNamed:@"SiderTableCelliPhone5" owner:self options:nil];
//            cell1 = (SiderTableCelliPhone5 *)[MyCustomCellNib lastObject];
//        }
//        //    cell.backgroundColor = [UIColor clearColor];
//        if(indexPath.row == 0){
//            cell1.eventName.text = [NSString stringWithFormat:@"INICIO"];
//            cell1.eventIcon.image = [UIImage imageNamed:@"i5_home_icon.png"];
//            cell1.eventSelect.backgroundColor = [UIColor whiteColor];
//            cell1.tag = 0;
//        }
//        else if(indexPath.row == 1){
//            cell1.eventName.text = [NSString stringWithFormat:@"EVENTOS"];
//            cell1.eventIcon.image = [UIImage imageNamed:@"i5_eventos_icon.png"];
//            cell1.tag = 1;
//        }
//        else if(indexPath.row == 2){
//            cell1.eventName.text = [NSString stringWithFormat:@"NOTIFICACIONES"];
//            cell1.eventIcon.image = [UIImage imageNamed:@"i5_notificaciones_icon.png"];
//            cell1.tag = 2;
//        }
//        else if(indexPath.row == 3){
//            cell1.eventName.text = [NSString stringWithFormat:@"PERFIL"];
//            cell1.eventIcon.image = [UIImage imageNamed:@"i5_perfil_icon.png"];
//            cell1.tag = 3;
//        }
//        else if(indexPath.row == 4){
//            cell1.eventName.text = [NSString stringWithFormat:@"NÚMEROS DE INTERES"];
//            cell1.eventIcon.image = [UIImage imageNamed:@"i5_numeros_de_interes_icon.png"];
//            cell1.tag = 4;
//        }
//        else if(indexPath.row == 5){
//            cell1.eventName.text = [NSString stringWithFormat:@"ALARMAS"];
//            cell1.eventIcon.image = [UIImage imageNamed:@"i5_alarmas_icon.png"];
//            cell1.tag = 5;
//        }
//        else if(indexPath.row == 6){
//            cell1.eventName.text = [NSString stringWithFormat:@"PERSONAS"];
//            cell1.eventIcon.image = [UIImage imageNamed:@"i5_personas_icon.png"];
//            cell1.tag = 6;
//        }
//        else if(indexPath.row == 7){
//            cell1.eventName.text = [NSString stringWithFormat:@"SALIR"];
//            cell1.eventIcon.image = [UIImage imageNamed:@"i5_salir_icon.png"];
//            cell1.tag = 7;
//            
//        }
////        cell1.eventIcon.contentMode = UIViewContentModeCenter;
//        cell1.eventIcon.contentMode = UIViewContentModeScaleAspectFit;
//        cell1.backgroundColor = blueColor;
//        cell1.selectionStyle = UITableViewCellEditingStyleNone;
//        cell1.eventSelect.hidden = YES;
//    }
//    else if (iPhone){
    cell = (SiderTableCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            NSArray * MyCustomCellNib;
            MyCustomCellNib = [[NSBundle mainBundle] loadNibNamed:@"SiderTableCell" owner:self options:nil];
            cell = (SiderTableCell *)[MyCustomCellNib lastObject];
        }
        //    cell.backgroundColor = [UIColor clearColor];
        if(indexPath.row == 0){
            cell.eventName.text = [[NSString stringWithFormat:@"INICIO"] capitalizedString];
//            if(iPhone5)
                cell.eventIcon.image = [UIImage imageNamed:@"i5_home_icon.png"];
//            else if(iPhone)
//                cell.eventIcon.image = [UIImage imageNamed:@"i4_home_icon.png"];
//            cell.eventSelect.backgroundColor = [UIColor whiteColor];
            cell.tag = 0;
        }
        else if(indexPath.row == 1){
            cell.eventName.text = [[NSString stringWithFormat:@"EVENTOS"] capitalizedString];
//            if(iPhone5)
                cell.eventIcon.image = [UIImage imageNamed:@"i5_eventos_icon.png"];
//            else if(iPhone)
//                cell.eventIcon.image = [UIImage imageNamed:@"i4_eventos_icon.png"];
            cell.tag = 1;
        }
        else if(indexPath.row == 2){
            cell.eventName.text = [[NSString stringWithFormat:@"NOTIFICACIONES"] capitalizedString];
//            if(iPhone5)
                cell.eventIcon.image = [UIImage imageNamed:@"i5_notificaciones_icon.png"];
//            else if(iPhone)
//                cell.eventIcon.image = [UIImage imageNamed:@"i4_notificaciones_icon.png"];
            cell.tag = 2;
        }
        else if(indexPath.row == 3){
            cell.eventName.text = [[NSString stringWithFormat:@"MI CONFIGURACIÓN"] capitalizedString];
//            if(iPhone5)
                cell.eventIcon.image = [UIImage imageNamed:@"i5_perfil_icon.png"];
//            else if(iPhone)
//                cell.eventIcon.image = [UIImage imageNamed:@"i4_perfil_icon.png"];
            cell.tag = 3;
        }
        else if(indexPath.row == 4){
            cell.eventName.text = [[NSString stringWithFormat:@"NÚMEROS DE INTERES"] capitalizedString];
//            if(iPhone5)
                cell.eventIcon.image = [UIImage imageNamed:@"i5_numeros_de_interes_icon.png"];
//            else if(iPhone)
//                cell.eventIcon.image = [UIImage imageNamed:@"i4_numeros_de_interes_icon.png"];
            cell.tag = 4;
        }
        else if(indexPath.row == 5){
            cell.eventName.text = [[NSString stringWithFormat:@"ALARMAS"] capitalizedString];
//            if(iPhone5)
                cell.eventIcon.image = [UIImage imageNamed:@"i5_alarmas_icon.png"];
//            else if(iPhone)
//                cell.eventIcon.image = [UIImage imageNamed:@"i4_alarmas_icon.png"];
            cell.tag = 5;
        }
        else if(indexPath.row == 6){
            NSUserDefaults *lSelection = [NSUserDefaults standardUserDefaults];
            [lSelection setValue:@"0" forKey:@"kPrefKeyForOptionSelection"];
            cell.eventName.text = [[NSString stringWithFormat:@"PERSONAS"] capitalizedString];
//            if(iPhone5)
                cell.eventIcon.image = [UIImage imageNamed:@"i5_personas_icon.png"];
//            else if(iPhone)
//                cell.eventIcon.image = [UIImage imageNamed:@"i4_personas_icon.png"];
            cell.tag = 6;
        }
        else if(indexPath.row == 7){
            cell.eventName.text = [[NSString stringWithFormat:@"SALIR"] capitalizedString];
//            if(iPhone5)
                cell.eventIcon.image = [UIImage imageNamed:@"i5_salir_icon.png"];
//            else if(iPhone)
//                cell.eventIcon.image = [UIImage imageNamed:@"i4_salir_icon.png"];
            cell.tag = 7;
        }
    if((int)indexPath.row == [[lCellDefaults objectForKey:@"kPrefKeyForCellIndex"] intValue]){
        cell.eventSelect.backgroundColor = [UIColor whiteColor];
    }
        cell.eventIcon.contentMode = UIViewContentModeCenter;
        cell.eventIcon.contentMode = UIViewContentModeScaleAspectFit;
        cell.backgroundColor = blueColor;
        cell.selectionStyle = UITableViewCellEditingStyleNone;
//        cell.eventSelect.hidden = YES;
//    }
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    return cell;//iPhone5 == 1?cell1:
}

//- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"eMaguen";
//}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [lCellDefaults setObject:[NSString stringWithFormat:@"%d",(int)indexPath.row] forKey:@"kPrefKeyForCellIndex"];
    
    
//    SiderTableCelliPhone5 *cell1 = (SiderTableCelliPhone5 *)[tableView cellForRowAtIndexPath:indexPath];
//    SiderTableCell *cell = (SiderTableCell *)[tableView cellForRowAtIndexPath:indexPath];
//    cell.tag = (int)indexPath.row;
//    if(iPhone5){
//        for(SiderTableCelliPhone5 *cellTemp in [tableView visibleCells]){
////            NSLog(@"%d = %d",cellTemp.tag,cell.tag);
//            cellTemp.eventSelect.backgroundColor = [UIColor clearColor];
//        }
//    }
//    else if(iPhone){
        for(SiderTableCell *cellTemp in [tableView visibleCells]){
//            NSLog(@"%d = %d",cellTemp.tag,cell.tag);
            cellTemp.eventSelect.backgroundColor = [UIColor clearColor];
        }
//    }
//    if (iPhone5) {
//        SiderTableCelliPhone5 *cell5 = (SiderTableCelliPhone5 *)[tableView cellForRowAtIndexPath:indexPath];
//        cell5.eventSelect.backgroundColor = [UIColor whiteColor];
//    }
//    else if(iPhone){
        SiderTableCell *cell4 = (SiderTableCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell4.eventSelect.backgroundColor = [UIColor whiteColor];
//    }
    
    if(indexPath.row == 0){
        HomeViewController* mainController;
        if(iPhone5){
            mainController= [[HomeViewController alloc] initWithNibName:@"HomeViewController_iPhone5" bundle:nil];
        } else if (iPhone) {
            mainController= [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        }
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
        // set the root controller
        DDMenuController *menuController = (DDMenuController*)((MyAppAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
        [menuController setRootController:navController animated:YES];
        
        mainController = nil;
        navController = nil;
        menuController = nil;
    }
    else if(indexPath.row == 1){
        EventsViewController* mainController;
        if(iPhone5){
            mainController= [[EventsViewController alloc] initWithNibName:@"EventsViewController_iPhone5" bundle:nil];
        } else if (iPhone) {
            mainController= [[EventsViewController alloc] initWithNibName:@"EventsViewController" bundle:nil];
        }
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
        // set the root controller
        DDMenuController *menuController = (DDMenuController*)((MyAppAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
        [menuController setRootController:navController animated:YES];
        
        mainController = nil;
        navController = nil;
        menuController = nil;
    }
    else if(indexPath.row == 2){
        NotificationsViewController* mainController;
        if(iPhone5){
            mainController= [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController_iPhone5" bundle:nil];
        } else if (iPhone) {
            mainController= [[NotificationsViewController alloc] initWithNibName:@"NotificationsViewController" bundle:nil];
        }
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
        // set the root controller
        DDMenuController *menuController = (DDMenuController*)((MyAppAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
        [menuController setRootController:navController animated:YES];
        
        mainController = nil;
        navController = nil;
        menuController = nil;
    }
    else if(indexPath.row == 3){
        ProfileViewController* mainController;
        if(iPhone5){
            mainController= [[ProfileViewController alloc] initWithNibName:@"ProfileViewController_iPhone5" bundle:nil];
        } else if (iPhone) {
            mainController= [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
        }
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
        // set the root controller
        DDMenuController *menuController = (DDMenuController*)((MyAppAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
        [menuController setRootController:navController animated:YES];
        
        mainController = nil;
        navController = nil;
        menuController = nil;
    }
    else if(indexPath.row == 4){
        ContactViewController* mainController;
        if(iPhone5){
            mainController= [[ContactViewController alloc] initWithNibName:@"ContactViewController_iPhone5" bundle:nil];
        } else if (iPhone) {
            mainController= [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil];
        }
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
        // set the root controller
        DDMenuController *menuController = (DDMenuController*)((MyAppAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
        [menuController setRootController:navController animated:YES];
        
        mainController = nil;
        navController = nil;
        menuController = nil;
    }
    else if(indexPath.row == 5){
        ChooseAlarmViewController* mainController;
        if(iPhone5){
            mainController= [[ChooseAlarmViewController alloc] initWithNibName:@"ChooseAlarmViewController_iPhone5" bundle:nil];
        } else if (iPhone) {
            mainController= [[ChooseAlarmViewController alloc] initWithNibName:@"ChooseAlarmViewController" bundle:nil];
        }
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
        // set the root controller
        DDMenuController *menuController = (DDMenuController*)((MyAppAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
        [menuController setRootController:navController animated:YES];
        
        mainController = nil;
        navController = nil;
        menuController = nil;
    }
    else if(indexPath.row == 6){
        PeopleGroupViewController* mainController;
        if(iPhone5){
            mainController= [[PeopleGroupViewController alloc] initWithNibName:@"PeopleGroupViewController_iPhone5" bundle:nil];
        } else if (iPhone) {
            mainController= [[PeopleGroupViewController alloc] initWithNibName:@"PeopleGroupViewController" bundle:nil];
        }
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
        // set the root controller
        DDMenuController *menuController = (DDMenuController*)((MyAppAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
        [menuController setRootController:navController animated:YES];
        
        mainController = nil;
        navController = nil;
        menuController = nil;
    }
    else if(indexPath.row == 7){
        [FBSession.activeSession closeAndClearTokenInformation];
        UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
        [lUserDataModel logoutUser];
        NSUserDefaults *lUserData = [NSUserDefaults standardUserDefaults];
        [lUserData setValue:@"0" forKey:@"kPrefKeyForUserLogin"];
        if(iPhone5)
            [lUserData setObject:@"i5_menu_off.png" forKey:@"kPrefKeyForHomeScreen"];
        else if(iPhone)
            [lUserData setObject:@"i4_off_screen.png" forKey:@"kPrefKeyForHomeScreen"];
        [mAppDelegate setLoginVCAsWindowRootVC];
        mAppDelegate.userLocSharing = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}



@end
