//
//  AddPeopleViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 26/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "PeopleViewController.h"
#import "MyAppAppDelegate.h"
#import "StringID.h"
#import "GroupsTableCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define GROUPCONTACTS_URL @"{\"Id\":\"%@\"}"
#define ADDCONTACTGROUP_URL @"{\"Id\":\"%@\",\"MemberName\":\"%@\",\"MemberEmail\":\"%@\"}"
#define PUSH_NOTIFI_URL @"{\"Message\":\"%@\",\"Handle\":\"%@\",\"GroupId\":\"%@\"}"
#define DELETEPERSON_URL @"{\"Id\":\"%@\",\"MemberName\":\"%@\"}"

MyAppAppDelegate *mAppAppdelegate;

@interface PeopleViewController ()< ABPeoplePickerNavigationControllerDelegate,ABPersonViewControllerDelegate,
ABNewPersonViewControllerDelegate, ABUnknownPersonViewControllerDelegate>{
    NSArray *lGroupDetails;
    NSMutableArray *lGroupContactsNames, *lGroupContactsNumbers;
    NSMutableString *contactName, *contactNumber;
    UISwipeGestureRecognizer *swipeDelete;
    NSString *deletePersonName;
    NSString *useString;
    int personsCount,option,index;
    UIAlertView *alertBox;
    UIActionSheet *actionSheetView;
}

@property (nonatomic, assign) ABAddressBookRef addressBook;

@end

@implementation PeopleViewController
- (void)setGroupDetails:(NSArray*)groupDetails{
    lGroupDetails = groupDetails;
    NSLog(@"%@",lGroupDetails);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an address book object
    _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    mAppAppdelegate = [MyAppAppDelegate getAppDelegate];
    
    lblGroupName.text = [lGroupDetails objectAtIndex:1];
    
    lGroupContactsNames = [[NSMutableArray alloc]init];
    lGroupContactsNumbers = [[NSMutableArray alloc]init];
    
    //    alertBox = [[UIAlertView alloc]init];
    
    lTableView.hidden = YES;
    
    swipeDelete = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:nil];
    [swipeDelete setDirection: UISwipeGestureRecognizerDirectionLeft];
    [lTableView addGestureRecognizer:swipeDelete];
    
    [self addProgressIndicator];
    [self showProgressIndicator];
    mLabelLoading.text = @"Cargando...";
    [self performSelectorInBackground:@selector(callGroupContactsWebService) withObject:nil];
    //    option = 0;
    //    PeopleModel *lGroupsList = [PeopleModel getPeopleModel];
    //    [lGroupsList callGroupContactsWebService:[NSString stringWithFormat:@"%@",[lGroupDetails objectAtIndex:0]]];
    
    
    // Do any additional setup after loading the view.
}

//- (void) loadData{
//    PeopleModel *lGroupContactsList = [PeopleModel getPeopleModel];
//    NSArray *namesArray = [lGroupContactsList.groupsContacts objectForKey:@"MemberNames"];
//    NSArray *numbersArray = [lGroupContactsList.groupsContacts objectForKey:@"MemberPhones"];
//    [lGroupContactsNames removeAllObjects];
//    [lGroupContactsNumbers removeAllObjects];
//    lGroupContactsNames = [[NSMutableArray alloc]initWithArray:[namesArray subarrayWithRange:NSMakeRange(1, personsCount)]];
//    lGroupContactsNumbers = [[NSMutableArray alloc]initWithArray:[numbersArray subarrayWithRange:NSMakeRange(1, personsCount)]];
//
//    [lTableView reloadData];
//    [self hideProgressIndicator];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return personsCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = 0;
    height = 60;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    GroupsTableCell *cell = (GroupsTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray * MyCustomCellNib;
        MyCustomCellNib = [[NSBundle mainBundle] loadNibNamed:@"GroupsTableCell" owner:self options:nil];
        cell = (GroupsTableCell *)[MyCustomCellNib lastObject];
    }
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    if([lGroupContactsNames count]>0){
        cell.personName.text = [lGroupContactsNames objectAtIndex:indexPath.row];// stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //        cell.pendingIcon.contentMode = UIViewContentModeCenter;
        //        cell.pendingIcon.contentMode = UIViewContentModeScaleAspectFit;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [mAppAppdelegate setPeopleLocationVCWithMobileNumber:[NSArray arrayWithObjects:[lGroupDetails objectAtIndex:0],[lGroupDetails objectAtIndex:1],[lGroupContactsNumbers objectAtIndex:indexPath.row], [lGroupContactsNames objectAtIndex:indexPath.row], nil]];
    [self deallocMemory];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self addProgressIndicator];
        [self showProgressIndicator];
        mLabelLoading.text = @"Borrando...";
        index = (int)indexPath.row;
        [self performSelectorInBackground:@selector(callDeleteContactFromGroupWebService) withObject:nil];
    }
}

