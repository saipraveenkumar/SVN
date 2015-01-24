//
//  AddEventViewControllerDetailsViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 13/10/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "AddEventDetailsViewController.h"
#import "EventsViewController.h"
#import "UserDataModel.h"
#import "AddEventModel.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "StringID.h"
#import "MyAppAppDelegate.h"
#import "GetEventsModel.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define MAX_LENGTH 2000

MyAppAppDelegate *mAppDelegate;

@interface AddEventDetailsViewController ()
{
    EventAddParam *lEventAddParam;
    UIDatePicker *pickerView;
    NSString *lDateTime;
    UIImage *imgForEvent;
    NSString *imageName;
    float coordlatt,coordlongi;
    int mCategoryId;
    NSMutableString *location;
    UIView *datePickerMainView;
    UITapGestureRecognizer *tap;
    UIImagePickerController *imagePicker;
}
@end

@implementation AddEventDetailsViewController

-(void)CoordDetails:(float)latt and:(float)longi{
    coordlatt = latt;
    coordlongi = longi;
    NSLog(@"Latt and Long:%f,%f",coordlatt,coordlongi);
    if(!location)
        location = [[NSMutableString alloc]init];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc]initWithLatitude:coordlatt longitude:coordlongi] completionHandler:^(NSArray *placemarks, NSError *error) {
        NSMutableString *str1;
        if(!str1)
            str1= [[NSMutableString alloc]init];
        if (error) {
            NSLog(@"Geocode failed with error: %@", error);
            location = [NSMutableString stringWithFormat:@"Not Available."];
            return;
        }
        if (placemarks && placemarks.count > 0)
        {
            CLPlacemark *placemark = [placemarks lastObject];
            NSDictionary *addressDictionary =
            placemark.addressDictionary;
            //might get error
            BOOL isFirst = YES;
            for(NSString *str in [addressDictionary objectForKey:@"FormattedAddressLines"]){
                if(isFirst == YES){
                    [str1 appendString:str];
                    isFirst = NO;
                }
                else
                    [str1 appendString:[NSString stringWithFormat:@", %@",str]];
            }
        }
        location = [[NSMutableString alloc]initWithString:str1];
        str1 = nil;
    }];
    lLabelCategory.text = @"Selecto evento";
    lLabelDateTime.text = @"Date                             Time";
    imageName = @"";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self addNotificationHandlers];
        [self addProgressIndicator];
        [self hideProgressIndicator];
    }
    return self;
}

-(void) addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFinish:) name: ADD_EVENT_FINISHED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onLoginFailed:) name: ADD_EVENT_FAILED object: nil];
}

-(void) removeNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

