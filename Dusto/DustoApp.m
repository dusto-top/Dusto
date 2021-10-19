//
//  DustoApp.m
//  DustoDemo
//
//  Copyright © 2021 Dusto. All rights reserved.
//

#import "DustoApp.h"
#include <CommonCrypto/CommonCrypto.h>

static NSString *const kDustoErrorDomain = @"kDustoErrorDomain";
static NSString *const kDustoAPIHost = @"https://dusto.top";
static NSString *const kDustoPurchaseValidationAPI = @"/api/validate_purchase";

@interface DustoApp ()

@property(nonatomic, copy) NSString *accessKey;
@property(nonatomic, copy) NSString *accessSecret;

@end

@implementation DustoApp

static DustoApp *sDefaultApp;

+ (void)configureWithAccessKey:(NSString *)accessKey accessSecret:(NSString *)accessSecret {
    if (!accessKey || !accessSecret) {
        [NSException raise:kDustoErrorDomain format:@"Neither access key nor access secret can be nil."];
    }
    
    if (accessKey.length == 0 || accessSecret.length == 0) {
        [NSException raise:kDustoErrorDomain format:@"Neither access key nor access secret can be empty."];
    }
    
    DustoApp *app = [[DustoApp alloc] init];
    app.accessKey = [accessKey copy];
    app.accessSecret = [accessSecret copy];
    
    sDefaultApp = app;
}

+ (DustoApp *)defaultApp {
    if (sDefaultApp) {
        return sDefaultApp;
    }

    return nil;
}

- (void)validatePurchaseWithPurchaseID:(NSString *)purchaseID userID:(nullable NSString *)userID completion:(nullable void (^)(NSError * _Nullable error, BOOL valid))completion {
    if (!purchaseID || purchaseID.length == 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Purchase ID can not be empty."};
        NSError *error = [NSError errorWithDomain:kDustoErrorDomain code:NSURLErrorUnknown userInfo:userInfo];
        !completion ?: completion(error, NO);
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kDustoAPIHost, kDustoPurchaseValidationAPI]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *method = @"POST";
    request.HTTPMethod = method;
    
    NSString *timestamp = [NSString stringWithFormat:@"%.0f", [[NSDate new] timeIntervalSince1970]];
    [request setValue:timestamp forHTTPHeaderField:@"X-Auth-Timestamp"];
    
    NSMutableDictionary *params = [@{@"purchase_id": purchaseID} mutableCopy];
    if (userID.length > 0) {
        params[@"user_id"] = userID;
    }
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.HTTPBody = paramsData;
    
    NSString *paramsString = [self sortedParamsStringFromDict:params];
    
    NSMutableArray *signatureItems = [NSMutableArray new];
    [signatureItems addObject:method];
    [signatureItems addObject:kDustoPurchaseValidationAPI];
    [signatureItems addObject:paramsString];
    [signatureItems addObject:timestamp];
    NSString *signatureString = [signatureItems componentsJoinedByString:@"+"];
    
    NSString *signatureHash = [self hmacSHA256StringWithMessage:signatureString Key:self.accessSecret];
    NSString *signatureBase64 = [[signatureHash dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    [request setValue:[NSString stringWithFormat:@"DUSTO %@:%@", self.accessKey, signatureBase64] forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            !completion ?: completion(error, NO);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary *data = dict[@"data"];
            if (data) {
                NSString *status = data[@"status"];
                BOOL valid = [status isEqualToString:@"valid"];
                !completion ?: completion(nil, valid);
            } else {
                NSDictionary *userInfo = nil;
                NSString *message = dict[@"message"];
                if (message) {
                    userInfo = @{NSLocalizedDescriptionKey: message};
                }
                NSError *error = [NSError errorWithDomain:kDustoErrorDomain code:NSURLErrorUnknown userInfo:userInfo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    !completion ?: completion(error, NO);
                });
            }
        }
    }];
    [dataTask resume];
}


- (NSString *)hmacSHA256StringWithMessage:(NSString *)message Key:(NSString *)key {
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t size = CC_SHA256_DIGEST_LENGTH;
    unsigned char result[size];
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), data.bytes, data.length, result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:size * 2];
    for (int i = 0; i < size; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

- (NSString *)sortedParamsStringFromDict:(NSDictionary *)paramsDict {
    NSArray *sortedKeys = [paramsDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableArray *kvStrings = [NSMutableArray new];
    for (NSString *key in sortedKeys) {
        NSString *value = paramsDict[key];
        NSString *kvString = [NSString stringWithFormat:@"\"%@\":\"%@\"", key, value];
        [kvStrings addObject:kvString];
    }
    
    NSString *paramsString = [NSString stringWithFormat:@"{%@}", [kvStrings componentsJoinedByString:@","]];
    
    return paramsString;
}

@end
