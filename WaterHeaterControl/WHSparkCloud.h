//
//  FMServer.h
//  SelfMe
//
//  Created by Ido on 5/15/14.
//  Copyright (c) 2014 FaceMe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MY_SPARK_ACCESS_TOKEN  @"26aa2d1d05547dfce09f4174099cef8522a1f10a"
#define MY_SPARK_DEVICE_ID     @"53ff73065075535147141687"

@interface WHSparkCloud : NSObject

+ (WHSparkCloud *)sharedInstance;

-(void)setConfig:(NSDictionary *)config completion:(void(^)(NSError *error))completion;;
-(void)getConfig:(void(^)(NSDictionary *config, NSError *error))completion;;
/*
-(void)setActive:(BOOL)active completion:(void(^)(NSError *error))completion;;
-(void)getActive:(void(^)(BOOL active, NSError *error))completion;;
*/
@end
