//
//  FMServer.m
//  SelfMe
//
//  Created by Ido on 5/15/14.
//  Copyright (c) 2014 FaceMe. All rights reserved.
//

#import "WHSparkCloud.h"
#import "JGSparkAPI.h"
#import "WHDeviceIDTokenDefs.h"
//#define SIMULATE_SERVER

@interface WHSparkCloud()

//@property (nonatomic,strong) NSString* smsCode;

@end

@interface NSData (UTF8)
- (NSString*)UTF8String;
@end

@implementation WHSparkCloud

+ (WHSparkCloud*)sharedInstance {
    static WHSparkCloud* i = NULL;
    if (!i) {
        i = [[WHSparkCloud alloc] init];
        [JGSparkAPI sharedAPI].deviceID = MY_SPARK_DEVICE_ID;
        [JGSparkAPI sharedAPI].accessToken = MY_SPARK_ACCESS_TOKEN;
    }
    return i;
}


-(void)getConfig:(void (^)(NSDictionary *, NSError *))completion
{
    [[JGSparkAPI sharedAPI] getVariable:@"config" usingBlock:^(NSDictionary *responseObject, NSError* error) {
        if (error)
        {
            completion(nil, error);
            return;
        }
        
        NSString *jd = responseObject[@"result"];//[NSString stringWithFormat:@"{%@}",response[@"result"]];
        NSData *jsonData = [jd dataUsingEncoding:NSUTF8StringEncoding];
        NSError *parserError; //$$$
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&parserError];
        if (parserError)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Failed parsing JSON result from server: %@", parserError);
                NSLog(@"JSON config from Spark server:\n%@",jd);
                completion(nil, parserError);
            });
            return;
        }
        
        completion(responseDict, nil);

        //NSLog(@"JGSparkAPI responseObject: %@",[responseObject description]);
    }];
    
}

-(void)setConfig:(NSDictionary *)config completion:(void (^)(NSError *))completion
{
    NSError *parserError;
    NSData *JSONBodyData = [NSJSONSerialization dataWithJSONObject:config
                                                           options:0 //NSJSONWritingPrettyPrinted
                                                             error:&parserError];
    
    NSString* JSONBodyString = [[NSString alloc] initWithData:JSONBodyData encoding:NSUTF8StringEncoding];
    
    if (parserError)
    {
        NSLog(@"ERROR: Could not parse input config dictionary data to JSON for spark cloud request");
        completion(parserError);
        return;
    }

    NSLog(@"* Parsed current UI change to JSON: \n%@",JSONBodyString);
    [[JGSparkAPI sharedAPI] runCommand:@"config" args:@[JSONBodyString] usingBlock:^(NSDictionary *responseObject, NSError *error) {
        NSLog(@"got responseObject:\n%@",[responseObject description]);
        completion(error);
    }];
    
   }

@end
