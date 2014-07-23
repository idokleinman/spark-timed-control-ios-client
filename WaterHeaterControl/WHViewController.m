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

@interface WHViewController () <WHTimeSelectDelegate>

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray* dayNameLabels;
@property (weak, nonatomic) IBOutlet UILabel *serverTimeLabel;


//@property (nonatomic) NSInteger buttonTag;
@property (strong, nonatomic) UIButton *timeButtonTouched;
//@property (nonatomic) NSInteger lastMinutes, lastHours;
@end

@implementation WHViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
   
}

-(void)viewWillAppear:(BOOL)animated
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:today];
    
    NSInteger weekday = [weekdayComponents weekday];
    
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WHTimeSelectViewController *timeVC = segue.destinationViewController;
    
    NSString *timeStr = self.timeButtonTouched.titleLabel.text;
    NSArray *timeStrComponents = [timeStr componentsSeparatedByString:@":"];
    NSInteger hour = [timeStrComponents[0] intValue];
    NSInteger minute = [timeStrComponents[1] intValue];
    
    [timeVC setPresetHour:hour];
    [timeVC setPresetMinute:minute];
    [timeVC setDelegate:self];
    
}


-(void)timeSelectedString:(NSString *)newTime
{
    self.timeButtonTouched.titleLabel.text = newTime;
}

@end