- (IBAction)BnShowPersonsMapTapped:(id)sender{
    [mAppAppdelegate setGroupMapVCWithGroupDetails:lGroupDetails];
    [self deallocMemory];
}

- (IBAction)BnAddContactTapped:(id)sender{
    if(!contactName)
        contactName = [[NSMutableString alloc]init];
    if(!contactNumber)
        contactNumber = [[NSMutableString alloc]init];
    [self chooseContact];
}

//hiding status bar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}
///

- (void)chooseContact{
    ABPeoplePickerNavigationController *picker =[[ABPeoplePickerNavigationController alloc] init];
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
//    if([(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty)) count] == 0){
//        ABPersonViewController *picker = [[ABPersonViewController alloc] init];
//        picker.personViewDelegate = self;
//        picker.displayedPerson = person;
//        // Allow users to edit the person’s information
//        picker.allowsEditing = YES;
//        [peoplePicker pushViewController:picker animated:YES];
//    }
//    else{
        [self displayPerson:person];
//    }
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    [self displayPerson:person]; //calls displayPerson:(ABRecordRef)person to show contact's information in the app
    [self dismissViewControllerAnimated:NO completion:NULL];
    peoplePicker = nil;
    return YES;
}

- (void)displayPerson:(ABRecordRef)person
{
    NSString* name = (__bridge_transfer   NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer   NSString*)ABRecordCopyValue(person,kABPersonLastNameProperty);
    NSLog(@"Contact:%@",name);
    if([(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty)) count]<=0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Sin email" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
    else{
        [contactName setString:[NSString stringWithFormat:@"%@ %@", (name ? name :[NSString stringWithFormat:@""]),(lastName ? lastName :[NSString stringWithFormat:@""])]];
        if([(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty)) count] > 1){
            if(!actionSheetView)
                actionSheetView = [[UIActionSheet alloc] initWithTitle:@"Elija una de las eMailid ..!"
                                                              delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                     otherButtonTitles:nil];
            UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
            for(NSString *str in (((__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty))))){
                [actionSheetView addButtonWithTitle:str];
            }
            [actionSheetView addButtonWithTitle:@"Cancelar"];
            actionSheetView.tag = 101;
            actionSheetView.actionSheetStyle = UIActionSheetStyleAutomatic;
            actionSheetView.destructiveButtonIndex = [(((__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty)))) count];
            [actionSheetView showInView:window];
        }
        else{
            [contactNumber setString:[(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty)) objectAtIndex:0]];
            if([[[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedeMail"] isEqualToString:contactNumber]){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Solicite no procesada. Elegido su propio correo electrónico de identificación." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
                [contactName setString:[NSString stringWithFormat:@"%@",nil]];
                [contactNumber setString:[NSString stringWithFormat:@"%@",nil]];
            }
            else{
                alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:[NSString stringWithFormat:@"¿ Quieres agregar a %@ %@ al Grupo %@?", [(name ? name :[NSString stringWithFormat:@""]) uppercaseString],[(lastName ? lastName :[NSString stringWithFormat:@""]) uppercaseString],[[lGroupDetails objectAtIndex:1] uppercaseString]] delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Aceptar", nil];
                alertBox.tag = 1;
                [alertBox show];
            }
        }
    }
    NSLog(@"Contacts:\n\n%@\n\n%@",contactName,contactNumber);
    
    //    NSMutableArray *numbers = [[NSMutableArray alloc]init];
    //    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    //    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
    //    {
    //        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
    //        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
    //        NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
    //        //CFRelease(phones);
    //        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
    //        CFRelease(phoneNumberRef);
    //        CFRelease(locLabel);
    //        NSLog(@"  - %@ (%@)", phoneNumber, phoneLabel);
    //        [numbers addObject:phoneNumber];
    //    }
    //    if([numbers count]<=0){
    //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Sin contacto" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    //        [alert show];
    //    }
    //    else{
    //        NSMutableString *phone = [[NSMutableString alloc]initWithString:[numbers objectAtIndex:0]];
    //        NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    //        phone = [NSMutableString stringWithFormat:@"%@",[[phone componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""]];
    //        NSLog(@"%@",phone);
    //        [contactName setString:[NSString stringWithFormat:@"%@ %@", (name ? name :[NSString stringWithFormat:@""]),(lastName ? lastName :[NSString stringWithFormat:@""])]];
    //        [contactNumber setString:phone];
    //        NSString *str = [NSString stringWithFormat:@"¿ Quieres agregar a %@ %@ al Grupo %@?", [(name ? name :[NSString stringWithFormat:@""]) uppercaseString],[(lastName ? lastName :[NSString stringWithFormat:@""]) uppercaseString],[[lGroupDetails objectAtIndex:1] uppercaseString]];
    //
    //        alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:str delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Aceptar", nil];
    //        alertBox.tag = 1;
    //        [alertBox show];
    //        NSLog(@"Phone:%@",phone);
    //    }
    //    NSLog(@"Contacts:\n\n%@\n\n%@",contactName,contactNumber);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == 101){
        if(buttonIndex != actionSheet.destructiveButtonIndex){
            NSLog(@"%@",[actionSheet buttonTitleAtIndex:buttonIndex]);
            contactNumber = [NSMutableString stringWithString:[actionSheet buttonTitleAtIndex:buttonIndex]];
            alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:[NSString stringWithFormat:@"¿ Quieres agregar a %@ al Grupo %@?", [contactName uppercaseString],[[lGroupDetails objectAtIndex:1] uppercaseString]] delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Aceptar", nil];
            alertBox.tag = 1;
            [alertBox show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        if(buttonIndex == 1){
            [self addProgressIndicator];
            [self showProgressIndicator];
            mLabelLoading.text = @"Agregando...";
            [self performSelectorInBackground:@selector(callAddContactGroupWebService) withObject:nil];
        }
        else{
            [contactName setString:[NSString stringWithFormat:@"%@",nil]];
            [contactNumber setString:[NSString stringWithFormat:@"%@",nil]];
            NSLog(@"Contacts:\n\n%@\n\n%@",contactName,contactNumber);
        }
    }
    //    else if (alertView.tag == 2){
    //        //        NSUserDefaults *lUserDefaults = [NSUserDefaults standardUserDefaults];
    //        [self addProgressIndicator];
    //        [self showProgressIndicator];
    //        mLabelLoading.text = @"Enviando...";
    //        [self performSelectorInBackground:@selector(callPushServiceForRegdUserWebService) withObject:nil];
    //    }
    else if (alertView.tag == 3){
        [mAppAppdelegate setGroupsListVCAsWindowRootVC];
    }
    else if (alertView.tag == 4){
        [self addProgressIndicator];
        [self showProgressIndicator];
        mLabelLoading.text = @"Cargando...";
        [self callGroupContactsWebService];
    }
}

- (void)callDeleteContactFromGroupWebService{
    NSString *urlString = [NSString stringWithFormat:@"%@EliminarGroupMember",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:DELETEPERSON_URL,[lGroupDetails objectAtIndex:0],[lGroupContactsNames objectAtIndex:index]];
    
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
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"Output: %@",returnString);
    [self hideProgressIndicator];
    if(returnString.length > 0){
        if([[returnString substringWithRange:NSMakeRange(1, returnString.length-2)] isEqualToString:@"Success"]){
            alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Eliminado con éxito" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            alertBox.tag = 4;
            [alertBox show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Eliminado sin éxito." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        [self showNetworkError];
    }
    //    mDeletePerson = [returnString substringWithRange:NSMakeRange(1, returnString.length-2)];
}

- (void)callPushServiceForRegdUserWebService{
    NSUserDefaults *lData = [NSUserDefaults standardUserDefaults];
    NSString *urlString = [NSString stringWithFormat:@"%@PushNotification",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:PUSH_NOTIFI_URL,[NSString stringWithFormat:@"%@ quiere que pertenezcas a su Grupo %@ en eMaguen",[lData valueForKey:@"kPrefKeyForUpdatedUsername"],[lGroupDetails objectAtIndex:1]],useString,[lGroupDetails objectAtIndex:0]];
    
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
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"Output: %@",returnString);
    [self hideProgressIndicator];
    if(returnString.length > 0){
        if([[returnString substringWithRange:NSMakeRange(1, returnString.length-2)] isEqualToString:@"Success"]){
            alertBox = [[UIAlertView alloc]initWithTitle:contactName message:@"Sacar este mensaje" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            alertBox.tag = 3;
            [alertBox show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Notificación de inserción envió sin éxito." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        [self showNetworkError];
    }
    //    mPushReply = [returnString substringWithRange:NSMakeRange(1, returnString.length-2)];
}

- (void)callAddContactGroupWebService{
    NSString *urlString = [NSString stringWithFormat:@"%@AgregarGroupMember",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:ADDCONTACTGROUP_URL,[lGroupDetails objectAtIndex:0],contactName,contactNumber];
    
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
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"Output: %@",returnString);
    [self hideProgressIndicator];
    if(returnString.length > 0){
        NSData* data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSLog(@"Response: %@",dict);
        NSError *error;
        NSDictionary *mAddedOrNotContact = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"%@",mAddedOrNotContact);
        if([[mAddedOrNotContact objectForKey:@"Response"] isEqualToString:@"Success"]){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:contactName message:@"Se ha enviado la invitación" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
            //            if([[mAddedOrNotContact objectForKey:@"Id"] intValue] == -1)//[lAddContact.addedOrNotContact isEqualToString:@"Non-Member"])
            //            {
            //                NSUserDefaults *lUDefaults = [NSUserDefaults standardUserDefaults];
            //                //testing message
            //                if(![MFMessageComposeViewController canSendText]) {
            //                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Su dispositivo no admite SMS!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            //                    [alert show];
            //                    return;
            //                }
            //                NSString *message = [NSString stringWithFormat:@"%@ te ha invitado a unirte al su %@ Instala eMaguén desde aquí : www.eMaguen.com y únete.",[lUDefaults stringForKey:@"kPrefKeyForUpdatedUsername"],[lGroupDetails objectAtIndex:1]];
            //
            //                MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            //                messageController.messageComposeDelegate = self;
            //                [messageController setRecipients:[NSArray arrayWithObject:contactNumber]];
            //                [messageController setBody:message];
            //                // Present message view controller on screen
            //                [self presentViewController:messageController animated:YES completion:nil];
            //            }
            //            else
            //            {
            //                useString = [mAddedOrNotContact objectForKey:@"Id"];
            //                //                alertBox = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Contacto agregado con éxito" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles:nil];
            //                //                alertBox.tag = 2;
            //                //                [alertBox show];
            //                [self addProgressIndicator];
            //                [self showProgressIndicator];
            //                mLabelLoading.text = @"Enviando...";
            //                [self performSelectorInBackground:@selector(callPushServiceForRegdUserWebService) withObject:nil];
            //            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Contactar no añadido" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        [contactName setString:[NSString stringWithFormat:@"%@",nil]];
        [contactNumber setString:[NSString stringWithFormat:@"%@",nil]];
    }
    else{
        [self showNetworkError];
    }
}

- (void)callGroupContactsWebService{
    NSString *urlString = [NSString stringWithFormat:@"%@ListaGroupMember",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:GROUPCONTACTS_URL,[NSString stringWithFormat:@"%@",[lGroupDetails objectAtIndex:0]]];
    
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
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"Output: %@",returnString);
    [self hideProgressIndicator];
    if(returnString.length > 0){
        NSData* data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSLog(@"Response: %@",dict);
        NSError *error;
        NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        [lGroupContactsNames removeAllObjects];
        [lGroupContactsNumbers removeAllObjects];
        if(([[lJSONArray objectForKey:@"GroupMemberCount"] intValue] - 1) <= 0){
            lTableView.hidden = YES;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Sin Contactos" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        else{
            personsCount = [[lJSONArray objectForKey:@"GroupMemberCount"] intValue] - 1;
            lGroupContactsNames = [[NSMutableArray alloc]initWithArray:[[lJSONArray objectForKey:@"MemberNames"] subarrayWithRange:NSMakeRange(1, personsCount)]];
            lGroupContactsNumbers = [[NSMutableArray alloc]initWithArray:[[lJSONArray objectForKey:@"MemberPhones"] subarrayWithRange:NSMakeRange(1, personsCount)]];
            lTableView.hidden = NO;
            [lTableView reloadData];
        }
    }
    else{
        [self showNetworkError];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            [mAppAppdelegate setGroupsListVCAsWindowRootVC];
            break;
        case MessageComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error al enviar SMS!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case MessageComposeResultSent:
            [mAppAppdelegate setGroupsListVCAsWindowRootVC];
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)BnBackTapped:(id)sender{
    [mAppAppdelegate setGroupsListVCAsWindowRootVC];
    [self deallocMemory];
}

- (void)deallocMemory{
    lGroupDetails = nil;
    lGroupContactsNames = nil;
    lGroupContactsNumbers = nil;
    contactName = nil;
    contactNumber = nil;
    deletePersonName = nil;
}

#pragma mark ABUnknownPersonViewControllerDelegate methods
// Dismisses the picker when users are done creating a contact or adding the displayed person properties to an existing contact.
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
    [self.navigationController popViewControllerAnimated:YES];
}

// Does not allow users to perform default actions such as emailing a contact, when they select a contact property.
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
                    property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    return NO;
}

#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
