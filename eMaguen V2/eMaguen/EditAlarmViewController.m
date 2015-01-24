//
//  EditAlarmViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 20/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "EditAlarmViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import "EventsViewController.h"
#import "AddAlarmModel.h"
#import "CountryNumberModel.h"
#import "FMResultSet.h"

#define MAX_LENGTH 15
#define NO_CONTACT @"Sin Contacto"

MyAppAppDelegate *mAppDelegate;

@interface EditAlarmViewController (){
    NSMutableArray *alarmNumbers;
    UITapGestureRecognizer *tap;
}

@end

@implementation EditAlarmViewController{
    int tempVar, buttonTag;
    NSMutableArray *mobileArray;
    NSArray *mAlaramDetails;
    ABPeoplePickerNavigationController *picker;
    int setController,smsCount ;
    ReverseGeocodeCountry *reverseGeocode;
    NSString *countryName, *countryNumber;
    BOOL isAssociatedAlarm;
    UIAlertView *alertBox;
}

- (void)setDetails:(NSArray*)alarmDetails{
    //    mAlaramDetails = alarmDetails;
    mAlaramDetails = alarmDetails;
    tempVar =0;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_UPDATEALARM_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_UPDATEALARM_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    AddAlarmModel *lAddAlarm = [AddAlarmModel getAddAlarmModel];
    if([lAddAlarm.alarmAdd isEqualToString:@"Successfully Added"]){
        alertBox = [[UIAlertView alloc]initWithTitle:lblAlarmName.text message:@"Se ha actualizado con éxito" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        alertBox.tag = 1;
        [alertBox show];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No se agregó" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        if(isAssociatedAlarm == YES){
            alarmNumbers = nil;
            [mAppDelegate setChooseAlarmViewController];
        }
        else{
            if(!mobileArray)
                mobileArray = [[NSMutableArray alloc]init];
            [mobileArray addObject:[mAlaramDetails objectAtIndex:0]];
            if(![lblContact1.text isEqualToString:[mAlaramDetails objectAtIndex:5]]){
                //            [mobileArray addObject:lblContact1.text];
                setController = 1;
                [mobileArray addObject:lblContact1.text];
            }
            else{
                [mobileArray addObject:NO_CONTACT];
            }
            if(![lblContact2.text isEqualToString:[mAlaramDetails objectAtIndex:6]]){
                //            [mobileArray addObject:lblContact1.text];
                setController = 1;
                [mobileArray addObject:lblContact2.text];
            }
            else{
                [mobileArray addObject:NO_CONTACT];
            }
            if(![lblContact3.text isEqualToString:[mAlaramDetails objectAtIndex:7]]){
                //            [mobileArray addObject:lblContact1.text];
                setController = 1;
                [mobileArray addObject:lblContact3.text];
            }
            else{
                [mobileArray addObject:NO_CONTACT];
            }
            NSArray *recipents = [NSArray arrayWithObject:[mAlaramDetails objectAtIndex:1]];//alarmSimNumber
            NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
            NSString *message = [NSString stringWithFormat:@"TEL:\n1.%@\n2.%@\n3.%@\n4.%@\n5.%@",[lData objectForKey:@"kPrefKeyForCountryNumber"],[lData objectForKey:@"kPrefKeyForPhone"],(![lblContact1.text isEqualToString:NO_CONTACT]?lblContact1.text:@""),(![lblContact2.text isEqualToString:NO_CONTACT]?lblContact2.text:@""),(![lblContact3.text isEqualToString:NO_CONTACT]?lblContact3.text:@"")];
            NSLog(@"\n%@",message);
            smsCount = 0;
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:recipents];
            [messageController setBody:message];
            // Present message view controller on screen
            [self presentViewController:messageController animated:YES completion:nil];
        }
    }
    else if (alertView.tag == 2){
//        if(smsCount == 1){
            if(setController == 1){
                [mAppDelegate setSendRequestVCWithMobileNumbers:mobileArray];
                mobileArray = nil;
            }
            else{
                [mAppDelegate setChooseAlarmViewController];
            }
//        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
//            if(smsCount == 1){
                if(setController == 1){
                    [mAppDelegate setSendRequestVCWithMobileNumbers:mobileArray];
                    mobileArray = nil;
                }
                else{
                    [mAppDelegate setChooseAlarmViewController];
                }
//            }
            break;
            
        case MessageComposeResultFailed:
        {
            alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error al enviar SMS!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            alertBox.tag = 2;
            [alertBox show];
            break;
        }
            
        case MessageComposeResultSent:
//            if(smsCount == 1){
                if(setController == 1){
                    [mAppDelegate setSendRequestVCWithMobileNumbers:mobileArray];
                }
                else{
                    [mAppDelegate setChooseAlarmViewController];
                }
//            }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
//    if(smsCount == 0){
//        NSArray *recipents = [NSArray arrayWithObject:[mAlaramDetails objectAtIndex:1]];//alarmSimNumber
//        NSString *message = [NSString stringWithFormat:@"Zone information:\n1.eMaguen\n2.eMaguen\n3.eMaguen\n4."];
//        NSLog(@"\n%@",message);
//        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
//        messageController.messageComposeDelegate = self;
//        [messageController setRecipients:recipents];
//        [messageController setBody:message];
//        // Present message view controller on screen
//        [self presentViewController:messageController animated:YES completion:nil];
//        ++smsCount;
//    }
}


