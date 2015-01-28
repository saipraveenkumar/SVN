//
//  ConfigureAlarmViewController.m
//  eMaguen
//
//  Created by Rushikesh Kulkarni on 14/11/14.
//  Copyright (c) 2014 Simplicity. All rights reserved.
//

#import "ConfigureAlarmViewController.h"
#import "MyAppAppDelegate.h"
#import "AddAlarmModel.h"
#import "StringID.h"

#define GET_ALARM_SETTINGS @"{\"AlarmPhoneNumber\":\"%@\"}"

#define SET_ALARM_SETTINGS @"{\"AlarmPhoneNumber\":\"%@\",\"Volume\":\"%@\",\"AlarmStatus\":\"%@\",\"DelayTime\":\"%@\"}"

MyAppAppDelegate *mAppDelegate;

@interface ConfigureAlarmViewController ()
{
    NSMutableArray *data;
    UIView *mainView;
    UIPickerView *pickerViewVolume, *pickerViewDelay, *pickerViewRinger;
    UIView *pickerViewBack;
    NSArray *mAlarmDetails;
    int volumeSetOld, volumeSetNew, delayTimeOld, delayTimeNew;
    UILabel *dateLabel;
    BOOL isGettingAlarmSettings;
    UITapGestureRecognizer *tap;
    NSDictionary *lAlarmSettings;
}
@end

@implementation ConfigureAlarmViewController

- (void)setData:(NSArray*)alarmDetails{
    mAlarmDetails = alarmDetails;
    NSLog(@"Alaram Details:%@",mAlarmDetails);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    volumeSetNew = 0;
    volumeSetOld = 0;
    delayTimeNew = 1;
    delayTimeOld = 1;
    isGettingAlarmSettings = YES;
    
    self.navigationItem.rightBarButtonItem = nil;
    
    mAppDelegate = [MyAppAppDelegate getAppDelegate];
    
    lblTitle.text = [[mAlarmDetails objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    pickerViewVolume = [[UIPickerView alloc]init];
    pickerViewVolume.delegate = self;
    pickerViewVolume.dataSource = self;
    pickerViewDelay = [[UIPickerView alloc]init];
    pickerViewDelay.delegate = self;
    pickerViewDelay.dataSource = self;
    
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissPickerView)];
    
    [self addProgressIndicator];
    [self showProgressIndicator];
    mLabelLoading.text = @"Cargando...";    
    [self performSelectorInBackground:@selector(callGetAlarmSettingsWebService) withObject:nil];
}

- (IBAction)BnBackTapped:(id)sender{
    [mAppDelegate setChooseAlarmViewController];
}

- (void)dismissPickerView{
    [mainView removeFromSuperview];
}

-(IBAction)BnChooseVolume:(id)sender{
    UIColor *blueColor = [self colorFromHexString:@"#2871b4"];
    [self pickerViewSettings];
    dateLabel.text = @"Seleccione el volumen";
    dateLabel.textColor = blueColor;
    UIButton *bnDone = [[UIButton alloc]initWithFrame:CGRectMake(33 , 35, 95, 37)];
    [bnDone setImage:[UIImage imageNamed:@"Guardar_iphone5.png"] forState:UIControlStateNormal];
    [bnDone addTarget:self action:@selector(VolumeDone) forControlEvents:UIControlEventTouchUpInside];
    data = [[NSMutableArray alloc]initWithObjects:@"Silencio",@"Bajo",@"Medio",@"Alto", nil];
    pickerViewVolume.frame = CGRectMake(0, 68, 160, 180);
    [pickerViewVolume selectRow:volumeSetNew inComponent:0 animated:YES];
    [pickerViewBack addSubview:bnDone];
    [pickerViewBack addSubview:dateLabel];
    [pickerViewBack addSubview:pickerViewVolume];
}

- (void)pickerViewSettings{
    if(iPhone5){
        mainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
    }
    else if (iPhone){
        mainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    }
    [self.view addSubview:mainView];
    if(iPhone5){
        pickerViewBack = [[UIView alloc]initWithFrame:CGRectMake(80, 338, 160, 230)];
    }
    else if (iPhone){
        pickerViewBack = [[UIView alloc]initWithFrame:CGRectMake(80, 250, 160, 230)];
    }
    pickerViewBack.layer.cornerRadius = 5.0f;
    [mainView addSubview:pickerViewBack];
    pickerViewBack.backgroundColor = [UIColor whiteColor];
    dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5 , 160, 30)];
    [dateLabel setFont:[UIFont systemFontOfSize:14]];
    dateLabel.textAlignment = NSTextAlignmentCenter;
    mainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"opacity_40.png"]];
    [mainView addGestureRecognizer:tap];
}

