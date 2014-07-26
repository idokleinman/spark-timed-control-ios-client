//
//  WHViewController.m
//  WaterHeaterControl
//
//  Created by Ido on 6/3/14.
//  Copyright (c) 2014 OwlPixel. All rights reserved.
//

#import "WHViewController.h"
#import <ESTimePicker/ESTimePicker.h>
#import "WHTimeSelectViewController.h"
#import "WHSparkCloud.h"

@interface WHViewController () <WHTimeSelectDelegate>

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* dayNameLabels;
@property (weak, nonatomic) IBOutlet UILabel *serverTimeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *activeSwitch;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIButton *timeButtonTouched;
@end

@implementation WHViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicator.color = [UIColor blackColor];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator stopAnimating];
    // update UI
   
   
}

-(void)viewWillAppear:(BOOL)animated
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
    
    NSInteger weekday = [weekdayComponents weekday];
    
    // make day of week bold (current)
    for (UILabel *label in self.dayNameLabels)
    {
        if (weekday == label.tag)
        {
            [label setFont:[UIFont boldSystemFontOfSize:18]];
            label.textColor = [UIColor blackColor];
        }
        else
        {
            [label setFont:[UIFont systemFontOfSize:17]];
            label.textColor = [UIColor darkGrayColor];

        }
        
    }
    
    [self syncAndUpdateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)syncAndUpdateUI
{
//    __block UIView *disabledView = [[UIView alloc] initWithFrame:self.view.frame];
//    [disabledView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
//    [self.view addSubview:disabledView];
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [self.activityIndicator startAnimating];
    
    [[WHSparkCloud sharedInstance] getConfig:^(NSDictionary *config, NSError *error) {
//        [disabledView removeFromSuperview];
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        [self.activityIndicator stopAnimating];
        if (!error)
        {
            [self updateUIFromConfigDict:config];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }
    }];
}

- (IBAction)timeButtonsTouched:(id)sender
{
//    UIButton *btn = sender;
//    self.buttonTag = btn.tag;

    self.timeButtonTouched = sender;
    
    [self performSegueWithIdentifier:@"time" sender:self];
    
    
//    [self.navigationController pushViewController:timeVC animated:YES];
    

}

-(void)convertTimeStrToHoursMinutes:(NSString* )timeStr hour:(NSInteger *)hour minute:(NSInteger *)minute
{
    NSArray *timeStrComponents = [timeStr componentsSeparatedByString:@":"];
    *hour = [timeStrComponents[0] intValue];
    *minute = [timeStrComponents[1] intValue];

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WHTimeSelectViewController *timeVC = segue.destinationViewController;
    
    if ([timeVC isKindOfClass:[WHTimeSelectViewController class]])
    {
        NSString *timeStr = self.timeButtonTouched.titleLabel.text;
        NSInteger hour,minute;
        [self convertTimeStrToHoursMinutes:timeStr hour:&hour minute:&minute];
        
        [timeVC setPresetHour:hour];
        [timeVC setPresetMinute:minute];
        [timeVC setDelegate:self];
    }
}


-(NSDictionary *)createConfigDictFromUIChange:(id)sender
{
    NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
  
    if (sender == self.activeSwitch)
    {
        [configDict setValue:[NSNumber numberWithBool:self.activeSwitch.isOn] forKey:@"active"]; // @{@"active" : [NSNumber numberWithBool:self.activeSwitch.isOn]};
        return configDict;
    }
    
    NSArray *weekdaySymbols = [[[NSDateFormatter alloc] init] weekdaySymbols];
    
    if ([sender isKindOfClass:[UISwitch class]])
    {
        UISwitch *enabledSwitch = (UISwitch *)sender;
        if (enabledSwitch.tag<100) // ignore active switch (tag=0)
            return nil;

        NSInteger day = (enabledSwitch.tag / 100)-1;
            
        configDict[weekdaySymbols[day]]=@{@"enabled": [NSNumber numberWithBool:enabledSwitch.isOn]};
        return configDict;
    }
    
    if ([sender isKindOfClass:[UIButton class]])
    {
        UIButton *timeButton = (UIButton *)sender;
        if (timeButton.tag < 100) // check its times button only
            return nil;
        
        NSInteger day = (timeButton.tag / 100)-1;
        NSInteger onHour, offHour, onMinute, offMinute;
        NSString *timeStr = timeButton.titleLabel.text;
        
        if (timeButton.tag % 2)
        {
            [self convertTimeStrToHoursMinutes:timeStr hour:&onHour minute:&onMinute];
            configDict[weekdaySymbols[day]]=
            @{@"onHour":[NSNumber numberWithInteger:onHour],
              @"onMinute":[NSNumber numberWithInteger:onMinute]};
            
        }
        else
        {
            [self convertTimeStrToHoursMinutes:timeStr hour:&offHour minute:&offMinute];
            configDict[weekdaySymbols[day]]=
            @{@"offHour":[NSNumber numberWithInteger:offHour],
              @"offMinute":[NSNumber numberWithInteger:offMinute]};

        }
        
        return configDict;
        
    }
    
    return nil;

}

