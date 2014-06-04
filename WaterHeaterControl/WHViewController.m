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

@interface WHViewController ()
@property (nonatomic) NSInteger buttonTag;
//@property (nonatomic) NSInteger lastMinutes, lastHours;
@end

@implementation WHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)timeButtonsTouched:(id)sender
{
    UIButton *btn = sender;
    self.buttonTag = btn.tag;

    
//    UIButton *btn = (UIButton *)self.view viewWithTag:
    WHTimeSelectViewController *timeVC = [[WHTimeSelectViewController alloc] init];
    
    [self.navigationController pushViewController:timeVC animated:YES];
    
//    [self performSegueWithIdentifier:@"time" sender:self];
    

}

@end
