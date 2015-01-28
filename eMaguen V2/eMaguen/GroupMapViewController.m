//
//  GroupMapViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 12/12/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "GroupMapViewController.h"
#import "MyAppAppDelegate.h"
#import <MapKit/MapKit.h>
#import "StringID.h"
#import <MapKit/MKAnnotation.h>
#import "EventsViewController.h"
#import "SendLoc.h"

#define GROUP_MAP_URL @"{\"Id\":\"%@\"}"

MyAppAppDelegate *mAppAppDelegate;

@interface GroupMapViewController ()
{
    NSArray *mGroupDetails;
    BOOL isCountNull;
    int temp,delay,range;
    CLLocationDistance distance;
    NSDictionary *groupData;
    NSArray *latLongData;
    NSArray *namesData;
    UILabel *lbl;
    SendLoc *loc;
    NSUserDefaults *lData;
}
@end

@implementation GroupMapViewController

- (void)setGroupDetails:(NSArray *)groupDetails{
    mGroupDetails = groupDetails;
    NSLog(@"Group Details:%@",mGroupDetails);
}

- (void)callBGProcess{
    NSUserDefaults *lUserData = [NSUserDefaults standardUserDefaults];
    [lMapView removeAnnotations:lMapView.annotations];
    for(UIView *view in lMapView.subviews){
        if([view isKindOfClass:[UILabel class]]){
            [view removeFromSuperview];
        }
    }
    for(int i =0;i<[[groupData objectForKey:@"GroupMemberCount"] intValue];i++){
        if(![[lUserData objectForKey:@"kPrefKeyForUpdatedUsername"] isEqualToString:[namesData objectAtIndex:i]]){
            NSMutableString *latLong = [[NSMutableString alloc]initWithString:[latLongData objectAtIndex:i]];
            [latLong substringWithRange:NSMakeRange(1, latLong.length-2)];
            NSLog(@"%@",latLong);
            NSArray *myArray = [latLong componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            NSLog(@"%@",myArray);
            CLLocationCoordinate2D  ctrpoint;
            ctrpoint.latitude = [[myArray objectAtIndex:0] floatValue];
            ctrpoint.longitude =[[myArray objectAtIndex:1] floatValue];
            AddressAnnotation *addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:ctrpoint];
            addAnnotation.title = [namesData objectAtIndex:i];
            if((addAnnotation.coordinate.latitude <= 90.0f) && (addAnnotation.coordinate.latitude >= -90.0f)&& (addAnnotation.coordinate.longitude <= 180.0f) && (addAnnotation.coordinate.longitude >= -180.0f)){
                [lMapView addAnnotation:addAnnotation];
                if(delay == 0){
                    CLLocation *locA = [[CLLocation alloc] initWithLatitude:loc.lattitude longitude:loc.longitude];
                    CLLocation *locB = [[CLLocation alloc] initWithLatitude:addAnnotation.coordinate.latitude longitude:addAnnotation.coordinate.longitude];
                    distance = [locA distanceFromLocation:locB];
                    if(range <= distance){
                        range = distance;
                        NSLog(@"range: %d",range);
                    }
                }
            }
        }
    }
    if(range > 500){
        range+=20000;
    }
    if(delay == 0 && [mAppAppDelegate alertSharingLocation] == 0){
        lMapView.showsUserLocation = YES;
        CLLocationCoordinate2D  tempCtrPoint;
        tempCtrPoint.latitude = loc.lattitude;
        tempCtrPoint.longitude = loc.longitude;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tempCtrPoint,range,range);
        MKCoordinateRegion adjusted_region = [lMapView regionThatFits:region];
        [lMapView setRegion:adjusted_region animated:YES];
        [lMapView reloadInputViews];
    }
    delay = 5;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callLocationService) object:nil];
    [self performSelector:@selector(callLocationService) withObject:nil afterDelay:5];
}

- (void)callLocationService{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //        // update UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self callGroupMapWebService];
        });
    });
}

