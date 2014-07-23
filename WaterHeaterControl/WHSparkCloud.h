//
//  FMServer.h
//  SelfMe
//
//  Created by Ido on 5/15/14.
//  Copyright (c) 2014 FaceMe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SPARK_ACCESS_TOKEN  @"1234312456723578"
#define SPARK_DEVICE_ID     @"fa6h86hf38763f876hf8sd7g"
#define WH_SPARK_API_CONFIG @"https://api.spark.io/v1/devices/%@/config?access_token=%@"
#define WH_SPARK_API_ACTIVE @"https://api.spark.io/v1/devices/%@/active?access_token=%@"

@interface WHSparkCloud : NSObject

+ (WHSparkCloud *)sharedInstance;

-(void)setConfig:(NSDictionary *)config completion:(void(^)(NSError *error))completion;;
-(void)getConfig:(void(^)(NSDictionary *config, NSError *error))completion;;

-(void)setActive:(BOOL)active completion:(void(^)(NSError *error))completion;;
-(void)getActive:(void(^)(BOOL active, NSError *error))completion;;

@end
