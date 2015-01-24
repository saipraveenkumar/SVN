//
//  EventsViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 12/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "EventsViewController.h"
#import <MapKit/MapKit.h>
#import "StringID.h"
#import "MyAppAppDelegate.h"
#import "GetEventsModel.h"
#import <MapKit/MKAnnotation.h>
#import "UserDataModel.h"
#import "SendLoc.h"

MyAppAppDelegate *mAppDelegate;


@interface EventsViewController (){
    NSMutableArray *lArray;
    int filter;
    //    CLLocationManager *locationManager;
    //    float currentLatitude, currentLongitude;//, anntLatt, anntLong;;
    int rngCrtLoc, count, temp;
    UIActivityIndicatorView *ldngData;
    UIColor *blueColor;
    SendLoc *loc;
    NSUserDefaults *lData;
    //    NSMutableArray *arrayAddressAnno;
}

@end

@implementation EventsViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        rngCrtLoc = 5000;
        count = 0;
        temp = 0;
        [self addNotificationHandlers];
        [self addProgressIndicator];
        [self showProgressIndicator];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_EVENTS_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_EVENTS_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    //[self loadData];
    [self myEvents:nil];
    [self performSelector:@selector(hideProgressIndicator) withObject:nil afterDelay:5.0];
    
}
-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void) removeBackgroundImage{
    
    [lButton1 setBackgroundImage:nil forState:UIControlStateNormal];
    [lButton2 setBackgroundImage:nil forState:UIControlStateNormal];
    [lButton3 setBackgroundImage:nil forState:UIControlStateNormal];
    blueColor = [self colorFromHexString:@"#2871b4"];
    [lButton1 setTitleColor:blueColor forState:UIControlStateNormal];
    [lButton2 setTitleColor:blueColor forState:UIControlStateNormal];
    [lButton3 setTitleColor:blueColor forState:UIControlStateNormal];
}