-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)callGroupMapWebService{
    NSString *urlString = [NSString stringWithFormat:@"%@ListaGroupMemberLocation",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:GROUP_MAP_URL,[mGroupDetails objectAtIndex:0]];
    
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
    
    //        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSError *error;
    groupData = nil;
    groupData = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
    NSLog(@"Group Map Data: %@",groupData);
    //    [self loadData];
    [self hideProgressIndicator];
    latLongData = nil;
    namesData = nil;
    latLongData = [[groupData objectForKey:@"LatLong"] subarrayWithRange:NSMakeRange(0, [[groupData objectForKey:@"GroupMemberCount"] intValue])];
    namesData = [[groupData objectForKey:@"MemberNames"] subarrayWithRange:NSMakeRange(0, [[groupData objectForKey:@"GroupMemberCount"] intValue])];
    if(latLongData.count <=0){
        if(isCountNull == YES){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No se puede obtener la ubicación" message:@"El usuario no está compartiendo su ubicación" delegate:self cancelButtonTitle:@"Volver" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        //        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callBGProcess) object:nil];
        //        [self performSelector:@selector(callBGProcess) withObject:nil afterDelay:delay];
        ////                    [self performSelectorInBackground:@selector(callBGProcess) withObject:nil];
        [self callBGProcess];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mAppAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    lMapView.rotateEnabled = NO;
    temp = 0;
    delay = 0;
    range = 500;
    isCountNull = YES;
    
    lblTitle.text = [mGroupDetails objectAtIndex:1];
    
    if(!loc)
        loc = [SendLoc getSendLoc];
    //    lMapView.delegate = self;
    
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
    
    if(!lData)
        lData = [NSUserDefaults standardUserDefaults];
    
//    if(!latLongData)
//        latLongData = [[NSMutableArray alloc]init];
//    if(!namesData)
//        namesData = [[NSMutableArray alloc]init];
    
    [self addProgressIndicator];
    [self showProgressIndicator];
    mLabelLoading.text = @"Cargando...";
    [self performSelector:@selector(callGroupMapWebService) withObject:nil afterDelay:delay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(AddressAnnotation *)annotation
{
    
    if([annotation class] == MKUserLocation.class)
        return nil;
    
    NSString *pinIdentifier = [NSString stringWithFormat:@"PinId"];
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
    
    if(annotationView == nil){
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
    }
    else
        annotationView.annotation = annotation;
    
    lbl = [[UILabel alloc] init];
    lbl.text = @"";
    annotationView.canShowCallout = YES;
    if (iPhone5){
        lbl.frame = CGRectMake(5, 5, 70, 46);
        //        [lbl sizeThatFits:CGSizeMake(70, 66)];
    }
    else if (iPhone){
        lbl.frame = CGRectMake(5, 5, 30, 30);
        [lbl setFont:[UIFont systemFontOfSize:8]];
        //        [lbl sizeThatFits:CGSizeMake(30, 30)];
    }
    lbl.backgroundColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = annotation.title;
    lbl.textColor = [UIColor blackColor];
    //    lbl.alpha = 0.5;
    [annotationView addSubview:lbl];
    
    [mapView.userLocation setTitle:@"Estoy aquí..."];
    
    if(iPhone5)
        annotationView.image = [UIImage imageNamed:@"i5_pin_person_icon-31.png"];
    else if (iPhone)
        annotationView.image = [UIImage imageNamed:@"i4_pin_person_icon-31.png"];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [lMapView selectAnnotation:[view annotation] animated:YES];
}

//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    //    NSLog(@"%@", [locations lastObject]);
//    CLLocation *newLocation = [locations lastObject];
//    currentLatitude = newLocation.coordinate.latitude;
//    currentLongitude = newLocation.coordinate.longitude;
//    //    if(temp == 0){
//    //        ++temp;
//    //    }
//
//}

//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    NSLog(@"%@", error.localizedDescription);
//}

- (IBAction)BnBackTapped:(id)sender{
    isCountNull = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callLocationService) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(callGroupMapWebService) object:nil];
    [mAppAppDelegate setPeopleViewController:mGroupDetails];
    [self deallocMemory];
}

- (void)deallocMemory{
    [lMapView removeAnnotations:lMapView.annotations];
    lMapView = nil;
    mGroupDetails = nil;
    //    locationManager = nil;
    groupData = nil;
    latLongData = nil;
    namesData = nil;
}

@end
