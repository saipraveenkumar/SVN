//
//  AddPeopleToAlarmViewController.m
//  eMaguen_V2
//
//  Created by Rushikesh Kulkarni on 11/11/14.
//  Copyright (c) 2014 PeleSystem. All rights reserved.
//

#import "AddPeopleToAlarmViewController.h"
#import "MyAppAppDelegate.h"
#import "AddAlarmModel.h"
#import "StringID.h"

#define NO_CONTACT @"Sin Contacto"

MyAppAppDelegate *mAppDelegate;
@interface AddPeopleToAlarmViewController ()
{
    NSString *fullName, *countryNo, *lattitude, *longitude, *alarmName, *alarmSimNumber;
    int lblButtonId, smsCount;
    BOOL isAlreadyAssociated;
    UIButton *button;
    NSMutableArray *contacts, *mAlarmDetails;
    ABPeoplePickerNavigationController *picker;
    UIActionSheet *actionSheetView;
    
    MFMessageComposeViewController *msg1, *msg2, *msg3;
}
@end

@implementation AddPeopleToAlarmViewController
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
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: GET_ADDALARM_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: GET_ADDALARM_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
    AddAlarmModel *lAddAlarm = [AddAlarmModel getAddAlarmModel];
    if([[lAddAlarm.alarmSettings objectForKey:@"ResponseMessage"] isEqualToString:@"Success"]){
        NSMutableArray *arr = [[NSMutableArray alloc]initWithArray:[lData objectForKey:@"kPrefKeyForAlarmZoneIds"]];
        [arr addObject:[lData objectForKey:@"kPrefKeyForCoId"]];
        BOOL isExisting = NO;
        for(NSString *str in arr){
            if([str isEqual:lAddAlarm.alarmZoneId]){
                isExisting = YES;
                break;
            }
        }
        if(isExisting == NO){
            [arr addObject:[lAddAlarm.alarmSettings objectForKey:@"EmprasaId"]];
            [lData setObject:arr forKey:@"kPrefKeyForAlarmZoneIds"];
        }
        [mAppDelegate registerForPushWithTag:arr];
        arr = nil;
        if([contacts count] == 0){
            [mAppDelegate setChooseAlarmViewController];
        }
        else{
            if(isAlreadyAssociated == YES){
                [mAppDelegate setChooseAlarmViewController];
            }
            else{
                alarmName = [mAlarmDetails objectAtIndex:0];
                alarmSimNumber = [mAlarmDetails objectAtIndex:1];
                [mAlarmDetails removeAllObjects];
                if([contacts count] == [[lAddAlarm.alarmSettings objectForKey:@"NonMemberCount"] intValue]){
                    mAlarmDetails = contacts;
                }
                else{
                    for(NSString *contactService in [[lAddAlarm.alarmSettings objectForKey:@"NonMembers"] subarrayWithRange:NSMakeRange(0, [[lAddAlarm.alarmSettings objectForKey:@"NonMemberCount"] intValue])]){
                        for(NSDictionary *localContact in contacts){
                            if([[localContact objectForKey:@"phone"] isEqualToString:contactService]){
                                [mAlarmDetails addObject:localContact];
                            }
                        }
                    }
                }
                contacts = nil;
                NSArray *recipents = [NSArray arrayWithObject:alarmSimNumber];//alarmSimNumber
                NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
                NSString *message;
                if([mAlarmDetails count] == 1){
                    message = [NSString stringWithFormat:@"TEL:\n1.%@\n2.%@\n3.%@\n4.\n5.",[lData objectForKey:@"kPrefKeyForCountryNumber"],[lData objectForKey:@"kPrefKeyForPhone"],[[mAlarmDetails objectAtIndex:0] objectForKey:@"phone"]];
                }
                else if ([mAlarmDetails count] == 2){
                    message = [NSString stringWithFormat:@"TEL:\n1.%@\n2.%@\n3.%@\n4.%@\n5.",[lData objectForKey:@"kPrefKeyForCountryNumber"],[lData objectForKey:@"kPrefKeyForPhone"],[[mAlarmDetails objectAtIndex:0] objectForKey:@"phone"],[[mAlarmDetails objectAtIndex:1] objectForKey:@"phone"]];
                }
                else if ([mAlarmDetails count] == 3){
                    message = [NSString stringWithFormat:@"TEL:\n1.%@\n2.%@\n3.%@\n4.%@\n5.%@",[lData objectForKey:@"kPrefKeyForCountryNumber"],[lData objectForKey:@"kPrefKeyForPhone"],[[mAlarmDetails objectAtIndex:0] objectForKey:@"phone"],[[mAlarmDetails objectAtIndex:1] objectForKey:@"phone"],[[mAlarmDetails objectAtIndex:2] objectForKey:@"phone"]];
                }
                NSLog(@"\n%@",message);
                
                msg1 = nil;
                msg1= [[MFMessageComposeViewController alloc] init];
                msg1.messageComposeDelegate = self;
                [msg1 setRecipients:recipents];
                [msg1 setBody:message];
                // Present message view controller on screen
                [self presentViewController:msg1 animated:YES completion:nil];
                
            }
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Unable to add alarm. Try again." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Controller is dimissed :%@",controller);
        if(smsCount == 0){
            NSArray *recipents = [NSArray arrayWithObject:alarmSimNumber];//alarmSimNumber
            NSString *message = [NSString stringWithFormat:@"Zone information:\n1.Bunker360Alarm\n2.Bunker360Alarm\n3.Bunker360Alarm\n4."];
            NSLog(@"\n%@",message);
            msg2 = nil;
            msg2 = [[MFMessageComposeViewController alloc] init];
            msg2.messageComposeDelegate = self;
            [msg2 setRecipients:recipents];
            [msg2 setBody:message];
            // Present message view controller on screen
            [self presentViewController:msg2 animated:YES completion:nil];
            ++smsCount;
        }
        else if (smsCount == 1){
            NSArray *recipents = [NSArray arrayWithObject:alarmSimNumber];//alarmSimNumber
            NSString *message = [NSString stringWithFormat:@"30"];
            NSLog(@"\n%@",message);
            msg3 = nil;
            msg3 = [[MFMessageComposeViewController alloc] init];
            msg3.messageComposeDelegate = self;
            [msg3 setRecipients:recipents];
            [msg3 setBody:message];
            // Present message view controller on screen
            [self presentViewController:msg3 animated:YES completion:nil];
            ++smsCount;
        }
    }];
    switch (result) {
        case MessageComposeResultCancelled:
            if(smsCount == 2){
                [mAlarmDetails insertObject:alarmName atIndex:0];
                [mAppDelegate setSendRequestVCWithMobileNumbers:mAlarmDetails];
                mAlarmDetails = nil;
            }
            break;
        case MessageComposeResultFailed:
        {
            if(smsCount == 2){
                [mAlarmDetails insertObject:alarmName atIndex:0];
                [mAppDelegate setSendRequestVCWithMobileNumbers:mAlarmDetails];
                mAlarmDetails = nil;
            }
            break;
        }
        case MessageComposeResultSent:
            if(smsCount == 2){
                [mAlarmDetails insertObject:alarmName atIndex:0];
                [mAppDelegate setSendRequestVCWithMobileNumbers:mAlarmDetails];
                mAlarmDetails = nil;
            }
            break;
            
        default:
            break;
    }
}

