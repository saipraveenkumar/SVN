//
//  AddEventViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 13/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "AddEventViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
//#import <MapKit/MapKit.h>
#import "EventsViewController.h"
#import "AddEventModel.h"
#import "SendLoc.h"

MyAppAppDelegate *mAppDelegate;


@interface AddEventViewController ()
{
    
    NSString *lLatitude,*lLongitude;
//    CLLocationManager *locationManager;
    int rngCrtLoc, tempVar, countAnnotaions, temp;
    NSMutableArray *addedAnnotaionArray;
    
    float currentLat, currentLong, anntLatt, anntLong;

}

@end

@implementation AddEventViewController
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self)
//    {
//        tempVar =0;
//        countAnnotaions = 0;
//        rngCrtLoc = 5;
//        anntLatt = -999999;
//        anntLong = -999999;
//        temp = 0;
//        [self addNotificationHandlers];
//        [self addProgressIndicator];
//        [self hideProgressIndicator];
//    }
//    return self;
//}

//-(void) addNotificationHandlers
//{
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: ADD_EVENT_FINISHED object: nil];
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: ADD_EVENT_FAILED object: nil];
//}

//-(void) removeNotificationHandlers
//{
//    [[NSNotificationCenter defaultCenter] removeObserver: self];
//}
//
//-(void)onLoginFinish:(NSNotification*) lNotification
//{
//    [self hideProgressIndicator];
////    [mAppDelegate setShareEventVCAsWindowRootVC:sndDtlsToShare];
//
//}
//-(void)onLoginFailed:(NSNotification*) lNotification
//{
//    [self hideProgressIndicator];
//    [self showNetworkError];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self showProgressIndicator];
    tempVar =0;
    countAnnotaions = 0;
    rngCrtLoc = 5;
    anntLatt = -999999;
    anntLong = -999999;
    temp = 0;
    
    lblAddCoordinates.enabled = NO;
    
    if([mAppDelegate alertSharingLocation] == 0){
        lMapView.showsUserLocation = YES;
        SendLoc *loc = [SendLoc getSendLoc];
        CLLocationCoordinate2D  tempCtrPoint;
        tempCtrPoint.latitude = loc.lattitude;
        tempCtrPoint.longitude = loc.longitude;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,5,5);
        MKCoordinateRegion adjusted_region = [lMapView regionThatFits:region];
        [lMapView setRegion:adjusted_region animated:NO];
    }
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
    [lMapView addGestureRecognizer:lpgr];
    
    addedAnnotaionArray = [[NSMutableArray alloc]init];    
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

-(IBAction)BnAddCoordinates:(id)sender{
    if(anntLatt != -999999 && anntLong != -999999){
    [mAppDelegate setAddEventDetailsVCAsWindowRootVC:anntLatt and:anntLong];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Seleccione el lugar / Coordenadas del evento." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint touchPoint = [gestureRecognizer locationInView:lMapView];
        CLLocationCoordinate2D touchMapCoordinate = [lMapView convertPoint:touchPoint toCoordinateFromView:lMapView];
        if(countAnnotaions == 0){
        AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:touchMapCoordinate];
            addAnnotation.title = @"Adding Event";
        [addedAnnotaionArray addObject:addAnnotation];
        [lMapView addAnnotation:addAnnotation];
            lblAddCoordinates.enabled = YES;
//        [lMapView selectAnnotation:addAnnotation animated:YES];
            ++countAnnotaions;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ya punto añadido" message:@"Si usted quiere cambiar, Borrar y añadir de nuevo." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        [lMapView removeGestureRecognizer:lpgr];
        anntLatt = touchMapCoordinate.latitude;
        anntLong = touchMapCoordinate.longitude;
//        NSLog(@"Annatation Latt and Long:%f,%f",anntLatt,anntLong);
    }
}

//- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer{
////    [self BnClearTapped];
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
////        return;
//    CGPoint touchPoint = [gestureRecognizer locationInView:lMapView];
//    CLLocationCoordinate2D touchMapCoordinate = [lMapView convertPoint:touchPoint toCoordinateFromView:lMapView];
//    AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:touchMapCoordinate];
//    [lMapView addAnnotation:addAnnotation];
//    [addedAnnotaionArray addObject:addAnnotation];
//    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
//    [lMapView removeGestureRecognizer:lpgr];
//    anntLatt = touchMapCoordinate.latitude;
//    anntLong = touchMapCoordinate.longitude;
//        NSLog(@"Annatation Latt and Long:%f,%f",anntLatt,anntLong);
//    }
////        UIAlertView* alertBack = [[UIAlertView alloc]initWithTitle:@"Ya marcada en el mapa" message:@"Si usted desea cambiar, pulse el botón claro y marcar de nuevo." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
////            [alertBack show];
//}

   
-(IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setEventsVCAsWindowRootVC];
}

//// Location Manager Delegate Methods
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
////    NSLog(@"%@", [locations lastObject]);
//    CLLocation *newLocation = [locations lastObject];
//    currentLat = newLocation.coordinate.latitude;
//    currentLong = newLocation.coordinate.longitude;
//    if(temp == 0){
//    CLLocationCoordinate2D  tempCtrPoint;
//    tempCtrPoint.latitude = currentLat;
//    tempCtrPoint.longitude = currentLong;
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,rngCrtLoc,rngCrtLoc);
//    MKCoordinateRegion adjusted_region = [lMapView regionThatFits:region];
//    [lMapView setRegion:adjusted_region animated:NO];
//        ++temp;
//    }
//    
//}

//- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(AddressAnnotation*) annotation{
//    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
//    annView.pinColor = MKPinAnnotationColorRed;
//    annView.animatesDrop=FALSE;
//    annView.canShowCallout = YES;
//    if([annotation.title isEqualToString:@"Add Event"]){
//    annView.image = [UIImage imageNamed:@"addEvent.png"];
//    }
//    else{
//        annView.image = [UIImage imageNamed:@"currLoc.png"];
//    }
//    return annView;
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
    
    if([annotation.title isEqualToString:@"Adding Event"]){
        annotation.title = @"ubicación del evento";
        annotationView.image = [UIImage imageNamed:@"pin_icon.png"];
    }
    else{
        annotationView.image = [UIImage imageNamed:@"currLoc.png"];
    }
    
    return annotationView;
}


//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    NSLog(@"%@", error.localizedDescription);
//}


//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    
//    currentLat =newLocation.coordinate.latitude;
//    currentLong =newLocation.coordinate.longitude;
//    if(tempVar == 0){
//    CLLocationCoordinate2D ctrpoint;
//    ctrpoint.latitude = currentLat;
//    ctrpoint.longitude = currentLong;
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(ctrpoint,rngCrtLoc,rngCrtLoc);
////    MKCoordinateRegion adjusted_region = [lMapView regionThatFits:region];
//    [lMapView setRegion:[lMapView regionThatFits:region] animated:YES];
//        ++tempVar;
//        [self hideProgressIndicator];
//    }
//}

- (IBAction )BnClearTapped{
    anntLatt = -999999;
    anntLong = -999999;
    countAnnotaions = 0;
    [lMapView removeAnnotations:addedAnnotaionArray];
    [addedAnnotaionArray removeAllObjects];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    [lMapView removeGestureRecognizer:lpgr];
    lblAddCoordinates.enabled = NO;
}

@end
