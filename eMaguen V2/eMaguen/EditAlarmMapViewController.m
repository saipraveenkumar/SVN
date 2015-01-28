//
//  EditAlarmMapViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 25/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "EditAlarmMapViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import "EventsViewController.h"
#import "AddAlarmModel.h"
#import "CountryNumberModel.h"
#import "SendLoc.h"

#define NO_CONTACT @"Sin Contacto"

MyAppAppDelegate *mAppDelegate;

@interface EditAlarmMapViewController (){
//    CLLocationManager *locationManager;
    int tempVar, countAnnotaions, temp, buttonTag;
    NSMutableArray *addedAnnotaionArray, *alarmNumbers;
    float anntLatt, anntLong;//currentLat, currentLong,
    NSArray *mAlaramDetails;
    ReverseGeocodeCountry *reverseGeocode;
    CountryNumberModel *lCountryNumber;
    BOOL isCountrynumber, isAssociatedAlarm;
    NSString *countryName, *countryNumber;
    int smsCount;
    UIAlertView *alertBox;
}

@end

@implementation EditAlarmMapViewController

- (void)setAlarmDetails:(NSArray *)alarmDetails{
    mAlaramDetails = alarmDetails;
    tempVar =0;
    countAnnotaions = 0;
    anntLatt = 999;
    anntLong = 999;
    temp = 0;
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
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_UPDATEALARM_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_UPDATEALARM_FAILED object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_COUNTRYNUMBER_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_COUNTRYNUMBER_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    NSLog(@"%@",lCountryNumber.countryNumber);
    
    if(isCountrynumber == YES){
        if([[lCountryNumber.countryNumber objectForKey:@"Response"] isEqualToString:@"Success"]){
            if((NSNull*)[lCountryNumber.countryNumber objectForKey:@"CountryCode"]!= [NSNull null]){
                NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
                [lData setObject:[lCountryNumber.countryNumber objectForKey:@"CountryCode"] forKey:@"kPrefKeyForCountryNumber"];
                
                countryNumber = [lCountryNumber.countryNumber objectForKey:@"CountryCode"];
                
                isCountrynumber = NO;
                
                AlarmParam *lAlarmParam = [[AlarmParam alloc]init];
                lAlarmParam.alarmName = [[mAlaramDetails objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                lAlarmParam.alarmNumber = [mAlaramDetails objectAtIndex:1];
                lAlarmParam.number1 = [mAlaramDetails objectAtIndex:4];
                lAlarmParam.number2 = [mAlaramDetails objectAtIndex:5];
                lAlarmParam.number3 = [mAlaramDetails objectAtIndex:6];
                lAlarmParam.number4 = [mAlaramDetails objectAtIndex:7];
                lAlarmParam.lattitude = [NSString stringWithFormat:@"%f",anntLatt];
                lAlarmParam.longitude = [NSString stringWithFormat:@"%f",anntLong];
                lAlarmParam.username = [mAlaramDetails objectAtIndex:9];
                lAlarmParam.userNumber = [mAlaramDetails objectAtIndex:10];
                lAlarmParam.ownerNumber = [mAlaramDetails objectAtIndex:11];
                [self addProgressIndicator];
                [self showProgressIndicator];
                AddAlarmModel *lAddAlarm = [AddAlarmModel getAddAlarmModel];
                [lAddAlarm callGetUpdateAlarmWebservice:lAlarmParam];
                mLabelLoading.text = @"Actualización de alarma";
                
                
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error de red." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error de red." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        AddAlarmModel *lAddAlarm = [AddAlarmModel getAddAlarmModel];
        if([lAddAlarm.alarmAdd isEqualToString:@"Successfully Added"]){
                if(![countryNumber isEqualToString:[mAlaramDetails objectAtIndex:4]]){
                    
                    NSArray *recipents = [NSArray arrayWithObject:[mAlaramDetails objectAtIndex:1]];//alarmSimNumber
                    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
                    NSString *message = [NSString stringWithFormat:@"TEL:\n1.%@\n2.%@\n3.%@\n4.%@\n5.%@",[lData objectForKey:@"kPrefKeyForCountryNumber"],[lData objectForKey:@"kPrefKeyForPhone"],(![[mAlaramDetails objectAtIndex:5] isEqualToString:NO_CONTACT]?[mAlaramDetails objectAtIndex:5]:@""),(![[mAlaramDetails objectAtIndex:6] isEqualToString:NO_CONTACT]?[mAlaramDetails objectAtIndex:6]:@""),(![[mAlaramDetails objectAtIndex:7] isEqualToString:NO_CONTACT]?[mAlaramDetails objectAtIndex:7]:@"")];
                    NSLog(@"\n%@",message);
                    smsCount = 0;
                    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                    messageController.messageComposeDelegate = self;
                    [messageController setRecipients:recipents];
                    [messageController setBody:message];
                    // Present message view controller on screen
                    [self presentViewController:messageController animated:YES completion:nil];
                }
                else{
                    [mAppDelegate setChooseAlarmViewController];
                }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No se agregó." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        if(smsCount == 1){
            [mAppDelegate setChooseAlarmViewController];
        }
    }
    else if (alertView.tag == 2){
        
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            if(smsCount == 1){
                [mAppDelegate setChooseAlarmViewController];
            }
            break;
            
        case MessageComposeResultFailed:
        {
            alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error al enviar SMS!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
            alertBox.tag = 1;
            [alertBox show];
        }
        case MessageComposeResultSent:
            if(smsCount == 1){
                [mAppDelegate setChooseAlarmViewController];
            }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if(smsCount == 0){
        NSArray *recipents = [NSArray arrayWithObject:[mAlaramDetails objectAtIndex:1]];//alarmSimNumber
        NSString *message = [NSString stringWithFormat:@"Zone information:\n1.eMaguen\n2.eMaguen\n3.eMaguen\n4."];
        NSLog(@"\n%@",message);
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipents];
        [messageController setBody:message];
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
        ++smsCount;
    }
}


-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    smsCount = 0;
    isAssociatedAlarm = NO;
    if(!reverseGeocode)
        reverseGeocode = [[ReverseGeocodeCountry alloc] init];
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    lMapViewTemp.delegate = self;
    
    isAssociatedAlarm = NO;
    if(!alarmNumbers)
        alarmNumbers = [[NSMutableArray alloc]init];
    for (int i = 5; i<=8; i++) {
        [alarmNumbers addObject:[mAlaramDetails objectAtIndex:i]];
    }
    for(NSString *str in alarmNumbers){
        NSLog(@"%@ == %@",str,[mAlaramDetails lastObject]);
        if(([str rangeOfString:[mAlaramDetails lastObject]].location != NSNotFound) || ([[mAlaramDetails lastObject] rangeOfString:str].location != NSNotFound) ){
            isAssociatedAlarm = YES;
            break;
        }
    }
    
    if(isAssociatedAlarm == YES){
        bnClear.hidden = YES;
        CLLocationCoordinate2D  tempCtrPoint;
        NSLog(@"%f,%f",[[mAlaramDetails objectAtIndex:2] floatValue],[[mAlaramDetails objectAtIndex:3] floatValue]);
        tempCtrPoint.latitude = [[mAlaramDetails objectAtIndex:2] floatValue];
        tempCtrPoint.longitude = [[mAlaramDetails objectAtIndex:3] floatValue];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,500,500);
        MKCoordinateRegion adjusted_region = [lMapViewTemp regionThatFits:region];
        [lMapViewTemp setRegion:adjusted_region animated:NO];
        lMapViewTemp.showsUserLocation = NO;
        
        CLLocationCoordinate2D  ctrpoint;
        
        ctrpoint.latitude = [[mAlaramDetails objectAtIndex:2] floatValue];
        ctrpoint.longitude = [[mAlaramDetails objectAtIndex:3] floatValue];
        AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
        addAnnotation.title = [mAlaramDetails objectAtIndex:0];
        //        NSLog(@"%@\t%@",lLatitude,lLongitude);
        //        NSLog(@"Tags:%d, annotation:%d",[lCategory intValue],addAnnotation.tag);
        if((addAnnotation.coordinate.latitude <= 90.0f) && (addAnnotation.coordinate.latitude >= -90.0f)&& (addAnnotation.coordinate.longitude <= 180.0f) && (addAnnotation.coordinate.longitude >= -180.0f))
            [lMapViewTemp addAnnotation:addAnnotation];
    }
    else if(isAssociatedAlarm == NO){
        if([mAppDelegate alertSharingLocation] == 0){
            lMapViewTemp.showsUserLocation = YES;
            SendLoc *loc = [SendLoc getSendLoc];
            CLLocationCoordinate2D  tempCtrPoint;
            tempCtrPoint.latitude = loc.lattitude;
            tempCtrPoint.longitude = loc.longitude;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,5,5);
            MKCoordinateRegion adjusted_region = [lMapViewTemp regionThatFits:region];
            [lMapViewTemp setRegion:adjusted_region animated:NO];
        }
//        if(!locationManager)
//            locationManager = [[CLLocationManager alloc] init];
//        locationManager.delegate = self;
//        locationManager.distanceFilter = kCLDistanceFilterNone;
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        
//        if(iPhone5){
//            if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//                [locationManager requestWhenInUseAuthorization];
//            }
//        }
//        [locationManager startUpdatingLocation];
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
        [lMapViewTemp addGestureRecognizer:lpgr];
        
        if(!addedAnnotaionArray)
            addedAnnotaionArray = [[NSMutableArray alloc]init];
    }
    lblUpdateButton.enabled = NO;
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint touchPoint = [gestureRecognizer locationInView:lMapViewTemp];
        CLLocationCoordinate2D touchMapCoordinate = [lMapViewTemp convertPoint:touchPoint toCoordinateFromView:lMapViewTemp];
        if(countAnnotaions == 0){
            AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:touchMapCoordinate];
            addAnnotation.title = @"Alarma cambiado";
            [addedAnnotaionArray addObject:addAnnotation];
            [lMapViewTemp addAnnotation:addAnnotation];
            lblUpdateButton.enabled = YES;
            //        [lMapView selectAnnotation:addAnnotation animated:YES];
            ++countAnnotaions;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ya punto añadido" message:@"Si usted quiere cambiar, Borrar y añadir de nuevo." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        [lMapViewTemp removeGestureRecognizer:lpgr];
        anntLatt = touchMapCoordinate.latitude;
        anntLong = touchMapCoordinate.longitude;
    }
}

