//
//  WHSettingsViewController.m
//  WaterHeaterControl
//
//  Created by Ido on 7/27/14.
//  Copyright (c) 2014 OwlPixel. All rights reserved.
//

#import "WHSettingsViewController.h"
#import "WHSparkCloud.h"
#import "WHDeviceIDTokenDefs.h"

@interface WHSettingsViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *deviceIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *accessTokenTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *timeZonePicker;

@end

@implementation WHSettingsViewController

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
    self.deviceIDTextField.text = MY_SPARK_DEVICE_ID;
    self.accessTokenTextField.text = MY_SPARK_ACCESS_TOKEN;
    self.timeZonePicker.delegate = self;
    self.timeZonePicker.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"UTC %d",(int)(row-12)];
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 24;
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

@end