- (IBAction)BnAlarmDelayTapped:(id)sender{
    UIColor *blueColor = [self colorFromHexString:@"#2871b4"];
    [self pickerViewSettings];
    dateLabel.text = @"Seleccione el retardo";
    dateLabel.textColor = blueColor;
    UIButton *bnDone = [[UIButton alloc]initWithFrame:CGRectMake(33 , 35, 95, 37)];
    [bnDone setImage:[UIImage imageNamed:@"Guardar_iphone5.png"] forState:UIControlStateNormal];
    [bnDone addTarget:self action:@selector(DelaySetDone) forControlEvents:UIControlEventTouchUpInside];
    data = [[NSMutableArray alloc]init];
    for(int i=1; i<=300; i++)
        [data addObject:[NSString stringWithFormat:@"%d",i]];
    pickerViewDelay.frame = CGRectMake(0, 68, 160, 180);
    [pickerViewDelay selectRow:delayTimeNew-1 inComponent:0 animated:NO];
    [pickerViewBack addSubview:bnDone];
    [pickerViewBack addSubview:dateLabel];
    [pickerViewBack addSubview:pickerViewDelay];
}

- (void)DelaySetDone{
    [mainView removeFromSuperview];
    lblDelay.text = [NSString stringWithFormat:@"%d",delayTimeNew];
    if(delayTimeNew != delayTimeOld){
        NSString *message= [NSString stringWithFormat:@"Alarm delay time(0-300sec):\n%d",delayTimeNew];
        NSLog(@"%@",message);
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Su dispositivo no admite SMS!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
            return;
        }
        NSArray *recipents = [NSArray arrayWithObject:[mAlarmDetails objectAtIndex:1]];
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipents];
        [messageController setBody:message];
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
    }
}

- (IBAction)BnAlarmEditTapped:(id)sender{
    if(mAlarmDetails != nil){
    [mAppDelegate setEditAlarmVCWithAlarmNameNumber:mAlarmDetails];
    }
}

-(void)VolumeDone{
    [mainView removeFromSuperview];
    if(volumeSetNew == 3){
        lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-33.png"];
    }
    else if(volumeSetNew == 2){
        lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-34.png"];
    }
    else if(volumeSetNew == 1){
        lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-35.png"];
    }
    else if(volumeSetNew == 0){
        lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-36.png"];
    }
    if(volumeSetNew != volumeSetOld){
        NSString *message= [NSString stringWithFormat:@"Siren volume(0 Mute, 1 Low, 2 Medium, 3 High):\n%d\nSiren ringing time(1-9min):\n5",volumeSetNew];
        NSLog(@"%@",message);
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Su dispositivo no admite SMS!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
            return;
        }
        NSArray *recipents = [NSArray arrayWithObject:[mAlarmDetails objectAtIndex:1]];
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipents];
        [messageController setBody:message];
        [self presentViewController:messageController animated:YES completion:nil];
    }
}