- (IBAction)BnClearTapped:(id)sender{
    lblUpdateButton.enabled = NO;
    anntLatt = 999;
    anntLong = 999;
    countAnnotaions = 0;
    [lMapViewTemp removeAnnotations:addedAnnotaionArray];
    [addedAnnotaionArray removeAllObjects];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    [lMapViewTemp removeGestureRecognizer:lpgr];
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    //    NSLog(@"%@", [locations lastObject]);
//    CLLocation *newLocation = [locations lastObject];
//    currentLat = newLocation.coordinate.latitude;
//    currentLong = newLocation.coordinate.longitude;
//    if(temp == 0){
//        CLLocationCoordinate2D  tempCtrPoint;
//        tempCtrPoint.latitude = currentLat;
//        tempCtrPoint.longitude = currentLong;
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,500,500);
//        MKCoordinateRegion adjusted_region = [lMapViewTemp regionThatFits:region];
//        [lMapViewTemp setRegion:adjusted_region animated:NO];
//        ++temp;
//    }
//    
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(AddressAnnotation *)annotation
{
    if([annotation class] == MKUserLocation.class)
        return nil;
    
    NSString *pinIdentifier = [NSString stringWithFormat:@"%d",annotation.tag];
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
    
    if(annotationView == nil)
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
    else
        annotationView.annotation = annotation;
    
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = NO;
    annotationView.enabled = YES;
    
    //    if([annotation.title isEqualToString:@"Change Alarm"]){
    //        annotation.title = @"Alarma cambiado";
    annotationView.image = [UIImage imageNamed:@"pin_alarm_iphone4.png"];
    //    }
    //    else{
    //        annotationView.image = [UIImage imageNamed:@"currLoc.png"];
    //    }
    
    return annotationView;
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
}


- (IBAction)BnBackTapped:(id)sender{
    lMapViewTemp.delegate = nil;
    [mAppDelegate setEditAlarmVCWithAlarmNameNumber:mAlaramDetails];
}

- (IBAction)BnUpdateAlarmTapped:(id)sender{
    if(anntLatt == 999 && anntLong == 999){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Alarma ubicación no cambió" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        [self addProgressIndicator];
        [self showProgressIndicator];
        addedAnnotaionArray = nil;
        countryName = [reverseGeocode getCountry:anntLatt :anntLong];
        isCountrynumber = YES;
        if(!lCountryNumber)
            lCountryNumber = [CountryNumberModel getCountryNumberModel];
        [lCountryNumber callGetCountryNumberWebserviceWithMobileNo:[NSArray arrayWithObjects:countryName, [mAlaramDetails objectAtIndex:1],nil]];
        mLabelLoading.text = @"Validación...";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload{
    lMapViewTemp.delegate = nil;
    [lMapViewTemp removeFromSuperview];
}

@end