-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)setData:(NSArray*)alarmDetails{
    mAlarmDetails = [[NSMutableArray alloc]initWithArray:alarmDetails];
    if([[mAlarmDetails lastObject] intValue] == 0){
        NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
        countryNo = [lData objectForKey:@"kPrefKeyForCountryNumber"];
        lattitude = [mAlarmDetails objectAtIndex:2];
        longitude = [mAlarmDetails objectAtIndex:3];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    smsCount = 0;
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    if([[mAlarmDetails lastObject] intValue] == 0){
        isAlreadyAssociated = NO;
        lblUserOROwnerName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedUsername"];
        NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
        lblUserNumber.text = [lData objectForKey:@"kPrefKeyForPhone"];
        contacts = [[NSMutableArray alloc]init];
        contact2.hidden = YES;
        contact3.hidden = YES;
        lblContactName1.hidden = YES;
        lblContactName2.hidden = YES;
        lblContactName3.hidden = YES;
        lblContactNumber1.hidden = YES;
        lblContactNumber2.hidden = YES;
        lblContactNumber3.hidden = YES;
        [contact1 setTitle:@"Agregar contacto" forState:UIControlStateNormal];
        [contact2 setTitle:@"Agregar contacto" forState:UIControlStateNormal];
        [contact3 setTitle:@"Agregar contacto" forState:UIControlStateNormal];
    }
    else if([[mAlarmDetails lastObject] intValue] == 1){
        [self addProgressIndicator];
        [self showProgressIndicator];
        mLabelLoading.text = @"Cargando...";
        [self performSelectorInBackground:@selector(associationAlarmMethod) withObject:nil];
    }
    contactDelete1.hidden = YES;
    contactDelete2.hidden = YES;
    contactDelete3.hidden = YES;
    contactDelete1IV.hidden = YES;
    contactDelete2IV.hidden = YES;
    contactDelete3IV.hidden = YES;
}

- (void)associationAlarmMethod{
    isAlreadyAssociated = YES;
    NSDictionary *dict = [mAlarmDetails objectAtIndex:2];
    lblUserNumber.text = [dict objectForKey:@"OwnerNumber"];
    [self initContact:4 andContact:lblUserNumber.text];
    NSArray *mobileNumbers = [[dict objectForKey:@"Numbers"] subarrayWithRange:NSMakeRange(0,[[dict objectForKey:@"NumbersCount"] intValue])];
    for (int i = 1; i < 4; i++) {//3 contacts
        if(i < [[dict objectForKey:@"NumbersCount"] intValue]){
            [self initContact:i andContact:[mobileNumbers objectAtIndex:i]];
        }
        else{
            [self initContact:i andContact:NO_CONTACT];
        }
    }
    contact1.enabled = NO;
    contact2.enabled = NO;
    contact3.enabled = NO;
    [contact1 setTitle:@"" forState:UIControlStateNormal];
    [contact2 setTitle:@"" forState:UIControlStateNormal];
    [contact3 setTitle:@"" forState:UIControlStateNormal];
    [self hideProgressIndicator];
}

- (void)initContact:(int)check andContact:(NSString*)contact{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    int found = 0;
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = ABAddressBookCreate( );
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        for(int i = 0; i < numberOfPeople; i++) {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
                NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
//                NSLog(@"Number: %@",[[phoneNumber componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]);
                if(([[[phoneNumber componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""] rangeOfString:contact].location != NSNotFound) || ([contact rangeOfString:[[phoneNumber componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]].location != NSNotFound))
                {
                    NSLog(@"Found");
                    found = 1;
                    if(check == 1){
                    lblContactName1.text =[NSString stringWithFormat:@"%@ %@", ((__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) ? (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) :[NSString stringWithFormat:@""]),((__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) ? (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) :[NSString stringWithFormat:@""])];
                    }
                    if(check == 2){
                        lblContactName2.text =[NSString stringWithFormat:@"%@ %@", ((__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) ? (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) :[NSString stringWithFormat:@""]),((__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) ? (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) :[NSString stringWithFormat:@""])];
                    }
                    if(check == 3){
                        lblContactName3.text =[NSString stringWithFormat:@"%@ %@", ((__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) ? (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) :[NSString stringWithFormat:@""]),((__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) ? (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) :[NSString stringWithFormat:@""])];
                    }
                    if(check == 4){
                        lblUserOROwnerName.text =[NSString stringWithFormat:@"%@ %@", ((__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) ? (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)) :[NSString stringWithFormat:@""]),((__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) ? (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty)) :[NSString stringWithFormat:@""])];
                    }
                    break;
                }
            }
        }
        if(found == 0){
            if(check == 1){
                lblContactName1.text = @"Sin Nombre";
            }
            if(check == 2){
                lblContactName2.text = @"Sin Nombre";
            }
            if(check == 3){
                lblContactName3.text = @"Sin Nombre";
            }
            if(check == 4){
                lblUserOROwnerName.text = @"Sin Nombre";
            }
        }
    }
    else {
        NSLog(@"Access denined.");
    }
    if(check==1){
        lblContactNumber1.text = contact;
    }
    if(check==2){
        lblContactNumber2.text = contact;
    }
    if(check==3){
        lblContactNumber3.text = contact;
    }
}

