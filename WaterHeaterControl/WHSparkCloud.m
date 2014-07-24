//
//  FMServer.m
//  SelfMe
//
//  Created by Ido on 5/15/14.
//  Copyright (c) 2014 FaceMe. All rights reserved.
//

#import "WHSparkCloud.h"

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

        
    }
    return i;
}


-(void)getConfig:(void (^)(NSDictionary *, NSError *))completion
{
    
    NSString *urlStr = [NSString stringWithFormat:WH_SPARK_API_CONFIG,SPARK_DEVICE_ID,SPARK_ACCESS_TOKEN];
    NSURL *url = [NSURL URLWithString:[self encodeURL:urlStr]];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"GET";
    
    [self serverRequest:req completion:^(id response, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            completion(nil, error);
            return;
        }
        
        NSDictionary *responseDict = response;
        completion(responseDict, nil);
    }];
}



-(void)getActive:(void (^)(BOOL, NSError *))completion
{

    NSString *urlStr = [NSString stringWithFormat:WH_SPARK_API_ACTIVE,SPARK_DEVICE_ID,SPARK_ACCESS_TOKEN];
    NSURL *url = [NSURL URLWithString:[self encodeURL:urlStr]];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
    
    req.HTTPMethod = @"GET";
    
    [self serverRequest:req completion:^(id response, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            completion(NO, error);
            return;
        }
        
        if ([response isKindOfClass:[NSNumber class]])
        {
            NSNumber *responseActive = response;
            completion(([responseActive intValue]) ? YES : NO, nil);
        }
        else
        {
            NSError *error = MakeErrorWithMessage(@"Invalid response data type");
            completion(NO, error);
        }
        
    }];
}

-(void)setConfig:(NSDictionary *)config completion:(void (^)(NSError *))completion
{
    NSString *urlStr = [NSString stringWithFormat:WH_SPARK_API_CONFIG,SPARK_DEVICE_ID,SPARK_ACCESS_TOKEN];
    NSURL *url = [NSURL URLWithString:[self encodeURL:urlStr]];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; // check
    
    /*
    NSMutableDictionary *requestBodyDict = [[NSMutableDictionary alloc] init];
    
    // prepare main request body
    requestBodyDict[@"appVersion"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableArray *allSearchNumbersArr = [[NSMutableArray alloc] initWithCapacity:searchNumbers.count];
    
    for (NSArray* contactSearchNumbers in searchNumbers)
    {
        [allSearchNumbersArr addObject:@{@"searchNumbers" : contactSearchNumbers}];
    }
    
    if (allSearchNumbersArr.count == 0)
    {
        NSError *error = MakeErrorWithMessage(@"no searchNumbers found in request");
        completion(nil, error);
        return;
    }
    requestBodyDict[@"contacts"] = allSearchNumbersArr;
     */
    
    NSError *error;
    NSData *JSONBodyData = [NSJSONSerialization dataWithJSONObject:config
                                                           options:0 //NSJSONWritingPrettyPrinted
                                                             error:&error];
    
    if (error)
    {
        NSLog(@"ERROR: Could not parse input config dictionary data to JSON for spark cloud request");
        completion(error);
        return;
    }
    
    req.HTTPBody = JSONBodyData;
    
    
    [self serverRequest:req completion:^(id response, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            completion(error);
            return;
        }
        
        completion(nil);
    }];
}


-(void)setActive:(BOOL)active completion:(void (^)(NSError *))completion
{
    NSString *urlStr = [NSString stringWithFormat:WH_SPARK_API_ACTIVE,SPARK_DEVICE_ID,SPARK_ACCESS_TOKEN];
    NSURL *url = [NSURL URLWithString:[self encodeURL:urlStr]];
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:@"text/html" forHTTPHeaderField:@"Content-Type"]; // check
    
    NSString *bodyChar;
    bodyChar = ((active) ? @"1" : @"0");
    
    
    req.HTTPBody = [NSData dataWithBytes:[bodyChar cStringUsingEncoding:NSStringEncodingConversionAllowLossy] length:1];
    
    
    [self serverRequest:req completion:^(id response, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            completion(error);
            return;
        }
        
        completion(nil);
    }];
}





// Server utils
-(NSString *)encodeURL:(NSString *)urlString // check if can be done via API correctly
{
    NSString *encodedStr;
    encodedStr = [urlString stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
    encodedStr = [encodedStr stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    encodedStr = [encodedStr stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
    encodedStr = [encodedStr stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    return encodedStr;
}


- (void)serverRequest:(NSURLRequest*)request completion:(void(^)(id response, NSError* error))completion {
    [self serverRequest:request retries:3 completion:completion];
    
    //    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    //    [NSURLConnection connectionWithRequest:request delegate:self];

}

- (void)serverRequest:(NSURLRequest*)request retries:(NSInteger)retryCount completion:(void(^)(id response, NSError* error))completion {
    NSMutableURLRequest *req = [request mutableCopy];
    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if (retryCount > 1) {
                // recurse with new retry-count
                [self serverRequest:request retries:(retryCount - 1) completion:completion];
                return;
            }
            
            // no more retries
            NSLog(@"SMServer API call error (no more retries): %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode != 200) {
            id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:0];
            NSError* e;
            if (!obj) {
                NSString* s = [data UTF8String];
                if (s.length == 0) {
                    s = @"Request Failed";
                }
                
                e = MakeError(s, httpResponse.statusCode);
            }
            else {
                NSString* errorMessage = obj[@"error"];
                if (!errorMessage) {
                    errorMessage = @"Request Failed";
                }
                
                e = MakeErrorWithMessage(errorMessage);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"API ERROR: %@", e);
                completion(nil, e);
            });
            return;
        }
        
        // debug:
//        NSLog(@"Got response with headers: \n%@",[httpResponse.allHeaderFields description]);
        
        id obj;
        //if ([httpResponse.allHeaderFields[@"Content-Type"] isEqualToString:@"application/json"])

        if ([httpResponse.allHeaderFields[@"Content-Type"] rangeOfString:@"json"].location != NSNotFound) // content is JSON (application/x-selfme-data_json)
        {
            NSLog(@"SMServer: Parsing JSON response from server");
            obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        }
        else
        {
            NSLog(@"SMServer: Passing binary response from server");
            obj = data; // content is binary (probably image)

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(obj, nil);
        });
        
    }] resume];
}


NSError* MakeErrorWithMessage(NSString* desc) {
    NSError* error = [NSError errorWithDomain:@"SMServer" code:0 userInfo:@{ NSLocalizedDescriptionKey: desc }];
    NSLog(@"ERROR: %@",desc);
    return error;
}

NSError* MakeError(NSString* desc, NSInteger code) {
    NSString* f = [NSString stringWithFormat:@"%ld: %@", (long)code, desc];
    NSError* error = [NSError errorWithDomain:@"SMServer" code:0 userInfo:@{ NSLocalizedDescriptionKey: f }];
    NSLog(@"ERROR code %ld: %@",(long)code,desc);
    return error;
}

@end

@implementation NSData (UTF8)

- (NSString *)UTF8String {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end