-(void)onLoginFinish:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
}
-(void)onLoginFailed:(NSNotification*) lNotification
{
    [self hideProgressIndicator];
    [self showNetworkError];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!mAppDelegate)
        mAppDelegate = [MyAppAppDelegate getAppDelegate];
    if(!lEventAddParam)
        lEventAddParam = [[EventAddParam alloc] init];
    lTextView.delegate = self;
    lTextView.textAlignment = NSTextAlignmentJustified;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss Z"];
    
    lLabelDateTime.text = [dateFormatter stringFromDate: [NSDate date]];
    
    [lTextView setFont:[UIFont systemFontOfSize:14]];
    lTextView.text = @"Entrad Descripción del evento aquí";
    
    UIColor *blueColor = [self colorFromHexString:@"#2871b4"];
    
    lTextView.textColor = blueColor;
    lLabelCategory.textColor = blueColor;
    lLabelDateTime.textColor = blueColor;
    lLabelGallery.textColor = blueColor;
    lLabelPhoto.textColor = blueColor;
    
    //    lButtonGuardar.titleLabel.textColor = blueColor;
    if(!tap)
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)handleTap:(id)sender{
    [self.view endEditing:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(IBAction)BnSelectEvent{
    UIActionSheet *actionSheetView = [[UIActionSheet alloc] initWithTitle:@"Tipo de evento:"
                                                                 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
                                                        otherButtonTitles: @"Robo", @"Choque de Vehículos", @"Persona Sospechosa", @"Obra", @"Evento Genérico", @"Cancelar", nil];
    actionSheetView.actionSheetStyle = UIActionSheetStyleAutomatic;
    actionSheetView.destructiveButtonIndex = 5;
    actionSheetView.tag = 1;
    [actionSheetView showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 1){
        if (buttonIndex == 0){
            lImageCategory.image = [UIImage imageNamed:@"pin_Robo.png"];
            lLabelCategory.text = @"Robo";
        }
        else if (buttonIndex == 1){
            lImageCategory.image = [UIImage imageNamed:@"pin_Choque.png"];
            lLabelCategory.text = @"Choque de Vehículos";
        }
        else if (buttonIndex == 2){
            lImageCategory.image = [UIImage imageNamed:@"pin_Sospechoso.png"];
            lLabelCategory.text = @"Persona Sospechosa";
        }
        else if (buttonIndex == 3){
            lImageCategory.image = [UIImage imageNamed:@"pin_obra.png"];
            lLabelCategory.text = @"Obra";
        }
        else if (buttonIndex == 4){
            lImageCategory.image = [UIImage imageNamed:@"Generico.png"];
            lLabelCategory.text = @"Evento Genérico";
        }
    }
}


- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    UIImageWriteToSavedPhotosAlbum([info objectForKey:@"UIImagePickerControllerOriginalImage"], self,@selector(image:finishedSavingWithError:contextInfo:),nil);
    if([info objectForKey:@"UIImagePickerControllerOriginalImage"]){
        imgForEvent = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        UIImage *tempImage = imgForEvent;
        previewImg.image = tempImage;
        [previewImg setNeedsDisplay];
        imageName = [NSString stringWithFormat:@"ios%d.png",[self generateCurrentTimeStamp]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (int)generateCurrentTimeStamp{
    int timestamp = [[NSDate date] timeIntervalSince1970];
    return timestamp;
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error al guardar la imagen / vídeo" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)BnOpenCarema:(id)sender{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //        NSLog(@"Camera");
        if(!imagePicker)
            imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No existe Cámara." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

-(IBAction)BnChooseImageFromGallery:(id)sender{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        if(!imagePicker)
            imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"No hay imágenes en la Galería." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (void) cancel{
    //    NSLog(@"Cancel");
    [lTextView resignFirstResponder];
}

- (void) save{
    //    NSLog(@"Save");
    [lTextView resignFirstResponder];
    
    CGRect tempFrame = lTextView.frame;
    tempFrame.origin.y = 0;
    CGPoint scrollPoint = CGPointMake(0.0, tempFrame.origin.y);
    [lTextView setContentOffset:scrollPoint animated:YES];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    previewImg.hidden = YES;
    lLabelGallery.hidden = YES;
    lButtonOpenCamera.hidden = YES;
    lButtonOpenGallery.hidden = YES;
    lLabelPhoto.hidden = YES;
    textViewImageView.hidden = YES;
    lLabelCategory.hidden = YES;
    lImageCategory.hidden = YES;
    lImageVImg.hidden = YES;
    lButtonBack.hidden = YES;
    lImgVewBack.hidden = YES;
    lImgViewChooseEvent.hidden = YES;
    lButtonEvents.hidden = YES;
    lTextView.backgroundColor = [UIColor whiteColor];
    lTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    lTextView.layer.borderWidth = 1.0f;
    lTextView.layer.cornerRadius = 3.0f;
    //    lTextView.text = @"";
    if(iPhone5){
        [lTextView setFrame:CGRectMake(20, 89, 280, 170)];
    }
    else{
        [lTextView setFrame:CGRectMake(20, 75, 280, 138)];
    }
    if([lTextView.text isEqualToString:@"Entrad Descripción del evento aquí"]){
        lTextView.text = @"";
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    lTextView.layer.borderColor = [[UIColor clearColor] CGColor];
    if(iPhone5){
        [lTextView setFrame:CGRectMake(28, 310, 266, 115)];
    }
    else{
        [lTextView setFrame:CGRectMake(27, 282, 266, 85)];
    }
    lTextView.backgroundColor = [UIColor clearColor];
    previewImg.hidden = NO;
    lLabelGallery.hidden = NO;
    lButtonOpenCamera.hidden = NO;
    lButtonOpenGallery.hidden = NO;
    lLabelPhoto.hidden = NO;
    textViewImageView.hidden = NO;
    lImageVImg.hidden = NO;
    lLabelCategory.hidden = NO;
    lImageCategory.hidden = NO;
    lButtonBack.hidden = NO;
    lImgVewBack.hidden = NO;
    lImgViewChooseEvent.hidden = NO;
    lButtonEvents.hidden = NO;
    if([lTextView.text isEqualToString:@""] || [lTextView.text isEqualToString:@" "]){
        lTextView.text = @"Entrad Descripción del evento aquí";
    }
}

- (void)dismissKeyBoard:(id)sender{
    [lTextView resignFirstResponder];
}

- (IBAction )BnDateTimeTapped{
    if(!datePickerMainView)
        datePickerMainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:datePickerMainView];
    UIView *dateView = [[UIView alloc]initWithFrame:CGRectMake(0, datePickerMainView.bounds.size.height - 256, datePickerMainView.bounds.size.width, 250)];
    dateView.layer.cornerRadius = 5.0f;
    [datePickerMainView addSubview:dateView];
    UIButton *bnDone = [[UIButton alloc]initWithFrame:CGRectMake(10, datePickerMainView.bounds.size.height - 297, datePickerMainView.bounds.size.width - 20, 34)];
    UIColor *blueColor = [self colorFromHexString:@"#2871b4"];
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    dateLabel.text = @"Selector de fecha";
    [dateLabel setFont:[UIFont boldSystemFontOfSize:18]];
    dateLabel.textColor = blueColor;
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [bnDone setBackgroundImage:[UIImage imageNamed:@"i5_button_2_on.png"] forState:UIControlStateNormal];
    [bnDone setTitle:@"Guardar" forState:UIControlStateNormal];
    [bnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bnDone addTarget:self action:@selector(PickDate:) forControlEvents:UIControlEventTouchUpInside];
    datePickerMainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"opacity_40.png"]];
    dateView.backgroundColor = [UIColor whiteColor];
    if(!pickerView)
        pickerView = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 40, 280, 40)];
    pickerView.maximumDate = [NSDate date];
    //        pickerView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [datePickerMainView addSubview:bnDone];
    [dateView addSubview:pickerView];
    [dateView addSubview:dateLabel];
}

-(void)alertDescription{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Por favor, introduzca la descripción." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [alert show];
}

- (void)PickDate:(id)sender{
    previewImg.hidden = NO;
    lLabelGallery.hidden = NO;
    lButtonOpenCamera.hidden = NO;
    lButtonOpenGallery.hidden = NO;
    //    lButtonEvents.hidden = NO;
    lLabelPhoto.hidden = NO;
    lTextView.hidden = NO;
    textViewImageView.hidden = NO;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    lDateTime = [dateFormatter stringFromDate: pickerView.date];
    
    lLabelDateTime.text  = lDateTime;
    [datePickerMainView removeFromSuperview];
}

-(IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setAddEventVCAsWindowRootVC];
}

- (IBAction)BnAddEvent:(id)sender{
    //check whether the image name has spaces or not
    if(![lLabelCategory.text isEqualToString:@"Selecto evento"]){
        if(![lTextView.text isEqualToString:@"Entrad Descripción del evento aquí"]){
            if (![lLabelDateTime.text isEqualToString:@"Date                             Time"]) {
                if(![imageName isEqualToString:@""]){
                    [self showProgressIndicator];
                    mLabelLoading.text = @"Cargando...";
                    [self performSelector:@selector(callServiceLoadingImage) withObject:nil afterDelay:1.0];
                }
                else{
                    mLabelLoading.text = @"Agregando...";
                    [self performSelector:@selector(callServiceLoadingImage) withObject:nil afterDelay:1.0];
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Elegir fecha." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
                [alert show];
            }
        }
        else{
            [self alertDescription];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Por favor, ingrese la evento." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if(lTextView==textView)
    {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-\"\"0123456789 "];
        for (int i = 0; i < [text length]; i++)
        {
            unichar c = [text characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
            else{
                if(textView.text.length == 0){
                    switch (c) {
                        case '_':
                        case '-':
                        case ' ':
                        case '"':
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
    
    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [text rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= MAX_LENGTH || returnKey;
}

-(void)callServiceLoadingImage{
    //    UserDataModel *lUserDataModel = [UserDataModel getUserDataModel];
    if(![imageName isEqualToString:@""]){
        NSString *urlString = [NSString stringWithFormat:@"http://emaguenwcfm3.cloudapp.net/JsonService.svc/UploadFile?fileName=%@",imageName];
        //http://emaguenwcfm3.cloudapp.net/JsonService.svc/UploadFile?
        //http://emaguenv2.cloudapp.net/JsonService.svc/PCUploadImage/fileName=%@
        //        NSString *urlString = [NSString stringWithFormat:@"http://emaguenv2.cloudapp.net/JsonService.svc/PCUploadImage"];
        NSLog(@"The final image name:%@",urlString);
        NSData *data = UIImageJPEGRepresentation(previewImg.image,0.1f);
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 250*1024;
        //            NSLog(@"%@",data);
        //            NSData *imageData = UIImageJPEGRepresentation(yourImage, compression);
        
        while ([data length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            data = UIImageJPEGRepresentation(previewImg.image, compression);
        }
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        NSMutableData *body = [NSMutableData data];
        [body appendData:[NSData dataWithData:data]];
        [request setHTTPBody:body];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"Ret: %@",returnString);
        if(returnString.length > 0){
            NSData* data1 = [returnString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data1 options:kNilOptions error:&error];
            //   NSLog(@"Dict:%@",[lJSONArray objectForKey:@"UploadImageResult"]);
            lEventAddParam.image = [NSString stringWithFormat:@"%@",[lJSONArray objectForKey:@"UploadImageResult"]];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Image uploading failed. Try again..!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        lEventAddParam.image = @"";
    }
    int mBarrioId;
    [self hideProgressIndicator];
    mBarrioId = 1;
    if([lLabelCategory.text isEqualToString:@"Evento Genérico"]){
        mCategoryId = 66;
    }
    else if([lLabelCategory.text isEqualToString:@"Robo"]){
        mCategoryId = 70;
    }
    else if([lLabelCategory.text isEqualToString:@"Choque de Vehículos"]){
        mCategoryId = 71;
    }
    else if([lLabelCategory.text isEqualToString:@"Persona Sospechosa"]){
        mCategoryId = 72;
    }
    else if([lLabelCategory.text isEqualToString:@"Obra"]){
        mCategoryId = 73;
    }
    lEventAddParam.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedUsername"];
    lEventAddParam.userPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedPassword"];
    NSString *dateString = [lDateTime stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    lEventAddParam.dateTime = dateString;
    lEventAddParam.categoryID  = mCategoryId;
    lEventAddParam.barrioID  = mBarrioId;
    lEventAddParam.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"kPrefKeyForUpdatedUsername"];
    lEventAddParam.location = location;
    lEventAddParam.description = lTextView.text;
    lEventAddParam.latitude = [NSString stringWithFormat:@"%f",coordlatt];
    lEventAddParam.longitude = [NSString stringWithFormat:@"%f",coordlongi];
    //        lEventAddParam.image = [NSString stringWithFormat:@"%@",[lJSONArray objectForKey:@"UploadImageResult"]];
    [self showProgressIndicator];
    mLabelLoading.text = @"Agregando...";
    [self performSelector:@selector(callService) withObject:nil afterDelay:1.0];
}

- (void) callService{
    
    NSString *convertedString  = [lEventAddParam.description stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:@"%@AgregarEvento",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:@"{\"alias\":\"%@\",\"contrasenia\":\"%@\",\"idCategoria\":\"%d\",\"nombre\":\"%@\",\"ubicacion\":\"%@\",\"fecha\":\"%@\",\"descripcion\":\"%@\",\"latitud\":\"%@\",\"longitud\":\"%@\",\"idBarrio\":\"%d\",\"Foto\":\"\%@\"}",lEventAddParam.userName,lEventAddParam.userPassword,lEventAddParam.categoryID,lEventAddParam.name,lEventAddParam.location,lEventAddParam.dateTime,convertedString,lEventAddParam.latitude,lEventAddParam.longitude,lEventAddParam.barrioID,lEventAddParam.image];
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    NSLog(@"Request: %@",jsonString);
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
    if([returnString length] == 0){
        [self hideProgressIndicator];
        [self showNetworkError];
    }
    else{
        returnString = [returnString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        returnString = [returnString substringToIndex:[returnString length] - 1];
        returnString = [returnString substringFromIndex:1];
        NSData* data = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        //    NSLog(@"Response: %@",dict);
        NSError *error;
        NSDictionary *lJSONArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"final response:%d",[[lJSONArray objectForKey:@"Mensaje"] intValue]);
        int temp =[[lJSONArray objectForKey:@"Mensaje"] intValue];
        
        [self hideProgressIndicator];
        if(temp > 0){
            [mAppDelegate setShareEventVCAsWindowRootVC:lLabelCategory.text andDateTime:[NSString stringWithFormat:@"%@",lLabelDateTime.text] andDescription:lEventAddParam.description andImage:lEventAddParam.image andUrl:[lJSONArray objectForKey:@"Mensaje"]];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Por favor, inténtelo otra vez." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
        [self deallocMemory];
    }
}

- (void)deallocMemory{
    lEventAddParam = nil;
    tap = nil;
    pickerView = nil;
    datePickerMainView = nil;
    location = nil;
}

@end


//-(NSString *)getCityFromLocation:(float)lattitude and:(float)longitude
//{
//    __block NSString *city;
//    CLLocation *LocationAtual = [[CLLocation alloc] initWithLatitude:lattitude longitude:longitude];
//    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//
//    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//
//    [geocoder reverseGeocodeLocation:LocationAtual completionHandler:
//     ^(NSArray *placemarks, NSError *error)
//     {
//         if([placemarks count] == 0){
//             city = @"Los datos que no se encuentra";
//             NSLog(@"Location: %@",mLocation);
//         }
//         else{
//             CLPlacemark *myPlacemark = [placemarks lastObject];
//             NSLog(@"PalceMark:%@",[placemarks lastObject]);
//             city = [NSString stringWithFormat:@"Area:%@%@%@%@%@.",((myPlacemark.thoroughfare.length == 0)?@"":[NSString stringWithFormat:@" %@",myPlacemark.thoroughfare]),((myPlacemark.locality.length == 0)?@"":[NSString stringWithFormat:@" %@",myPlacemark.locality]),((myPlacemark.administrativeArea.length == 0)?@"":[NSString stringWithFormat:@" %@",myPlacemark.administrativeArea]),((myPlacemark.postalCode.length == 0)?@"":[NSString stringWithFormat:@" %@",myPlacemark.postalCode]),((myPlacemark.country.length == 0)?@"":[NSString stringWithFormat:@" %@",myPlacemark.country])];
//             NSLog(@"Location: %@",mLocation);
//         }
//         dispatch_semaphore_signal(sema); // string is ready
//     }
//     ];
//
//    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER); // wait for string
////    dispatch_release(sema); // if you are using ARC & 10.8 this is NOT needed
//    return city;
//}
