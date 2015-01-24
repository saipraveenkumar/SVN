//
//  EventsViewController.h
//  eMaguen
//
//  Created by Rohit Yermalkar on 12/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface EventsViewController : RootViewController <MKMapViewDelegate>
{
        IBOutlet MKMapView *lMapView;
        IBOutlet UIButton *lButton1;
        IBOutlet UIButton *lButton2;
        IBOutlet UIButton *lButton3;
        IBOutlet UIImageView *topMenuImgV;
}
- (IBAction)BnAddEvent:(id)sender;

@end


@interface AddressAnnotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *mTitle;
    NSString *mSubTitle;
    int mTag;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic) int tag;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c;


@end
