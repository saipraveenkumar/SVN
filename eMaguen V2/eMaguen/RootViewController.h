//
//  RootViewController.h
//  CERSAI14
//
//  Created by Rohit Yermalkar on 11/04/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface RootViewController : UIViewController
{
    BOOL iPad;
    BOOL iPhone;
    BOOL iPhone5;
    int commCount,flagComments;
    
    IBOutlet UIView                     *mViewLoading;
    IBOutlet UIImageView                *mImageViewLoading;
    IBOutlet UIActivityIndicatorView    *mActivityLoading;
    IBOutlet UILabel                    *mLabelLoading;


}
- (void) addProgressIndicator;
- (void) showProgressIndicator;
- (void) hideProgressIndicator;
- (void) showNetworkError;
@end
