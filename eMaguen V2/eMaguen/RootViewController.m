//
//  RootViewController.m
//  CERSAI14
//
//  Created by Rohit Yermalkar on 11/04/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "RootViewController.h"
#import "MyAppAppDelegate.h"
#import "SendLoc.h"

@interface RootViewController ()
{
    MyAppAppDelegate *mAppDelegate;
}

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    iPad = NO;
    iPhone = NO;
    iPhone5 = NO;
    commCount = 0;
    flagComments = 0;
    
    iPhone      = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    iPad        = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    iPhone5     = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0;
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    [self enableExclusiveTouch];
    
    
}


- (void) enableExclusiveTouch{
    for (id object in [self.view subviews]){
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *tempButton = object;
            tempButton.exclusiveTouch = YES;
        }
    }
}

- (void)stopShareLocationApp{
    SendLoc *loc = [SendLoc getSendLoc];
    [loc stopShareLocation];
}

- (void)startSharingLocation{
    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
    if([[lData objectForKey:@"kPrefKeyForLocationService"] intValue] == 1){
        SendLoc *loc = [SendLoc getSendLoc];
        [loc shareCurrentLocation];
    }
}

- (void) addProgressIndicator{
    iPhone      = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    iPad        = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    iPhone5     = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568.0;
    
    
    if (iPhone5) {
        mViewLoading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
        mImageViewLoading = [[UIImageView alloc] initWithFrame:CGRectMake(82, 177, 156, 124)];
        mActivityLoading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(142, 194, 37, 37)];
        mLabelLoading = [[UILabel alloc] initWithFrame:CGRectMake(98, 244, 127, 50)];
    }
    else if (iPhone) {
        mViewLoading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        mImageViewLoading = [[UIImageView alloc] initWithFrame:CGRectMake(82, 177, 156, 124)];
        mActivityLoading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(142, 194, 37, 37)];
        mLabelLoading = [[UILabel alloc] initWithFrame:CGRectMake(98, 244, 127, 50)];
    }
    else{
        mViewLoading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
        mImageViewLoading = [[UIImageView alloc] initWithFrame:CGRectMake(306, 440, 156, 124)];
        mActivityLoading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(366, 455, 37, 37)];
        mLabelLoading = [[UILabel alloc] initWithFrame:CGRectMake(323, 510, 127, 50)];
        mLabelLoading.font = [UIFont systemFontOfSize:15.0];
    }
    
    mViewLoading.alpha = 0.5;
    mViewLoading.backgroundColor = [UIColor blackColor];
    [self.view addSubview:mViewLoading];
    
    NSString* lBGIndicator = [[NSBundle mainBundle] pathForResource:@"bg_loading.png" ofType:nil inDirectory:@""];
    mImageViewLoading.image = [UIImage imageWithContentsOfFile:lBGIndicator];
    
    
    [self.view addSubview:mImageViewLoading];
    [self.view addSubview:mActivityLoading];
    
    mLabelLoading.numberOfLines = 2;
    mLabelLoading.textAlignment = NSTextAlignmentCenter;
    mLabelLoading.backgroundColor = [UIColor clearColor];
    mLabelLoading.textColor = [UIColor whiteColor];
    mLabelLoading.font = [UIFont fontWithName:@"DINBold" size:15];
    [self.view addSubview:mLabelLoading];
}
- (void) showProgressIndicator{
    [self stopShareLocationApp];
    mViewLoading.hidden = NO;
    mImageViewLoading.hidden = NO;
    mActivityLoading.hidden = NO;
    mLabelLoading.hidden = NO;
    [mActivityLoading startAnimating];
    self.view.userInteractionEnabled = NO;
}
- (void) hideProgressIndicator{
    [self startSharingLocation];
    mViewLoading.hidden = YES;
    mImageViewLoading.hidden = YES;
    mActivityLoading.hidden = YES;
    mLabelLoading.hidden = YES;
    [mActivityLoading stopAnimating];
    self.view.userInteractionEnabled = YES;
}



- (void) showNetworkError{
    [self hideProgressIndicator];
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Información" message: @"Sin conexión a Internet. Por favor, inténtelo de nuevo." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [myAlert show];
}


@end