-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!reverseGeocode)
    reverseGeocode = [[ReverseGeocodeCountry alloc] init];
    
    lblAlarmName.self.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    setController = 0;
    
    smsCount = 0;
    [self.view endEditing:YES];
    
    [self.navigationController setToolbarHidden:YES];
    
    isAssociatedAlarm = NO;
    if(!alarmNumbers)
        alarmNumbers = [[NSMutableArray alloc]init];
    for (int i = 5; i<=8; i++) {
        [alarmNumbers addObject:[mAlaramDetails objectAtIndex:i]];
    }
    for(NSString *str in alarmNumbers){
        NSLog(@"%@ == %@",str,[mAlaramDetails lastObject]);
        if(([str rangeOfString:[mAlaramDetails lastObject]].location != NSNotFound) || ([[mAlaramDetails lastObject] rangeOfString:str].location != NSNotFound) ){
            isAssociatedAlarm = YES;
            bnContact1.enabled = NO;
            bnContact2.enabled = NO;
            bnContact3.enabled = NO;
            lblContact1.textColor = [UIColor grayColor];
            lblContact2.textColor = [UIColor grayColor];
            lblContact3.textColor = [UIColor grayColor];
            break;
        }
    }
    
    [self callService];
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
}

- (void)callService{
    
    lblAlarmName.delegate = self;
    
    lblAlarmName.text = [[mAlaramDetails objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    lblUserNumber.text = [mAlaramDetails objectAtIndex:10];
    lblContact1.text = ([mAlaramDetails objectAtIndex:5] ? [mAlaramDetails objectAtIndex:5] :@"Sin contacto");
    lblContact2.text = ([mAlaramDetails objectAtIndex:6] ? [mAlaramDetails objectAtIndex:6] :@"Sin contacto");
    lblContact3.text = ([mAlaramDetails objectAtIndex:7] ? [mAlaramDetails objectAtIndex:7] :@"Sin contacto");
}

- (IBAction)BnDetailsUpdate:(id)sender{
    if([[mAlaramDetails objectAtIndex:5] isEqualToString:lblContact1.text] && [[mAlaramDetails objectAtIndex:6] isEqualToString:lblContact2.text] && [[mAlaramDetails objectAtIndex:7] isEqualToString:lblContact3.text] && [[mAlaramDetails objectAtIndex:0] isEqualToString:lblAlarmName.text]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Hay datos modificados" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        if(lblAlarmName.text.length == 0){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Elija nombre de la alarma" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        else{
            [picker removeFromParentViewController];
            
            [self addProgressIndicator];
            [self showProgressIndicator];
            
            AlarmParam *lAlarmParam = [[AlarmParam alloc]init];
            lAlarmParam.alarmName = [lblAlarmName.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            lAlarmParam.alarmNumber = [mAlaramDetails objectAtIndex:1];
            lAlarmParam.number1 = [mAlaramDetails objectAtIndex:4];
            lAlarmParam.number2 = lblContact1.text;
            lAlarmParam.number3 = lblContact2.text;
            lAlarmParam.number4 = lblContact3.text;
            lAlarmParam.lattitude = [mAlaramDetails objectAtIndex:2];
            lAlarmParam.longitude = [mAlaramDetails objectAtIndex:3];
            lAlarmParam.username = [mAlaramDetails objectAtIndex:9];
            lAlarmParam.userNumber = [mAlaramDetails objectAtIndex:10];
            
            AddAlarmModel *lAddAlarm = [AddAlarmModel getAddAlarmModel];
            [lAddAlarm callGetUpdateAlarmWebservice:lAlarmParam];
            mLabelLoading.text = @"Gurdando...";
        }
    }
}

-(IBAction)BnBackTapped:(id)sender{
    //    [picker removeFromParentViewController];
    [mAppDelegate setConfigureAlarmVCWithAlarmName:mAlaramDetails];
}

- (IBAction)BnEditMapTapped:(id)sender{
    [mAppDelegate setEditAlarmMapVCWithAlarmDetails:[NSArray arrayWithObjects:lblAlarmName.text,[mAlaramDetails objectAtIndex:1],[mAlaramDetails objectAtIndex:2],[mAlaramDetails objectAtIndex:3],[mAlaramDetails objectAtIndex:4],lblContact1.text,lblContact2.text,lblContact3.text,[mAlaramDetails objectAtIndex:8],[mAlaramDetails objectAtIndex:9],[mAlaramDetails objectAtIndex:10], nil]];
}

//hiding status bar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
///

- (IBAction)BnEditContact:(id)sender{
    UIButton *button = sender;
    buttonTag = (int)button.tag;
    if(!picker){
        picker=[[ABPeoplePickerNavigationController alloc] init];
    }
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
     shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property
                             identifier:(ABMultiValueIdentifier)identifier{
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person;
{
    [self displayPerson:person];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    //calls displayPerson:(ABRecordRef)person to show contact's information in the app
    [self displayPerson:person];
    [self dismissViewControllerAnimated:NO completion:NULL];
    return NO;
}

- (void)displayPerson:(ABRecordRef)person
{
    //    [self performSelector:nil withObject:nil afterDelay:2];
    NSMutableArray *numbers = [[NSMutableArray alloc]init];
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
    {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
        NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        //CFRelease(phones);
        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
        CFRelease(phoneNumberRef);
        CFRelease(locLabel);
        NSLog(@"  - %@ (%@)", phoneNumber, phoneLabel);
        [numbers addObject:phoneNumber];
    }
    if([numbers count]<=0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Este contacto no tiene un teléfono asociado" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString* phone = [[[numbers objectAtIndex:0] componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        NSLog(@"Phone:%@",phone);
        NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
        if([lblContact1.text isEqualToString:phone] || [lblContact2.text isEqualToString:phone] || [lblContact3.text isEqualToString:phone] || ([phone rangeOfString:[lData objectForKey:@"kPrefKeyForPhone"]].location != NSNotFound) || ([[lData objectForKey:@"kPrefKeyForPhone"] rangeOfString:phone].location != NSNotFound)){
            [self contactExists];
        }
        else{
            if(buttonTag == 0){
                lblContact1.text = phone;
            }
            else if (buttonTag == 1){
                lblContact2.text = phone;
            }
            else if (buttonTag == 2){
                lblContact3.text = phone;
            }
        }
    }
}

- (void)contactExists{
    [self dismissViewControllerAnimated:NO completion:NULL];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"El contacto ya está en la lista" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [alert show];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(lblAlarmName == textField)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-0123456789 "];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
            else{
                if(textField.text.length == 0){
                    switch (c) {
                        case '_':
                        case '-':
                        case ' ':
                            return NO;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        return YES;
    }
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= MAX_LENGTH || returnKey;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if([textField.text isEqualToString:@"\n"]){
        return NO;
    }
    return YES;
}


@end
