//
//  AddEventViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 13/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RootViewController.h"


@interface AddEventViewController : RootViewController //<CLLocationManagerDelegate>
{
    IBOutlet MKMapView *lMapView;
    IBOutlet UIButton *lblAddCoordinates;
}
-(IBAction )BnClearTapped;
//-(IBAction )BnHideTapped;


@end


