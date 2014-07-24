//
//  WHTimeSelectViewController.m
//  WaterHeaterControl
//
//  Created by Ido on 6/3/14.
//  Copyright (c) 2014 OwlPixel. All rights reserved.
//

#import "WHTimeSelectViewController.h"
#import <ESTimePicker/ESTimePicker.h>

@interface WHTimeSelectViewController () <ESTimePickerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *hoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesLabel;
@property (strong, nonatomic) ESTimePicker *timePicker;
@end

@implementation WHTimeSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.timePicker = [[ESTimePicker alloc] initWithDelegate:self]; // Delegate is optional
    [self.timePicker setFrame:CGRectMake(10, 100, 300, 300)];
    [self.view addSubview:self.timePicker];
    [self.timePicker setNotation24Hours:YES];
    [self.timePicker setMinutes:self.presetMinute];
    [self.timePicker setHours:self.presetHour];
    
    self.hoursLabel.text = [NSString stringWithFormat:@"%02d",(int)self.presetHour];
    self.minutesLabel.text = [NSString stringWithFormat:@"%02d",(int)self.presetMinute];
    

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {

    [self.delegate newTimeSelected:[NSString stringWithFormat:@"%02d:%02d",self.timePicker.hours,self.timePicker.minutes]];
    [self.navigationController popViewControllerAnimated:YES];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)timePickerHoursChanged:(ESTimePicker *)timePicker toHours:(int)hours
{
    [self.hoursLabel setText:[NSString stringWithFormat:@"%02d",hours]];
    
}

- (void)timePickerMinutesChanged:(ESTimePicker *)timePicker toMinutes:(int)minutes
{
    [self.minutesLabel setText:[NSString stringWithFormat:@"%02d",minutes]];
}

@end
