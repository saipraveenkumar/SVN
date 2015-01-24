//
//  HomeViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 05/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "HomeViewController.h"
#import "MyAppAppDelegate.h"
#import "UserDataModel.h"
#import "StringID.h"
#import "AddEventModel.h"
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GetNotificationListModel.h"
#import "CHTumblrMenuView.h"
#import "QueryManagerModel.h"
#import "FMResultSet.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SendLoc.h"

#define COUNT_NOTIFI @"select distinct nid from Notificaion where uid = '%@'"

MyAppAppDelegate *mAppDelegate;

@interface HomeViewController (){
    NSString *lLatitude,*lLongitude;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    int mCategoryId;
    EventAddParam *lEventAddParam;
    float latitude, longitude;
    NSString *eventName;
    //    int webServiceCall;
    NSArray *lArray;
    int locationCounter;
    NSUserDefaults *lUserData;
    NSMutableString *location;
    UIView *viewPhoto;
    UIImage *imgForEvent;
    NSString *imageName;
    UIActionSheet *actionSheetView;
    //    UIColor *blueColor;
}


@end

@implementation HomeViewController

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
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: ADD_EVENT_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: ADD_EVENT_FAILED object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_NOTIFICATIONS_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_NOTIFICATIONS_FAILED object: nil];
}

