//
//  AddAlarmLocationViewController.m
//  eMaguen_V2
//
//  Created by Rushikesh Kulkarni on 11/11/14.
//  Copyright (c) 2014 PeleSystem. All rights reserved.
//

#import "AddAlarmLocationViewController.h"
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MyAppAppDelegate.h"
#import "EventsViewController.h"
#import "SendLoc.h"

MyAppAppDelegate *mAppDelegate;

@interface AddAlarmLocationViewController ()
{
    NSString *lLatitude,*lLongitude;
//    CLLocationManager *locationManager;
    int rngCrtLoc, tempVar, countAnnotaions, temp;
    NSMutableArray *addedAnnotaionArray;
    float anntLatt, anntLong;//currentLat, currentLong,
    NSMutableArray *mAlarmDetails;
}
@end

@implementation AddAlarmLocationViewController
- (void)setDetails:(NSArray*)alarmDetails{
    mAlarmDetails = [[NSMutableArray alloc]initWithArray:alarmDetails];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tempVar =0;
    countAnnotaions = 0;
    rngCrtLoc = 5;
    anntLatt = 999;//default value      -90 to 90
    anntLong = 999;//default value      -180 to 180
    temp = 0;
    
    lMapView.delegate = self;
    
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
    
    if([[mAlarmDetails lastObject] intValue] == 0){
        
//        locationManager = [[CLLocationManager alloc] init];
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
        [lMapView addGestureRecognizer:lpgr];
        
        addedAnnotaionArray = [[NSMutableArray alloc]init];
    }
    else if([[mAlarmDetails lastObject] intValue] == 1){
        lblClear.hidden = YES;
        NSDictionary *dict = [mAlarmDetails objectAtIndex:2];
        CLLocationCoordinate2D  tempCtrPoint;
        tempCtrPoint.latitude = [[dict objectForKey:@"Lat"] floatValue];
        tempCtrPoint.longitude = [[dict objectForKey:@"Long"] floatValue];
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,1000,1000);
        MKCoordinateRegion adjusted_region = [lMapView regionThatFits:region];
        [lMapView setRegion:adjusted_region animated:NO];
        lMapView.showsUserLocation = NO;
        
        CLLocationCoordinate2D  ctrpoint;
        
        ctrpoint.latitude = [[dict objectForKey:@"Lat"] floatValue];
        ctrpoint.longitude =[[dict objectForKey:@"Long"] floatValue];
        AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
        addAnnotation.title = [mAlarmDetails objectAtIndex:0];
        //        NSLog(@"%@\t%@",lLatitude,lLongitude);
        //        NSLog(@"Tags:%d, annotation:%d",[lCategory intValue],addAnnotation.tag);
        if((addAnnotation.coordinate.latitude <= 90.0f) && (addAnnotation.coordinate.latitude >= -90.0f)&& (addAnnotation.coordinate.longitude <= 180.0f) && (addAnnotation.coordinate.longitude >= -180.0f))
            [lMapView addAnnotation:addAnnotation];
    }
    // Do any additional setup after loading the view.
}

-(IBAction)BnAddCoordinates:(id)sender{
    if([[mAlarmDetails lastObject] intValue] == 0){
        if(anntLatt != 999 && anntLong != 999){
            [mAlarmDetails removeLastObject];
            NSLog(@"The Annatation point Coordinates are:%f,%f",anntLatt,anntLong);
            [mAlarmDetails addObject:[NSString stringWithFormat:@"%f",anntLatt]];
            [mAlarmDetails addObject:[NSString stringWithFormat:@"%f",anntLong]];
            [mAlarmDetails addObject:@"0"];
            lMapView = nil;
            [mAppDelegate setAddPeopleToAlarmViewController:mAlarmDetails];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Seleccione el lugar / Coordenadas del evento." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else if([[mAlarmDetails lastObject] intValue] == 1){
        [mAppDelegate setAddPeopleToAlarmViewController:mAlarmDetails];
    }
}

- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setAddAlarmViewController];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint touchPoint = [gestureRecognizer locationInView:lMapView];
        CLLocationCoordinate2D touchMapCoordinate = [lMapView convertPoint:touchPoint toCoordinateFromView:lMapView];
        if(countAnnotaions == 0){
            AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:touchMapCoordinate];
            addAnnotation.title = @"ubicación del alarma";
            [addedAnnotaionArray addObject:addAnnotation];
            [lMapView addAnnotation:addAnnotation];
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
    }
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    CLLocation *newLocation = [locations lastObject];
//    currentLat = newLocation.coordinate.latitude;
//    currentLong = newLocation.coordinate.longitude;
//    if(temp == 0){
//        CLLocationCoordinate2D  tempCtrPoint;
//        tempCtrPoint.latitude = currentLat;
//        tempCtrPoint.longitude = currentLong;
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,5,5);
//        MKCoordinateRegion adjusted_region = [lMapView regionThatFits:region];
//        [lMapView setRegion:adjusted_region animated:NO];
//        ++temp;
//    }
//}

- (IBAction )BnClearTapped{
    anntLatt = 999;
    anntLong = 999;
    countAnnotaions = 0;
    [lMapView removeAnnotations:addedAnnotaionArray];
    [addedAnnotaionArray removeAllObjects];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    [lMapView removeGestureRecognizer:lpgr];    
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
    annotationView.image = [UIImage imageNamed:@"pin_alarm_iphone4.png"];
    
    return annotationView;
}


//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    NSLog(@"%@", error.localizedDescription);
//}

@end
