//
//  FMServer.h
//  SelfMe
//
//  Created by Ido on 5/15/14.
//  Copyright (c) 2014 FaceMe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SM_API_URL @"http://d13e1a8d9a7c45309119f5323f1ef4f4.cloudapp.net" // staging area
#define SM_API_CREATE_PROFILE @"%@/REST/SMClientAPI?action_type=create_profile&user_name=%@&platform=iOS"
#define SM_API_SMS_VERIFICATION @"%@/REST/SMClientAPI?action_type=perform_sms_verification&user_name=%@&sms_code=%@"
#define SM_API_REGISTER_PUSH_TOKEN @"%@/REST/SMClientAPI?action_type=push_register&user_name=%@&password=%@&token=%@"
#define SM_API_POST_REQUEST @"%@/REST/SMClientAPI?action_type=request&user_name=%@&password=%@"
#define SM_API_POST_UPLOAD @"%@/REST/SMClientAPI?action_type=upload_file&user_name=%@&password=%@"
#define SM_API_DOWNLOAD @"%@/REST/SMClientAPI?action_type=get_profile_image&user_name=%@&password=%@&contact_id=%@"

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
