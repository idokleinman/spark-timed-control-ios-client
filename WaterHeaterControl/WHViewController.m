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
@property (strong, nonatomic) UIButton *timeButtonTouched;
@end

@implementation WHViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // update UI
    [[WHSparkCloud sharedInstance] getConfig:^(NSDictionary *config, NSError *error) {
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
        }
        else
        {
            [label setFont:[UIFont systemFontOfSize:17]];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    NSString *timeStr = self.timeButtonTouched.titleLabel.text;
    NSInteger hour,minute;
    [self convertTimeStrToHoursMinutes:timeStr hour:&hour minute:&minute];
    
    [timeVC setPresetHour:hour];
    [timeVC setPresetMinute:minute];
    [timeVC setDelegate:self];
}



-(NSDictionary *)createConfigDictFromCurrentSettings
{
    NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
    
    [configDict setValue:[NSNumber numberWithBool:self.activeSwitch.isOn] forKey:@"active"]; // @{@"active" : [NSNumber numberWithBool:self.activeSwitch.isOn]};
    NSArray *weekdaySymbols = [[[NSDateFormatter alloc] init] weekdaySymbols];
    
    
    for (UIButton *timeButton in self.view.subviews)
    {
        if ([timeButton isKindOfClass:[UIButton class]])
        {
            NSInteger day = (timeButton.tag / 100)-1;
            NSInteger onHour, offHour, onMinute, offMinute;;
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



-(void)updateUIFromConfigDict:(NSDictionary *)configDict
{
    
//    [configDict setValue:[NSNumber numberWithBool:self.activeSwitch.isOn] forKey:@"active"]; // @{@"active" : [NSNumber numberWithBool:self.activeSwitch.isOn]};

    if (configDict[@"active"])
         [self.activeSwitch setOn:[configDict[@"active"] boolValue]];

    NSArray *weekdaySymbols = [[[NSDateFormatter alloc] init] weekdaySymbols];

    for (UIButton *timeButton in self.view.subviews)
    {
        if ([timeButton isKindOfClass:[UIButton class]])
        {
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


-(void)newTimeSelected:(NSString *)newTime
{
    // set the text
    __block NSString *timeBeforeChangeStr = self.timeButtonTouched.titleLabel.text;
    self.timeButtonTouched.titleLabel.text = newTime;
    NSDictionary *configDict = [self createConfigDictFromCurrentSettings];
    
    __block UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.color = [UIColor blackColor];
    activity.center = self.view.center;
    [self.view addSubview:activity];
    [activity startAnimating];
    
                       
    [[WHSparkCloud sharedInstance] setConfig:configDict completion:^(NSError *error) {
        [activity stopAnimating];
        [activity removeFromSuperview];

        if (error)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            self.timeButtonTouched.titleLabel.text = timeBeforeChangeStr;
            [alert show];
        }
        
    }];
    
    
//    animate the button
    /*
    [UIView animateWithDuration:0.35f animations:^{
        CGRect frame = self.timeButtonTouched.frame;
        frame.size.width *= 1.5;
        frame.size.height *= 1.5;
        [self.timeButtonTouched setFrame:frame];
        
    }];
     
     */
     
     /*
                    completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35f animations:^{
            CGRect frame = self.timeButtonTouched.frame;
            frame.size.width /= 1.5;
            frame.size.height /= 1.5;
            [self.timeButtonTouched setFrame:frame];
         }];
    }];
      */
     
}


- (IBAction)activeSwitchChanged:(id)sender
{
    __block UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.color = [UIColor blackColor];
    activity.center = self.view.center;
    [self.view addSubview:activity];
    [activity startAnimating];

    
    [[WHSparkCloud sharedInstance] setActive:self.activeSwitch.isOn completion:^(NSError *error) {

        [activity stopAnimating];
        [activity removeFromSuperview];
        if (error)
        {
            [self.activeSwitch setOn:(!self.activeSwitch.isOn)]; // reverse switch
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }


    }];
}

@end