/*
-(NSDictionary *)createConfigDictFromCurrentSettings //UNUSED DUE TO 64 BYTES LIMIT ON SPARK COMMAND ARGUMENT
{
    NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
    
    [configDict setValue:[NSNumber numberWithBool:self.activeSwitch.isOn] forKey:@"active"]; // @{@"active" : [NSNumber numberWithBool:self.activeSwitch.isOn]};
    NSArray *weekdaySymbols = [[[NSDateFormatter alloc] init] weekdaySymbols];
    
    
    for (UIView *element in self.view.subviews)
    {
        if ([element isKindOfClass:[UISwitch class]])
        {
            UISwitch *enabledSwitch = (UISwitch *)element;
            if (enabledSwitch.tag>=100) // ignore active switch (tag=0)
            {
                NSInteger day = (enabledSwitch.tag / 100)-1;
                
                configDict[weekdaySymbols[day]]=
                @{@"enabled": [NSNumber numberWithBool:enabledSwitch.isOn]};
            }
        }

        if ([element isKindOfClass:[UIButton class]])
        {
            UIButton *timeButton = (UIButton *)element;
            NSInteger day = (timeButton.tag / 100)-1;
            NSInteger onHour, offHour, onMinute, offMinute;
            NSString *timeStr = timeButton.titleLabel.text;
            
            if (timeButton.tag % 2)
            {
                
                [self convertTimeStrToHoursMinutes:timeStr hour:&onHour minute:&onMinute];
                
            }
            else
            {
                [self convertTimeStrToHoursMinutes:timeStr hour:&offHour minute:&offMinute];
                
            }
            
            configDict[weekdaySymbols[day]]=
            @{@"onHour":[NSNumber numberWithInteger:onHour],
              @"onMinute":[NSNumber numberWithInteger:onMinute],
              @"offHour":[NSNumber numberWithInteger:offHour],
              @"offMinute":[NSNumber numberWithInteger:offMinute]};
        }
    }
    
    //NSLog(@"%@",[configDict description]);
    return configDict;
    
}
*/




-(void)updateUIFromConfigDict:(NSDictionary *)configDict
{
    
//    [configDict setValue:[NSNumber numberWithBool:self.activeSwitch.isOn] forKey:@"active"]; // @{@"active" : [NSNumber numberWithBool:self.activeSwitch.isOn]};

    if (configDict[@"active"])
         [self.activeSwitch setOn:[configDict[@"active"] boolValue]];

    if (configDict[@"serverTime"])
    {
        self.serverTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",[configDict[@"serverTime"][@"hour"] integerValue],[configDict[@"serverTime"][@"minute"] integerValue]];
    }
    else
    {
        self.serverTimeLabel.text = @"unknown";
    }

    NSArray *weekdaySymbols = [[[NSDateFormatter alloc] init] weekdaySymbols];

    for (UIView *element in self.view.subviews)
    {
        if ([element isKindOfClass:[UISwitch class]])
        {
            UISwitch *enabledSwitch = (UISwitch *)element;
            if (enabledSwitch.tag >= 100)
            {
                NSInteger day = (enabledSwitch.tag / 100)-1;
                [enabledSwitch setOn:[configDict[weekdaySymbols[day]][@"enabled"] boolValue]];
            }
        }
        
        if ([element isKindOfClass:[UIButton class]])
        {
            UIButton *timeButton = (UIButton *)element;
            NSInteger day = (timeButton.tag / 100)-1;
            NSDictionary *dayConfig = configDict[weekdaySymbols[day]];
            if (dayConfig)
            {
                NSInteger onHour, offHour, onMinute, offMinute;
                onHour = [configDict[weekdaySymbols[day]][@"onHour"] integerValue];
                offHour = [configDict[weekdaySymbols[day]][@"offHour"] integerValue];
                onMinute = [configDict[weekdaySymbols[day]][@"onMinute"] integerValue];
                offMinute = [configDict[weekdaySymbols[day]][@"offMinute"] integerValue];
                
                if (timeButton.tag % 2)
                {
                    timeButton.titleLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",onHour,onMinute];
                }
                else
                {
                    timeButton.titleLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",offHour,offMinute];
                }
            }
        }
    }
    
}


-(void)updateRemoteWithConfigDict:(NSDictionary *)configDict
{
    // NSDictionary *configDict = [self createConfigDictFromCurrentSettings]; // NOT USED NOW
    
//    __block UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    activity.color = [UIColor whiteColor];
//    activity.center = self.view.center;
//    [activity startAnimating];
//    __block UIView *disabledView = [[UIView alloc] initWithFrame:self.view.frame];
//    [disabledView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
//    [self.view addSubview:disabledView];
//    [self.view addSubview:activity];
//    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [self.activityIndicator startAnimating];
    
    [[WHSparkCloud sharedInstance] setConfig:configDict completion:^(NSError *error) {
//        [activity stopAnimating];
//        [activity removeFromSuperview];
//        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//        [disabledView removeFromSuperview];
        
        [self.activityIndicator stopAnimating];
        if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    }];
}

-(void)newTimeSelected:(NSString *)newTime
{
    self.timeButtonTouched.titleLabel.text = newTime;
    NSDictionary *configDict = [self createConfigDictFromUIChange:self.timeButtonTouched];
    [self updateRemoteWithConfigDict:configDict];
}


- (IBAction)activeSwitchChanged:(id)sender
{
    NSDictionary *configDict = [self createConfigDictFromUIChange:sender];
    [self updateRemoteWithConfigDict:configDict];
}



- (IBAction)enabledSwitchChanged:(id)sender
{
    NSDictionary *configDict = [self createConfigDictFromUIChange:sender];
    [self updateRemoteWithConfigDict:configDict];
}



@end
