//
//  PeopleOnMapViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 27/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "PeopleOnMapViewController.h"
#import <MapKit/MapKit.h>
#import "StringID.h"
#import "MyAppAppDelegate.h"
#import <MapKit/MKAnnotation.h>
#import "GetPeoplesLocationModel.h"
#import "EventsViewController.h"
#import "SendLoc.h"

MyAppAppDelegate *mAppDelegate;

@interface PeopleOnMapViewController (){
    //    CLLocationManager *locationManager;
    //    float currentLatitude, currentLongitude;
    int temp, range;
    NSArray *mPersonDetails;
    CLLocationDistance distance;
    GetPeoplesLocationModel *lGetPeopleLocationModel;
    SendLoc *loc;
    NSUserDefaults *lData;
}
@end

@implementation PeopleOnMapViewController

- (void)setPersonDetails:(NSArray *)personDetails{
    mPersonDetails = personDetails;
    NSLog(@"PersonDetails:%@",personDetails);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
        //        [self hideProgressIndicator];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_PEOPLE_LOCATION_DETAILS_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_PEOPLE_LOCATION_DETAILS_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self loadData];
    //    [self performSelector:@selector(hideProgressIndicator) withObject:nil afterDelay:5.0];
}

-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [mAppDelegate setPeopleViewController:[NSArray arrayWithObjects:[mPersonDetails objectAtIndex:0],[mPersonDetails objectAtIndex:1], nil]];
}

- (void) loadData{
    NSArray *locationDetails = lGetPeopleLocationModel.peopleLocation;
    if([[locationDetails objectAtIndex:0] isEqualToString:@""] || [[locationDetails objectAtIndex:1] isEqualToString:@""]){
        UIAlertView *alertBox = [[UIAlertView alloc]initWithTitle:@"No se puede obtener la ubicación" message:@"El usuario no está compartiendo su ubicación" delegate:self cancelButtonTitle:@"Volver" otherButtonTitles: nil];
        [alertBox show];
    }
    else{
        [lMapView removeAnnotations:lMapView.annotations];
        CLLocationCoordinate2D  ctrpoint;
        ctrpoint.latitude = [[locationDetails objectAtIndex:0] floatValue];
        ctrpoint.longitude =[[locationDetails objectAtIndex:1] floatValue];
        AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
        addAnnotation.title = [mPersonDetails objectAtIndex:3];
        if((addAnnotation.coordinate.latitude <= 90.0f) && (addAnnotation.coordinate.latitude >= -90.0f)&& (addAnnotation.coordinate.longitude <= 180.0f) && (addAnnotation.coordinate.longitude >= -180.0f)){
            [lMapView addAnnotation:addAnnotation];
            if(temp == 0){
                CLLocation *locA = [[CLLocation alloc] initWithLatitude:loc.lattitude longitude:loc.longitude];
                CLLocation *locB = [[CLLocation alloc] initWithLatitude:addAnnotation.coordinate.latitude longitude:addAnnotation.coordinate.longitude];
                distance = [locA distanceFromLocation:locB];
                if(range <= distance){
                    range = distance;
                    NSLog(@"range: %d",range);
                }
            }
        }
        if(range > 500){
            range+=20000;
        }
        if([mAppDelegate alertSharingLocation] == 0){
            lMapView.showsUserLocation = YES;
            CLLocationCoordinate2D  tempCtrPoint;
            tempCtrPoint.latitude = loc.lattitude;
            tempCtrPoint.longitude = loc.longitude;
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,range,range);
            MKCoordinateRegion adjusted_region = [lMapView regionThatFits:region];
            [lMapView setRegion:adjusted_region animated:YES];
            [lMapView reloadInputViews];
            ++temp;
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callLocationService) object:nil];
        [self performSelector:@selector(callLocationService) withObject:nil afterDelay:5];
    }
    lMapView.delegate = self;
}

- (void)callLocationService{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // update UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [lGetPeopleLocationModel callGetPeoplesLocationModelWebserviceWithUserId:[mPersonDetails objectAtIndex:2]];
        });
    });
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(AddressAnnotation *)annotation
{
    if([annotation class] == MKUserLocation.class)
        return nil;
    
    NSString *pinIdentifier = [NSString stringWithFormat:@"PinId"];
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
    
    if(annotationView == nil)
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
    else
        annotationView.annotation = annotation;
    
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = NO;
    annotationView.enabled = YES;
    UILabel *lbl = [[UILabel alloc] init];
    if (iPhone5){
        lbl.frame = CGRectMake(5, 0, 70, 66);
    }
    else if (iPhone){
        lbl.frame = CGRectMake(5, 0, 30, 30);
    }
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = annotation.title;
    lbl.textColor = [UIColor blackColor];
    lbl.alpha = 0.5;
    [annotationView addSubview:lbl];
    //    annotationView.frame = lbl.frame;
    
    [mapView.userLocation setTitle:@"Estoy aquí..."];
    
    if(iPhone5)
        annotationView.image = [UIImage imageNamed:@"i5_pin_person_icon-31.png"];
    else if (iPhone)
        annotationView.image = [UIImage imageNamed:@"i4_pin_person_icon-31.png"];
    
    return annotationView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!loc)
        loc = [SendLoc getSendLoc];
    if(!mAppDelegate)
        mAppDelegate = [MyAppAppDelegate getAppDelegate];
    if(!lGetPeopleLocationModel)
        lGetPeopleLocationModel = [GetPeoplesLocationModel getGetPeoplesLocationModel];
    
    lblTitle.text = [mPersonDetails lastObject];
    lMapView.rotateEnabled = NO;
    temp = 0;
    range = 0;
    if(!lData)
    lData = [NSUserDefaults standardUserDefaults];
    
    [self addProgressIndicator];
    [self showProgressIndicator];
    [lGetPeopleLocationModel callGetPeoplesLocationModelWebserviceWithUserId:[mPersonDetails objectAtIndex:2]];
    mLabelLoading.text = @"Buscando...";
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [lMapView selectAnnotation:[view annotation] animated:YES];
}

- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setPeopleViewController:[NSArray arrayWithObjects:[mPersonDetails objectAtIndex:0],[mPersonDetails objectAtIndex:1], nil]];
    [self deallocMemory];
}

- (void)deallocMemory{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callLocationService) object:nil];
    //    locationManager = nil;
    mPersonDetails = nil;
    lGetPeopleLocationModel = nil;
}


@end