- (IBAction)BnArmDisarmCallBackTapped:(id)sender{
    UIButton *tempButton = sender;
    NSString *message;
    if(tempButton.tag == 1)
        message = [NSString stringWithFormat:@"0"];
    else if (tempButton.tag == 2)
        message = [NSString stringWithFormat:@"1"];
    else if (tempButton.tag == 3)
        message = [NSString stringWithFormat:@"2"];
    //testing message
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Su dispositivo no admite SMS!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSArray *recipents = [NSArray arrayWithObject:[mAlarmDetails objectAtIndex:1]];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
        {
            volumeSetNew = volumeSetOld;
            delayTimeNew = delayTimeOld;
            lblDelay.text = [NSString stringWithFormat:@"%d",delayTimeNew];
            switch (volumeSetOld) {
                case 0:
                    lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-36.png"];
                    break;
                case 1:
                    lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-35.png"];
                    break;
                case 2:
                    lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-34.png"];
                    break;
                case 3:
                    lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-33.png"];
                    break;
                default:
                    break;
            }
        }
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atención" message:@"Error al enviar SMS!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
            break;
        }
            
        case MessageComposeResultSent:
        {
            volumeSetOld = volumeSetNew;
            delayTimeOld = delayTimeNew;
            [self addProgressIndicator];
            [self showProgressIndicator];
            mLabelLoading.text = @"Gurdando...";
            [self callSaveAlarmSettingsWebService];
        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [data count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return data[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component{
    if(pickerView == pickerViewVolume){
        if([[data objectAtIndex:row] isEqualToString:@"Silencio"])
            volumeSetNew = 0;
        else if([[data objectAtIndex:row] isEqualToString:@"Bajo"])
            volumeSetNew = 1;
        else if([[data objectAtIndex:row] isEqualToString:@"Medio"])
            volumeSetNew = 2;
        else if([[data objectAtIndex:row] isEqualToString:@"Alto"])
            volumeSetNew = 3;
    }
    else if(pickerView == pickerViewDelay){
        delayTimeNew = [[data objectAtIndex:row] intValue];
    }
}

- (void)callGetAlarmSettingsWebService{
    NSString *urlString = [NSString stringWithFormat:@"%@GetAlarmStatus",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:GET_ALARM_SETTINGS,[mAlarmDetails objectAtIndex:1]];
    
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
    [self hideProgressIndicator];
    if(returnString.length > 0){
        NSLog(@"Output: %@",returnString);
        NSData* dataService = [returnString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        lAlarmSettings = [NSJSONSerialization JSONObjectWithData:dataService options:kNilOptions error:&error];
        isGettingAlarmSettings = NO;
        if([[lAlarmSettings objectForKey:@"Response"] isEqualToString:@"Success"]){
            if((NSNull *)[lAlarmSettings objectForKey:@"DelayTime"] != [NSNull null] && [[lAlarmSettings objectForKey:@"DelayTime"] intValue]!=0){
                delayTimeOld = [[lAlarmSettings objectForKey:@"DelayTime"] intValue];
                delayTimeNew = delayTimeOld;
                lblDelay.text = [NSString stringWithFormat:@"%d",delayTimeNew];
            }
            else{
                delayTimeOld = 1;
                delayTimeNew = delayTimeOld;
                lblDelay.text = [NSString stringWithFormat:@"%d",delayTimeNew];
            }
            if((NSNull *)[lAlarmSettings objectForKey:@"Volume"] != [NSNull null]){
                volumeSetOld = [[lAlarmSettings objectForKey:@"Volume"] intValue];
                volumeSetNew = volumeSetOld;
                switch (volumeSetOld) {
                    case 0:
                        lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-36.png"];
                        break;
                    case 1:
                        lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-35.png"];
                        break;
                    case 2:
                        lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-34.png"];
                        break;
                    case 3:
                        lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-33.png"];
                        break;
                    default:
                        break;
                }
            }
            else{
                volumeSetOld = 0;
                volumeSetNew = volumeSetOld;
                lblVolumeImage.image = [UIImage imageNamed:@"i4_emaguen_v2_india-36.png"];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[mAlarmDetails objectAtIndex:0] message:@"Unable to retrieve old settings..! Go Back and Try again." delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        [self showNetworkError];
    }
}

- (void)callSaveAlarmSettingsWebService{
    NSString *urlString = [NSString stringWithFormat:@"%@SetAlarmStatus",lServiceURL];
    NSString *jsonString = [NSString stringWithFormat:SET_ALARM_SETTINGS, [mAlarmDetails objectAtIndex:1], [NSString stringWithFormat:@"%d",volumeSetNew], @"", [NSString stringWithFormat:@"%d",delayTimeNew]];
    
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
        NSError *error;
        lAlarmSettings = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if([[lAlarmSettings objectForKey:@"Response"] isEqualToString:@"Success"]){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[mAlarmDetails objectAtIndex:0] message:@"Alarm konfiguriert" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
            volumeSetOld = volumeSetNew;
            delayTimeOld = delayTimeNew;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[mAlarmDetails objectAtIndex:0] message:@"Kann Alarm konfigurieren. versuchen Sie es erneut...!" delegate:self cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        [self showNetworkError];
    }
}

@end