-(IBAction)BnAddContact:(id)sender{
//    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
//        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//            if (granted) {
//                NSLog(@"First Time Access");
//            } else {
//                NSLog(@"User Denined Access");
//            }
//        });
//    }
//    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
//        // The user has previously given access, add the contact
//        NSLog(@"User has previously has access");
//    }
//    else {
//        // The user has previously denied access
//        // Send an alert telling user to change privacy setting in settings app
//        NSLog(@"User has previously denied has access");
//    }
    button = sender;
    lblButtonId = (int)button.tag;
    if(!picker)
        picker =[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person{
    [self displayPerson:person];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 101){
        if(buttonIndex != actionSheet.destructiveButtonIndex){
            NSLog(@"%@",[actionSheet buttonTitleAtIndex:buttonIndex]);
            NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
            [self addMobileNumber:fullName withNumber:([[[actionSheet buttonTitleAtIndex:buttonIndex] componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""])];
        }
    }
}

// Implement this delegate method to make the Cancel button of the Address Book working.
-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//hiding status bar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
//

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    [self displayPerson:person];
    return NO;
}

- (void)displayPerson:(ABRecordRef)person{
    NSString* name = (__bridge_transfer   NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer   NSString*)ABRecordCopyValue(person,kABPersonLastNameProperty);
    NSLog(@"Contact:%@",name);
    [picker dismissViewControllerAnimated:YES completion:nil];
    if([(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty)) count]<=0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Contacto sin Numero" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        NSMutableString* phone;
        if([(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty)) count] > 1){
            fullName =[NSString stringWithFormat:@"%@ %@", (name ? name :[NSString stringWithFormat:@""]),(lastName ? lastName :[NSString stringWithFormat:@""])];
            
            actionSheetView = nil;
            if(!actionSheetView)
            actionSheetView = [[UIActionSheet alloc] initWithTitle:@"Elija uno de los números de contacto ..!"
                                                                         delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                                otherButtonTitles:nil];
            UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
            for(NSString *str in (((__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty))))){
                [actionSheetView addButtonWithTitle:str];
            }
            [actionSheetView addButtonWithTitle:@"Cancelar"];
            actionSheetView.tag = 101;
            actionSheetView.actionSheetStyle = UIActionSheetStyleAutomatic;
            actionSheetView.destructiveButtonIndex = [(((__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty)))) count];
            [actionSheetView showInView:window];
        }
        else{
            if(!phone)
                phone= [[NSMutableString alloc]initWithString:[(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonPhoneProperty)) objectAtIndex:0]];
            NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
            phone = [NSMutableString stringWithFormat:@"%@",[[phone componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]];
            NSLog(@"Phone:%@",phone);
            fullName =[NSString stringWithFormat:@"%@ %@", (name ? name :[NSString stringWithFormat:@""]),(lastName ? lastName :[NSString stringWithFormat:@""])];
            [self addMobileNumber:fullName withNumber:phone];
        }
    }
}

