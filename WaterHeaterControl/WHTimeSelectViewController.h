//
//  WHTimeSelectViewController.h
//  WaterHeaterControl
//
//  Created by Ido on 6/3/14.
//  Copyright (c) 2014 OwlPixel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WHTimeSelectDelegate <NSObject>

@required
-(void)timeSelectedString:(NSString *)newTime;

@end

@interface WHTimeSelectViewController : UIViewController
@property (nonatomic) NSInteger presetHour;
@property (nonatomic) NSInteger presetMinute;
@property (nonatomic) id <WHTimeSelectDelegate> delegate;

@end
