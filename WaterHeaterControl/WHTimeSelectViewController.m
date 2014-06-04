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
    ESTimePicker *timePicker = [[ESTimePicker alloc] initWithDelegate:self]; // Delegate is optional
    [timePicker setFrame:CGRectMake(10, 100, 300, 300)];
    [self.view addSubview:timePicker];
    [timePicker setNotation24Hours:YES];
    [timePicker setMinutes:self.presetMinutes];
    [timePicker setHours:self.presetHours];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButton:(id)sender {
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
    [self.hoursLabel setText:[NSString stringWithFormat:@"%2d",hours]];
    
}

- (void)timePickerMinutesChanged:(ESTimePicker *)timePicker toMinutes:(int)minutes
{
    [self.minutesLabel setText:[NSString stringWithFormat:@"%2d",minutes]];
}

@end
