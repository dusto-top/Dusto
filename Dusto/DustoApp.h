//
//  DustoApp.h
//  DustoDemo
//
//  Copyright © 2021 Dusto. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DustoApp : NSObject

+ (void)configureWithAccessKey:(NSString *)accessKey accessSecret:(NSString *)accessSecret NS_SWIFT_NAME(configure(accessKey:accessSecret:));

+ (nullable DustoApp *)defaultApp NS_SWIFT_NAME(app());

- (instancetype)init NS_UNAVAILABLE;

- (void)validatePurchaseWithPurchaseID:(NSString *)purchaseID userID:(nullable NSString *)userID completion:(nullable void (^)(NSError * _Nullable error, BOOL valid))completion NS_SWIFT_NAME(validatePurchase(purchaseID:userID:completion:));

@end

NS_ASSUME_NONNULL_END
