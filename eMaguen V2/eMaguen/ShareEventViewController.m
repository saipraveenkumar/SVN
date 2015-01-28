//
//  ShareEventViewController.m
//  eMaguen
//
//  Created by Rohit Yermalkar on 13/06/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ShareEventViewController.h"
#import "MyAppAppDelegate.h"
#import "UserDataModel.h"
#import "StringID.h"
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>

MyAppAppDelegate *mAppDelegate;

@interface ShareEventViewController ()
{
    NSString *detailsToShare;
    NSString *lblCategory,*lblDatetime,*lblDescription,*lblImage,*lblURL;
}
@end

@implementation ShareEventViewController

-(void)DtlsToShare:(NSString *)category and:(NSString*)dateTime and:(NSString*)description and:(NSString*)image and:(NSString*)url{
    lblCategory =category;
    lblDatetime = dateTime;
    lblDescription = description;
    if([image isEqualToString:@""])
        lblImage = [NSString stringWithFormat:@"http://emaguen2.azurewebsites.net/images/Logo.jpg"];
    else
        lblImage = image;
    lblURL = [NSString stringWithFormat:@"http://emaguenV2.azurewebsites.net/eventos/EventSOS.aspx?id=%@",url];
    NSLog(@"URL:%@",lblURL);
//    detailsToShare = sndDtlsToShare;
//    NSLog(@"%@",sndDtlsToShare);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.documentationInteractionController.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)updateAlert:(UIAlertView *)alert {
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

-(IBAction)BnShowMenu:(id)sender{
    [mAppDelegate setHomeVCAsWindowRootVC];
}

-(IBAction)BnFacebookTapped:(id)sender{

//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
//    {
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [lblCategory uppercaseString], @"name",
                                           [NSString stringWithFormat:@"%@",lblURL], @"caption",
                                           [NSString stringWithFormat:@"%@ on %@",lblDescription,lblDatetime], @"description",
                                           lblURL, @"link",
                                           lblImage, @"picture",
                                           nil];
            
            // Show the feed dialog
            [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                if (error) {
                                                          // An error occurred, we need to handle the error
                                                              // See: https://developers.facebook.com/docs/ios/errors
                    NSLog(@"Error publishing story: %@", error.description);
                } else {
                    if (result == FBWebDialogResultDialogNotCompleted) {
                        // User cancelled.
                        NSLog(@"User cancelled.");
                    } else {
                        // Handle the publish feed callback
                        NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                                  
                        if (![urlParams valueForKey:@"post_id"]) {
                            // User cancelled.
                            NSLog(@"User cancelled.");
                                                                      
                        } else {
                            NSLog(@"result %@", [urlParams valueForKey:@"post_id"]);
                            if([urlParams valueForKey:@"post_id"]){
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Con éxito compartido en Facebook.." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                                [alert show];
                            }
                            else{
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Sin éxito compartido en Facebook." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                                [alert show];
                            }
                        }
                    }
                }
            }];
//    }
//    else
//    {
//        SCLAlertView *alert = [[SCLAlertView alloc] init];
//        alert.shouldDismissOnTapOutside = YES;
//        [alert showInfo:self title:@"Atención" subTitle:@"Por favor, configurar los ajustes de Facebook." closeButtonTitle:@"Aceptar" duration:0.0f];
////        facebookAlert = [[UIAlertView alloc]initWithTitle:nil message:@"Por favor, configurar los ajustes de Facebook." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
////        [facebookAlert show];
//    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(IBAction)BnTwitterTapped:(id)sender{
//    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
    
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        //Adding the Text to the facebook post value from iOS
        [controller setInitialText:[NSString stringWithFormat:@"%@\nOn %@\n",[lblCategory uppercaseString],lblDatetime]];
        
        //Adding the URL to the facebook post value from iOS
        
        [controller addURL:[NSURL URLWithString:lblURL]];
        
        //Adding the Image to the facebook post value from iOS
        NSURL *aURL = [NSURL URLWithString:[lblImage stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        [controller addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:aURL]]];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
        [controller setCompletionHandler:^(SLComposeViewControllerResult result){
            UIAlertView *alert;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Con éxito compartido en Twitter." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                    [alert show];
                    break;
                case SLComposeViewControllerResultDone:
                    alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Sin éxito compartido en Twitter." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                    [alert show];
                    break;
                    
                default:
                    break;
            }
         }];
//    }
//    else{
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Por favor, configurar los ajustes de Twitter." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
//        [alert show];
//    }
}

-(IBAction)BnWhatsappTapped:(id)sender{
    NSString *formattedText = [NSString stringWithFormat:@"@eMaguen:\n\n%@\n\n%@ on %@\n\n%@",[lblCategory uppercaseString],lblDescription,lblDatetime,lblURL];
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                     NULL,
                                                                                                     (CFStringRef)formattedText,
                                                                                                     NULL,
                                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                     kCFStringEncodingUTF8 ));

    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",encodedString];
    NSURL * whatsappURL = [NSURL URLWithString:urlWhats];//[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"WhatsApp no se instala." message:@"El dispositivo no tiene instalado WhatsApp." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL*) fileURL

                                               usingDelegate: (id ) interactionDelegate {
    
    
    
    self.documentationInteractionController =[UIDocumentInteractionController interactionControllerWithURL: fileURL];
    
    self.documentationInteractionController.delegate = interactionDelegate;
    
    
    
    return self.documentationInteractionController;
    
}


//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if(buttonIndex == 0){
//        if(alertView == facebookAlert || alertView == twitterAlert){
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        }
//    }
//}
//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];



@end



//
//NSURL* url = [NSURL URLWithString:@"https://developers.facebook.com/"];
//[FBDialogs presentShareDialogWithLink:url
//                              handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                  if(error) {
//                                      NSLog(@"Error: %@", error.description);
//                                  } else {
//                                      NSLog(@"Success!");
//                                  }
//                              }];