- (void)addMobileNumber:(NSString *)name withNumber:(NSString *)number{
    if (lblButtonId == 1) {
        if([self CheckNumberSelected:number] == 0){
            NSLog(@"Number 1:%@",number);
            lblContactName1.text = name;
            lblContactNumber1.text = number;
            [button setTitle:@"" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            NSDictionary *dict = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:name,number, nil] forKeys:[NSArray arrayWithObjects:@"name",@"phone", nil]];
            [contacts insertObject:dict atIndex:0];
            lblContactName1.hidden = NO;
            lblContactNumber1.hidden = NO;
            contact2.hidden = NO;
            contactDelete1.hidden = NO;
            contactDelete1IV.hidden = NO;
            contact1.enabled = NO;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:name message:@"Ya se ha ańadido" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else if (lblButtonId == 2){
        if([self CheckNumberSelected:number] == 0){
            NSLog(@"Number 2:%@",number);
            lblContactName2.text = name;
            lblContactNumber2.text = number;
            [button setTitle:@"" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            NSDictionary *dict = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:name,number, nil] forKeys:[NSArray arrayWithObjects:@"name",@"phone", nil]];
            [contacts insertObject:dict atIndex:1];
            lblContactName2.hidden = NO;
            lblContactNumber2.hidden = NO;
            contact3.hidden = NO;
            contactDelete2.hidden = NO;
            contactDelete2IV.hidden = NO;
            contact2.enabled = NO;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:name message:@"Ya se ha ańadido" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        if([self CheckNumberSelected:number] == 0){
            NSLog(@"Number 3:%@",number);
            lblContactName3.text = name;
            lblContactNumber3.text = number;
            [button setTitle:@"" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            NSDictionary *dict = [[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:name,number, nil] forKeys:[NSArray arrayWithObjects:@"name",@"phone", nil]];
            [contacts insertObject:dict atIndex:2];
            lblContactName3.hidden = NO;
            lblContactNumber3.hidden = NO;
            contactDelete3.hidden = NO;
            contactDelete3IV.hidden = NO;
            contact3.enabled = NO;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:name message:@"Ya se ha ańadido" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    NSLog(@"Contacts:%@\ncount:%d",contacts,(int)[contacts count]);
}

- (int)CheckNumberSelected:(NSString *)mobile{
    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
    if([contacts count]>0){
        for(NSDictionary *dict in contacts){
            if([[dict objectForKey:@"phone"] isEqualToString:mobile] || ([mobile rangeOfString:[lData objectForKey:@"kPrefKeyForPhone"]].location != NSNotFound) || ([[lData objectForKey:@"kPrefKeyForPhone"] rangeOfString:mobile].location != NSNotFound)){
                return 1;
            }
        }
    }
    else if (([mobile rangeOfString:[lData objectForKey:@"kPrefKeyForPhone"]].location != NSNotFound) || ([[lData objectForKey:@"kPrefKeyForPhone"] rangeOfString:mobile].location != NSNotFound))
        return 1;
    return 0;
}

- (IBAction)BnDeleteContact:(id)sender{
    if([sender tag] == 1){
        [contacts removeObjectAtIndex:0];
        [self reloadButtons];
    }
    else if ([sender tag] == 2){
        [contacts removeObjectAtIndex:1];
        [self reloadButtons];
    }
    else if ([sender tag] == 3){
        [contacts removeObjectAtIndex:2];
        [self reloadButtons];
    }
}

-(void)reloadButtons{
    int count = (int)[contacts count];
    NSLog(@"Count:%d",count);
    if(count == 0){
        [contacts removeAllObjects];
        contact2.hidden = YES;
        contact3.hidden = YES;
        contactDelete1.hidden = YES;
        contactDelete2.hidden = YES;
        contactDelete3.hidden = YES;
        contactDelete1IV.hidden = YES;
        contactDelete2IV.hidden = YES;
        contactDelete3IV.hidden = YES;
        lblContactName1.hidden = YES;
        lblContactName2.hidden = YES;
        lblContactName3.hidden = YES;
        lblContactNumber1.hidden = YES;
        lblContactNumber2.hidden = YES;
        lblContactNumber3.hidden = YES;
        contact1.enabled = YES;
        [contact1 setTitle:@"Agregar contacto" forState:UIControlStateNormal];
        [contact1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else if (count == 1){
        contact3.hidden = YES;
        contact1.hidden = NO;
        contact2.hidden = NO;
        contactDelete1.hidden = NO;
        contactDelete2.hidden = YES;
        contactDelete3.hidden = YES;
        contactDelete1IV.hidden = NO;
        contactDelete2IV.hidden = YES;
        contactDelete3IV.hidden = YES;
        lblContactName1.hidden = NO;
        lblContactName2.hidden = YES;
        lblContactName3.hidden = YES;
        lblContactNumber1.hidden = NO;
        lblContactNumber2.hidden = YES;
        lblContactNumber3.hidden = YES;
        NSDictionary *dict = [contacts objectAtIndex:count-1];
        [contact1 setTitle:@"" forState:UIControlStateNormal];
        lblContactName1.text = [dict objectForKey:@"name"];
        lblContactNumber1.text = [dict objectForKey:@"phone"];
        NSLog(@"%@",[dict objectForKey:@"phone"]);
        [contact1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        contact1.enabled = NO;
        [contact2 setTitle:@"Agregar contacto" forState:UIControlStateNormal];
        [contact2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        contact2.enabled = YES;
    }
    else if (count == 2){
        NSLog(@"%@",contacts);
        contact1.hidden = NO;
        contact2.hidden = NO;
        contact3.hidden = NO;
        contactDelete1.hidden = NO;
        contactDelete2.hidden = NO;
        contactDelete3.hidden = YES;
        contactDelete1IV.hidden = NO;
        contactDelete2IV.hidden = NO;
        contactDelete3IV.hidden = YES;
        lblContactName1.hidden = NO;
        lblContactName2.hidden = NO;
        lblContactName3.hidden = YES;
        lblContactNumber1.hidden = NO;
        lblContactNumber2.hidden = NO;
        lblContactNumber3.hidden = YES;
        NSDictionary *dict = [contacts objectAtIndex:0];
        NSLog(@"%@",dict);
        [contact1 setTitle:@"" forState:UIControlStateNormal];
        [contact1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        contact1.enabled = NO;
        lblContactName1.text = [dict objectForKey:@"name"];
        lblContactNumber1.text = [dict objectForKey:@"phone"];
        NSLog(@"%@",[dict objectForKey:@"phone"]);
        dict = [contacts objectAtIndex:1];
        [contact2 setTitle:@"" forState:UIControlStateNormal];
        [contact2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        contact2.enabled = NO;
        lblContactName2.text = [dict objectForKey:@"name"];
        lblContactNumber2.text = [dict objectForKey:@"phone"];
        NSLog(@"%@",[dict objectForKey:@"phone"]);
        [contact3 setTitle:@"Agregar contacto" forState:UIControlStateNormal];
        [contact3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        contact3.enabled = YES;
    }
}

-(IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setChooseAlarmViewController];
}

-(IBAction)BnSubmitTapped:(id)sender{
    //    if([numbers count]>0){
    if([[mAlarmDetails lastObject] intValue] == 0){
        [mAlarmDetails removeLastObject];
        [mAlarmDetails addObject:countryNo];
        if([contacts count] == 0){
            [mAlarmDetails addObject:NO_CONTACT];
            [mAlarmDetails addObject:NO_CONTACT];
            [mAlarmDetails addObject:NO_CONTACT];
        }
        else if([contacts count] == 1){
            [mAlarmDetails addObject:lblContactNumber1.text];
            [mAlarmDetails addObject:NO_CONTACT];
            [mAlarmDetails addObject:NO_CONTACT];
        }
        else if ([contacts count] == 2){
            [mAlarmDetails addObject:lblContactNumber1.text];
            [mAlarmDetails addObject:lblContactNumber2.text];
            [mAlarmDetails addObject:NO_CONTACT];
        }
        else if ([contacts count] == 3){
            [mAlarmDetails addObject:lblContactNumber1.text];
            [mAlarmDetails addObject:lblContactNumber2.text];
            [mAlarmDetails addObject:lblContactNumber3.text];
        }
    }
    else if([[mAlarmDetails lastObject] intValue] == 1){
        [mAlarmDetails removeLastObject];
        NSDictionary *dict = [mAlarmDetails lastObject];
        [mAlarmDetails removeLastObject];
        countryNo = [dict objectForKey:@"CountryCode"];
        lattitude = [dict objectForKey:@"Lat"];
        longitude = [dict objectForKey:@"Long"];
        [mAlarmDetails addObject:countryNo];
        [mAlarmDetails addObject:lattitude];
        [mAlarmDetails addObject:longitude];
        [mAlarmDetails addObject:lblContactNumber1.text];
        [mAlarmDetails addObject:lblContactNumber2.text];
        [mAlarmDetails addObject:lblContactNumber3.text];
    }
    NSUserDefaults *lMobileData = [NSUserDefaults standardUserDefaults];
    NSLog(@"Mobile No:%@",[lMobileData stringForKey:@"kPrefKeyForPhone"]);
    NSLog(@"UserName:%@",[lMobileData stringForKey:@"kPrefKeyForUpdatedUsername"]);
    AlarmParam *lAlarmParam = [[AlarmParam alloc]init];
    lAlarmParam.alarmName = [[mAlarmDetails objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    lAlarmParam.alarmNumber = [mAlarmDetails objectAtIndex:1];
    lAlarmParam.number1 = countryNo;
    lAlarmParam.number2 = [mAlarmDetails objectAtIndex:5];
    lAlarmParam.number3 = [mAlarmDetails objectAtIndex:6];
    lAlarmParam.number4 = [mAlarmDetails objectAtIndex:7];
    lAlarmParam.lattitude = lattitude;
    lAlarmParam.longitude = longitude;
    lAlarmParam.username = [lMobileData stringForKey:@"kPrefKeyForUpdatedUsername"];
    lAlarmParam.userNumber = [lMobileData stringForKey:@"kPrefKeyForPhone"];
    lAlarmParam.ownerNumber = lblUserNumber.text;
    [self addProgressIndicator];
    [self showProgressIndicator];
    AddAlarmModel *lAddAlarm = [AddAlarmModel getAddAlarmModel];
    [lAddAlarm callGetAddAlarmWebservice:lAlarmParam];
    mLabelLoading.text = @"Agregando...";
    //    }
    //    else{
    //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Al menos contacto onc tiene que seleccionar." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    //        [alert show];
    //    }
}

@end