-(void) removeNotificationHandlers {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification {
    [self hideProgressIndicator];
}

-(void)onLoginFailed:(NSNotification*) lNotification{
    [self hideProgressIndicator];
    [self showNetworkError];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error{
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    lUserData = [NSUserDefaults standardUserDefaults];
    [lUserData setObject:@"0" forKey:@"kPrefKeyForCellIndex"];
    
    if(!locationManager)
        locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    
    locationCounter = 0;
    //    webServiceCall = -1;
    imageName = @"";
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    mCategoryId = 0;
    if(!lEventAddParam)
        lEventAddParam = [[EventAddParam alloc] init];
    
    [lblAlarms addTarget:self action:@selector(imageChanged:) forControlEvents:UIControlEventTouchDown];
    [lblFastEvents addTarget:self action:@selector(imageChanged:) forControlEvents:UIControlEventTouchDown];
    [lblPersonas addTarget:self action:@selector(imageChanged:) forControlEvents:UIControlEventTouchDown];
    [lblSOS addTarget:self action:@selector(imageChanged:) forControlEvents:UIControlEventTouchDown];
    [lblAlarms addTarget:self action:@selector(imageReturnBackPosition) forControlEvents:UIControlEventTouchCancel];
    
    //Checking with load data
    QueryManagerModel *lQuery = [QueryManagerModel getQueryManagerModel];
    NSString *sqlQuery = [NSString stringWithFormat:COUNT_NOTIFI,[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedUsername"]];
    
    FMResultSet *results = [lQuery getResultsFromDB:sqlQuery];
    int count = 0;
    while ([results next]) {
        NSLog(@"%d",[[results stringForColumn:@"nid"] intValue]);
        ++count;
    }
    
    lblUnreadNotifi.text = [NSString stringWithFormat:@"%d",[[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForNotificationCount"] intValue] - count];
    
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        NSLog(@"Not Determine.");
        [locationManager requestAlwaysAuthorization];
    }else {
        [self performSelectorInBackground:@selector(alertAboutLocation) withObject:nil];
    }
}

//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
//        NSLog(@"Allowed");
//    }
//    else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
//        NSLog(@"Denined");
//        [self alertLocationStatusDenined];
//    }
//}

- (void)alertLocationStatusDenined{
    [[[UIAlertView alloc]initWithTitle:@"Attention" message:@"For adding fastevents and alarms, you need to share your location." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil] show];
}

//- (void)alertAboutContacts{
//    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
//        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
//        //1
//        NSLog(@"Denied");
//    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
//        //2
//        NSLog(@"Authorized");
//    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
//        //3
//        NSLog(@"Not determined");
//    }
//}

- (void)alertAboutLocation{
    mAppDelegate.userLocSharing = YES;
    [mAppDelegate alertSharingLocation];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)imageReturnBackPosition{
    if(iPhone5){
        lblMenu.image = [UIImage imageNamed:@"i5_menu_off.png"];
    }
    else if (iPhone){
        lblMenu.image = [UIImage imageNamed:@"i4_off_screen.png"];
    }
}

- (void)imageChanged:(UIButton *)sender{
    if(sender.tag == 1){
        if(iPhone5){
            lblMenu.image = [UIImage imageNamed:@"i5_alarmas_on.png"];
        }
        else if (iPhone){
            lblMenu.image = [UIImage imageNamed:@"i4_alarma_on.png"];
        }
    }
    else if (sender.tag == 2){
        if(iPhone5){
            lblMenu.image = [UIImage imageNamed:@"i5_eventos_on.png"];
        }
        else if (iPhone){
            lblMenu.image = [UIImage imageNamed:@"i4_eventos_on.png"];
        }
    }
    else if (sender.tag == 3){
        if(iPhone5){
            lblMenu.image = [UIImage imageNamed:@"i5_personas_on.png"];
        }
        else if (iPhone){
            lblMenu.image = [UIImage imageNamed:@"i4_personas_on.png"];
        }
    }
    else if (sender.tag == 4){
        if(iPhone5){
            lblMenu.image = [UIImage imageNamed:@"i5_sos_on.png"];
        }
        else if (iPhone){
            lblMenu.image = [UIImage imageNamed:@"i4_sos_on.png"];
        }
    }
}

- (IBAction)BnAlarmTapped:(id)sender{
    [self.view setNeedsDisplay];
    NSUserDefaults *lSetCellIndex = [NSUserDefaults standardUserDefaults];
    [lSetCellIndex setObject:@"5" forKey:@"kPrefKeyForCellIndex"];
    [mAppDelegate setChooseAlarmViewController];
}

- (IBAction)BnSOSEventTapped:(id)sender{
    int check = [mAppDelegate alertSharingLocation];
    if(check == 0){
        mCategoryId = 68;
        eventName = @"S.O.S.";
        [self callEventChooseMethod:mCategoryId];
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
    [self imageReturnBackPosition];
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

- (IBAction)BnPeopleTapped:(id)sender{
    NSUserDefaults *lSetCellIndex = [NSUserDefaults standardUserDefaults];
    [lSetCellIndex setObject:@"6" forKey:@"kPrefKeyForCellIndex"];
    [mAppDelegate setGroupsListVCAsWindowRootVC];
}

- (IBAction)BnFastEventsTapped:(id)sender{
    int check = [mAppDelegate alertSharingLocation];
    if(check == 0){
        UIImage *obraImg, *sosphimg, *roboImg, *choqueImg;
        if(iPhone5){
            obraImg = [UIImage imageNamed:@"i5_obras_icon-57.png"];
            sosphimg = [UIImage imageNamed:@"i5_sospechoso_icon-57.png"];
            roboImg = [UIImage imageNamed:@"i5_robo_icon-57.png"];
            choqueImg = [UIImage imageNamed:@"i5_choque_icon-57.png"];
        }
        else if (iPhone){
            obraImg = [UIImage imageNamed:@"i4_obras_icon-57.png"];
            sosphimg = [UIImage imageNamed:@"i4_sospechoso_icon-57.png"];
            roboImg = [UIImage imageNamed:@"i4_robo_icon-57.png"];
            choqueImg = [UIImage imageNamed:@"i4_choque_icon-57.png"];
        }
        CHTumblrMenuView *menuView = [[CHTumblrMenuView alloc] init];
        [menuView addMenuItemWithTitle:@"Robo" andIcon:roboImg andSelectedBlock:^{
            mCategoryId = 70;
            eventName = @"Robo";
            [self callEventChooseMethod:mCategoryId];
        }];
        [menuView addMenuItemWithTitle:nil andIcon:nil andSelectedBlock:^{
        }];
        [menuView addMenuItemWithTitle:@"Choque" andIcon:choqueImg andSelectedBlock:^{
            mCategoryId = 71;
            eventName = @"Choque de Vehículos";
            [self callEventChooseMethod:mCategoryId];
        }];
        
        [menuView addMenuItemWithTitle:@"Sospechoso" andIcon:sosphimg andSelectedBlock:^{
            mCategoryId = 72;
            eventName = @"Persona Sospechosa";
            [self callEventChooseMethod:mCategoryId];
        }];
        
        [menuView addMenuItemWithTitle:nil andIcon:nil andSelectedBlock:^{
        }];
        
        [menuView addMenuItemWithTitle:@"Obra" andIcon:obraImg andSelectedBlock:^{
            mCategoryId = 73;
            eventName = @"Obra";
            [self callEventChooseMethod:mCategoryId];
        }];
        
        [menuView show];
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
    [self imageReturnBackPosition];
}

- (void)callEventChooseMethod:(int)eventid{
    //    webServiceCall = 0;
    if(eventid == 68){
        actionSheetView = [[UIActionSheet alloc] initWithTitle:@"¿ Desea enviar un S.O.S. ?"
                                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                             otherButtonTitles:@"Si", @"Sí, con foto", @"Cancelar", nil];
        actionSheetView.tag = 2;
        actionSheetView.actionSheetStyle = UIActionSheetStyleAutomatic;
        actionSheetView.destructiveButtonIndex = 2;
        [actionSheetView showInView:self.view];
    }
    else{
        actionSheetView = [[UIActionSheet alloc] initWithTitle:@"¿ Desea publicar un evento ?"
                                                      delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                             otherButtonTitles:@"Si", @"Sí, con foto", @"Cancelar", nil];
        actionSheetView.tag = 2;
        actionSheetView.actionSheetStyle = UIActionSheetStyleAutomatic;
        actionSheetView.destructiveButtonIndex = 2;
        [actionSheetView showInView:self.view];
    }
}

- (void)callPhotoMethod{
    actionSheetView = [[UIActionSheet alloc] initWithTitle:@"Elige una opción"
                                                  delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                         otherButtonTitles:@"Tomar una Foto con la Cámara", @"Elegir una Foto de la Galería", @"Cancelar", nil];
    actionSheetView.tag = 1;
    actionSheetView.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheetView.destructiveButtonIndex = 2;
    [actionSheetView showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 1){
        if (buttonIndex == 0){
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                imagePicker.allowsEditing = NO;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No existe Cámara." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
        }
        else if (buttonIndex == 1){
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
                imagePicker.allowsEditing = NO;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No hay imágenes en la Galería." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
        }
        else if (buttonIndex == 2){
            //NSLog(@"cancel");
        }
        [self imageReturnBackPosition];
    }
    else if (actionSheet.tag == 2){
        if (buttonIndex == 0){
            [self prepareWebserviceCall];
            [self imageReturnBackPosition];
        }
        else if (buttonIndex == 1){
            [self callPhotoMethod];
        }
        else if (buttonIndex == 2){
            [self imageReturnBackPosition];
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    UIImageWriteToSavedPhotosAlbum([info objectForKey:@"UIImagePickerControllerOriginalImage"], self,@selector(image:finishedSavingWithError:contextInfo:),nil);
    if([info objectForKey:@"UIImagePickerControllerOriginalImage"]){
        imgForEvent = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        imageName = [NSString stringWithFormat:@"ios%d.png",[self generateCurrentTimeStamp]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self addProgressIndicator];
    [self showProgressIndicator];
    mLabelLoading.text = @"Cargando...";
    //Service calls
    
    [self performSelector:@selector(callWebserviceWithPhoto) withObject:nil afterDelay:0.5];
}

- (void)callWebserviceWithPhoto{
    //    [viewPhoto removeFromSuperview];
    [self prepareWebserviceCall];
}

- (int)generateCurrentTimeStamp{
    int timestamp = [[NSDate date] timeIntervalSince1970];
    return timestamp;
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Guardar fracasó" message:@"Error al guardar la imagen / vídeo." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) callService{
    //    SendLoc *loc = [SendLoc getSendLoc];
    NSString *urlString = [NSString stringWithFormat:@"%@AgregarEvento",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:@"{\"alias\":\"%@\",\"contrasenia\":\"%@\",\"idCategoria\":\"%d\",\"nombre\":\"%@\",\"ubicacion\":\"%@\",\"fecha\":\"%@\",\"descripcion\":\"%@\",\"latitud\":\"%@\",\"longitud\":\"%@\",\"idBarrio\":\"%d\",\"Foto\":\"\%@\"}",lEventAddParam.userName,lEventAddParam.userPassword,lEventAddParam.categoryID,lEventAddParam.name,lEventAddParam.location,lEventAddParam.dateTime,lEventAddParam.description,lEventAddParam.latitude,lEventAddParam.longitude,lEventAddParam.barrioID,lEventAddParam.image];
    
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
    if([returnString length] == 0){
        [self showNetworkError];
    }
    else{
        returnString = [returnString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        returnString = [returnString substringToIndex:[returnString length] - 1];
        returnString = [returnString substringFromIndex:1];
        NSData* data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSLog(@"Response: %@",dict);
        NSError *error;
        NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        NSLog(@"final response for fast event:%d",[[lJSONArray objectForKey:@"Mensaje"] intValue]);
        
        int temp =[[lJSONArray objectForKey:@"Mensaje"] intValue];
        
        [self hideProgressIndicator];
        
        if(temp > 0){
            NSLog(@"\nEvent name:%@\nDate Time:%@\nDescription:%@\nImage:%@\nEvent id:%@",lEventAddParam.name,lEventAddParam.dateTime,lEventAddParam.description,lEventAddParam.image,[lJSONArray objectForKey:@"Mensaje"]);
            NSUserDefaults *lSetCellIndex = [NSUserDefaults standardUserDefaults];
            [lSetCellIndex setObject:@"1" forKey:@"kPrefKeyForCellIndex"];
            [mAppDelegate setShareEventVCAsWindowRootVC:lEventAddParam.name andDateTime:lEventAddParam.dateTime andDescription:lEventAddParam.description andImage:lEventAddParam.image andUrl:[lJSONArray objectForKey:@"Mensaje"]];
            lEventAddParam = nil;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alerta" message:@"Por favor, inténtelo otra vez." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        data = nil;
        lJSONArray = nil;
        myJSONData = nil;
        request = nil;
        body = nil;
        returnData = nil;
        returnString = nil;
    }
    //    [loc shareCurrentLocation];
}

- (IBAction)BnNotificationsTapped:(id)sender{
    NSUserDefaults *lSetCellIndex = [NSUserDefaults standardUserDefaults];
    [lSetCellIndex setObject:@"2" forKey:@"kPrefKeyForCellIndex"];
    [mAppDelegate setNotificationsVCAsWindowRootVC];
}

- (void) prepareWebserviceCall{
    SendLoc *loc = [SendLoc getSendLoc];
    //    [loc stopShareLocation];
    [self hideProgressIndicator];
    int mBarrioId;
    NSString *mDescription;
    mBarrioId = 1;
    mDescription = @"Este es un Evento Express enviado con la Aplicación eMaguén, este tipo de evento permite avisar rápidamente a tus amigos en Facebook que está pasando a tu alrededor.";
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"dd-MM-yyyy HH:mm:ss";
    lEventAddParam.userName = [lUserData objectForKey:@"kPrefKeyForUpdatedUsername"];
    lEventAddParam.userPassword = [lUserData objectForKey:@"kPrefKeyForUpdatedPassword"];
    lEventAddParam.dateTime = [format stringFromDate:[NSDate new]];
    lEventAddParam.categoryID  = mCategoryId;
    lEventAddParam.barrioID  = mBarrioId;
    lEventAddParam.name = eventName;
    lEventAddParam.location = loc.location;
    lEventAddParam.description = mDescription;
    lEventAddParam.latitude =[NSString stringWithFormat:@"%f",loc.lattitude];
    lEventAddParam.longitude =[NSString stringWithFormat:@"%f",loc.longitude];
    [self addProgressIndicator];
    [self showProgressIndicator];
    mLabelLoading.text = @"Agregando...";
    if(![imageName isEqualToString:@""]){
        NSString *urlString = [NSString stringWithFormat:@"http://emaguenwcfm3.cloudapp.net/JsonService.svc/UploadFile?fileName=%@",imageName];
        //http://emaguenwcfm3.cloudapp.net/JsonService.svc/UploadFile?
        //http://emaguenv2.cloudapp.net/JsonService.svc/PCUploadImage/fileName=%@
        //        NSString *urlString = [NSString stringWithFormat:@"http://emaguenv2.cloudapp.net/JsonService.svc/PCUploadImage"];
        NSLog(@"The final image name:%@",urlString);
        NSData *data = UIImageJPEGRepresentation(imgForEvent,1.0f);
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 250*1024;
        //            NSLog(@"%@",data);
        //            NSData *imageData = UIImageJPEGRepresentation(yourImage, compression);
        
        while ([data length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            data = UIImageJPEGRepresentation(imgForEvent, compression);
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        NSMutableData *body = [NSMutableData data];
        [body appendData:[NSData dataWithData:data]];
        [request setHTTPBody:body];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Ret: %@",returnString);
        NSData* data1 = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data1 options:kNilOptions error:&error];
        //    NSLog(@"Dict:%@",[lJSONArray objectForKey:@"UploadImageResult"]);
        lEventAddParam.image = [NSString stringWithFormat:@"%@",[lJSONArray objectForKey:@"UploadImageResult"]];
        
        //deallocing memory
        data = nil;
        request = nil;
        body = nil;
        returnData = nil;
        returnString = nil;
        data1 = nil;
        lJSONArray = nil;
    }
    else{
        lEventAddParam.image = @"";
    }
    [self performSelector:@selector(callService) withObject:nil afterDelay:1.0];
}

@end