- (IBAction)myEvents:(id)sender{
    //    [self showProgressIndicator];
    [self removeBackgroundImage];
    //    UIImage *bgImage = [UIImage imageNamed:@"bg_button.png"];
    if(iPhone5)
        topMenuImgV.image = [UIImage imageNamed:@"i5_menu_eventos1.png"];
    else if(iPhone)
        topMenuImgV.image = [UIImage imageNamed:@"i4_menu_eventos1.png"];
    
    [lButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [lButton2 setTitleColor:blueColor forState:UIControlStateNormal];
    [lButton3 setTitleColor:blueColor forState:UIControlStateNormal];
    
    filter = 1;
    [self loadData];
}

- (IBAction)nearMe:(id)sender{
    //    [self showProgressIndicator];
    int check = [mAppDelegate alertSharingLocation];
    if(check == 0){
        [self removeBackgroundImage];
        if(iPhone5)
            topMenuImgV.image = [UIImage imageNamed:@"i5_menu_eventos2.png"];
        else if(iPhone)
            topMenuImgV.image = [UIImage imageNamed:@"i4_menu_eventos2.png"];
        
        [lButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [lButton1 setTitleColor:blueColor forState:UIControlStateNormal];
        [lButton3 setTitleColor:blueColor forState:UIControlStateNormal];
        
        filter = 2;
        [self loadData];
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
            if([CLLocationManager locationServicesEnabled]){
                NSUserDefaults *lSetCellIndex = [NSUserDefaults standardUserDefaults];
                [lSetCellIndex setObject:@"3" forKey:@"kPrefKeyForCellIndex"];
                [mAppDelegate setProfileVCAsWindowRootVC];
            }
            else{
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                    [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
                }
                else{
                    [[[UIAlertView alloc]initWithTitle:@"Attention" message:@"Turn on Location Services to perform any action.\nSettings -> Privacy -> Location Services (ON)" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil] show];
                }
            }
        }
    }
}

- (IBAction)allEvents:(id)sender{
    //    [self showProgressIndicator];
    [self removeBackgroundImage];
    
    if(iPhone5)
        topMenuImgV.image = [UIImage imageNamed:@"i5_menu_eventos3.png"];
    else if(iPhone)
        topMenuImgV.image = [UIImage imageNamed:@"i4_menu_eventos3.png"];
    
    [lButton3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [lButton2 setTitleColor:blueColor forState:UIControlStateNormal];
    [lButton1 setTitleColor:blueColor forState:UIControlStateNormal];
    
    
    filter = 3;
    [self loadData];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


- (void) loadData{
    if(!loc)
        loc = [SendLoc getSendLoc];
    CLLocationCoordinate2D  tempCtrPoint;//new
    GetEventsModel *lGetEventsModel = [GetEventsModel getGetEventsModel];
//    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    
    [lMapView removeAnnotations:lMapView.annotations];
    [lArray removeAllObjects];
    
    if(filter == 1){
        for (int i = 0; i < [lGetEventsModel.arrayEvents count]; i++){
            NSDictionary *lArray1 = [lGetEventsModel.arrayEvents objectAtIndex:i];
//            NSString *lName = [NSString stringWithFormat:@"%@",[lArray1 objectForKey:@"CoPropietario"]];
            if([[lArray1 objectForKey:@"CoPropietario"] intValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForCoId"] intValue]){
                [lArray addObject:lArray1];
            }
        }
    }
    else if(filter == 2){
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:loc.lattitude longitude:loc.longitude];
        
        for (int i = 0; i < [lGetEventsModel.arrayEvents count]; i++){
            NSDictionary *lArray1 = [lGetEventsModel.arrayEvents objectAtIndex:i];
            NSString *lLatitude = [lArray1 objectForKey:@"Latitud"];
            NSString *lLongitude = [lArray1 objectForKey:@"Longitud"];
            CLLocation *locB = [[CLLocation alloc] initWithLatitude:[lLatitude floatValue] longitude:[lLongitude floatValue]];
            CLLocationDistance distance = [locA distanceFromLocation:locB];
            if(distance < 5000){
                [lArray addObject:lArray1];
            }
        }
    }
    else if(filter == 3){
        [lArray addObjectsFromArray:lGetEventsModel.arrayEvents];
    }
    for( int i = 0; i < [lArray count]; i++){
        NSDictionary *lArray1 = [lArray objectAtIndex:i];
        //        NSLog(@"%@\t%@",[lArray1 objectForKey:@"Latitud"],[lArray1 objectForKey:@"Longitud"]);
        //        if([[lArray1 objectForKey:@"Longitud"] floatValue]<=90 && [[lArray1 objectForKey:@"Longitud"]intValue]<=90 && [[lArray1 objectForKey:@"Longitud"] intValue]>=-90 && [[lArray1 objectForKey:@"Longitud"]intValue]>=-90){
        NSString *lLatitude = [lArray1 objectForKey:@"Latitud"];
        NSString *lLongitude = [lArray1 objectForKey:@"Longitud"];
        NSString *lLocation = [lArray1 objectForKey:@"Ubicacion"];
        NSString *lDescription = [lArray1 objectForKey:@"Descripcion"];
        NSString *lCategory = [lArray1 objectForKey:@"Categoria"];
        
        CLLocationCoordinate2D  ctrpoint;
        
        ctrpoint.latitude = [lLatitude floatValue];
        ctrpoint.longitude =[lLongitude floatValue];
        AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
        addAnnotation.title = lLocation;
        addAnnotation.subTitle = lDescription;
        addAnnotation.tag = [lCategory intValue];
        //        NSLog(@"%@\t%@",lLatitude,lLongitude);
        //        NSLog(@"Tags:%d, annotation:%d",[lCategory intValue],addAnnotation.tag);
        if((addAnnotation.coordinate.latitude <= 90.0f) && (addAnnotation.coordinate.latitude >= -90.0f)&& (addAnnotation.coordinate.longitude <= 180.0f) && (addAnnotation.coordinate.longitude >= -180.0f))
            [lMapView addAnnotation:addAnnotation];
        //        else
        //            NSLog(@"%@",lArray1);
        //        [self updateAnnotationImage:addAnnotation];
        //        }
    }
    tempCtrPoint.latitude = loc.lattitude;
    tempCtrPoint.longitude = loc.longitude;
    if([mAppDelegate alertSharingLocation] == 0){
        lMapView.showsUserLocation = YES;
        if(count == 0 || filter == 2){
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,rngCrtLoc,rngCrtLoc);
            MKCoordinateRegion adjusted_region = [lMapView regionThatFits:region];
            [lMapView setRegion:adjusted_region animated:YES];
            ++count;
        }
    }
    lMapView.delegate = self;
    //[self hideProgressIndicator];
}

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
    
    if(annotation.tag == 68){
        annotationView.image = [UIImage imageNamed:@"pin_SOS.png"];
    }
    else if(annotation.tag == 70){
        annotationView.image = [UIImage imageNamed:@"pin_Robo.png"];
    }
    else if(annotation.tag == 71){
        annotationView.image = [UIImage imageNamed:@"pin_Choque.png"];
    }
    else if(annotation.tag == 72){
        annotationView.image = [UIImage imageNamed:@"pin_Sospechoso.png"];
    }
    else if(annotation.tag == 73){
        annotationView.image = [UIImage imageNamed:@"pin_obra.png"];
    }
    else{
        annotationView.image = [UIImage imageNamed:@"Generico.png"];
    }
    
    
    return annotationView;
}


- (IBAction)BnAddEvent:(id)sender{
    [mAppDelegate setAddEventVCAsWindowRootVC];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    lData = [NSUserDefaults standardUserDefaults];
    
    flagComments = 0;
    commCount = 0;
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    //    lMapView.scrollEnabled = NO;
    //    lMapView.zoomEnabled = NO;
    lMapView.rotateEnabled = NO;
    //    lMapView.showsBuildings = YES;
    
    GetEventsModel *lGetEventsModel = [GetEventsModel getGetEventsModel];
    [lGetEventsModel callGetEventsWebservice];
    mLabelLoading.text = @"Buscando...";
    filter = 1;
    
    
    //    locationManager = [[CLLocationManager alloc] init];
    //    locationManager.delegate = self;
    //    locationManager.distanceFilter = kCLDistanceFilterNone;
    //    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //
    //
    //    if(iPhone5){
    //        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
    //            [locationManager requestWhenInUseAuthorization];
    //        }
    //    }
    //    [locationManager startUpdatingLocation];
    
    
    [lButton2 setTitleColor:blueColor forState:UIControlStateHighlighted];
    [lButton3 setTitleColor:blueColor forState:UIControlStateHighlighted];
    [lButton1 setTitleColor:blueColor forState:UIControlStateHighlighted];
    
    
    lArray = [[NSMutableArray alloc] init];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [lMapView selectAnnotation:[view annotation] animated:YES];
    int i;
    
    for(i = 0; i<[lArray count]; i++){
        if([[NSString stringWithFormat:@"%f",[[view annotation] coordinate].latitude] isEqualToString:[NSString stringWithFormat:@"%f",[[[lArray objectAtIndex:i] objectForKey:@"Latitud"] floatValue]]]){
            if([[NSString stringWithFormat:@"%f",[[view annotation] coordinate].longitude] isEqualToString:[NSString stringWithFormat:@"%f",[[[lArray objectAtIndex:i] objectForKey:@"Longitud"] floatValue]]]){
                NSLog(@"The details are:%@",[lArray objectAtIndex:i]);
                NSDictionary *lArray1 = [lArray objectAtIndex:i];
                NSString *eventId = [lArray1 objectForKey:@"Id"];
                NSLog(@"The event id:%@",eventId);
                
                [mAppDelegate ShowEventDetailsVCAsWindowRootVC:eventId];
            }
        }
        else{
            //                        NSLog(@"Bye");
        }
    }
}

@end



@implementation AddressAnnotation

@synthesize coordinate;
@synthesize title = mTitle;
@synthesize subTitle = mSubTitle;
@synthesize tag = mTag;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    //    NSLog(@"%f,%f",c.latitude,c.longitude);
    return self;
}

@end
