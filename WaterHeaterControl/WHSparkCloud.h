//
//  FMServer.h
//  SelfMe
//
//  Created by Ido on 5/15/14.
//  Copyright (c) 2014 FaceMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHSparkCloud : NSObject

+ (WHSparkCloud *)sharedInstance;

-(void)setConfig:(NSDictionary *)config completion:(void(^)(NSError *error))completion;;
-(void)getConfig:(void(^)(NSDictionary *config, NSError *error))completion;;
/*
-(void)setActive:(BOOL)active completion:(void(^)(NSError *error))completion;;
-(void)getActive:(void(^)(BOOL active, NSError *error))completion;;
*/
@end
