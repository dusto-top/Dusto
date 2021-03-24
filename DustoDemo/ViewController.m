//
//  ViewController.m
//  DustoDemo
//
//  Copyright © 2021 Dusto. All rights reserved.
//

#import "ViewController.h"
#import <CloudKit/CloudKit.h>
#import "IAPShare.h"
#import "DustoApp.h"

static NSString *const kDustoDemoErrorDomain = @"kDustoErrorDomain";
static NSString *const kIAPSharedSecret = @"replace with your secret";

@interface ViewController ()<SKRequestDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pidLabel;
@property (weak, nonatomic) IBOutlet UILabel *uidLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) NSString *purchaseID;
@property (nonatomic, strong) NSString *userID;

//IAP
@property (nonatomic, strong) void (^purchaseIDCompletion)(NSError * _Nullable error, NSString * _Nullable purchaseID);
@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pidLabel.text = nil;
    self.uidLabel.text = nil;
    self.statusLabel.text = nil;
}

- (IBAction)getPIDAction:(id)sender {
    __weak __typeof(self)weakSelf = self;
    [self getPurchaseIDWithCompletion:^(NSError * _Nullable error, NSString * _Nullable purchaseID) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (error) {
            strongSelf.pidLabel.text = error.userInfo[NSLocalizedDescriptionKey];
            strongSelf.purchaseID = nil;
            return;
        }
        
        if (purchaseID) {
            strongSelf.purchaseID = purchaseID;
            strongSelf.uidLabel.text = strongSelf.purchaseID;
        }
    }];
}

- (IBAction)getUIDAction:(id)sender {
    __weak __typeof(self)weakSelf = self;
    [[CKContainer defaultContainer] fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                strongSelf.uidLabel.text = error.userInfo[NSLocalizedDescriptionKey];
                strongSelf.userID = nil;
                return;
            }
            
            if (recordID.recordName) {
                strongSelf.userID = recordID.recordName;
                strongSelf.uidLabel.text = strongSelf.userID;
            }
        });
    }];
}

- (IBAction)validateAction:(id)sender {
    if (!self.purchaseID || self.purchaseID.length == 0) {
        self.statusLabel.text = @"Purchase ID can't be empty";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.statusLabel.text = nil;
        });
        return;
    }
    
    [[DustoApp defaultApp] validatePurchaseWithPurchaseID:self.purchaseID userID:self.userID completion:^(NSError * _Nullable error, BOOL valid) {
        if (error) {
            self.statusLabel.text = error.userInfo[NSLocalizedDescriptionKey];
            return;
        }
        
        self.statusLabel.text = valid ? @"Valid purchase" : @"Invalid purchase";
    }];
}

#pragma mark - IAP

- (void)getPurchaseIDWithCompletion:(void (^)(NSError *error, NSString *purchaseId))completion {
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:receiptURL.path]) {
        NSData *data = [NSData dataWithContentsOfURL:receiptURL];
        [[IAPShare sharedHelper].iap checkReceipt:data AndSharedSecret:kIAPSharedSecret onCompletion:^(NSString *response, NSError *error) {
            if (error) {
                completion(error, nil);
                return;
            }
            
            NSDictionary* info = [[self class] toJSON:response];

            NSInteger status = [info[@"status"] integerValue];
            if (status == 21007) {
                [IAPShare sharedHelper].iap.production = NO;
                [self getPurchaseIDWithCompletion:completion];
                return;
            } else if (status == 0) {
                NSDictionary *receipt = info[@"receipt"];
                NSString *purchaseID = receipt[@"original_purchase_date_ms"];
                !completion ?: completion(nil, purchaseID);
            } else {
                error = [[NSError alloc] initWithDomain:kDustoDemoErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Validation failed."}];
                !completion ?: completion(error, nil);
            }
        }];
    } else {
        self.purchaseIDCompletion = completion;
        [self refreshReceipt];
    }
}

- (void)refreshReceipt {
    if (self.isRefreshing) {
        return;
    }
    
    self.isRefreshing = YES;
    SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
    request.delegate = self;
    [request start];
}

- (void)requestDidFinish:(SKRequest *)request {
    self.isRefreshing = NO;
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:receiptURL.path]) {
        [self getPurchaseIDWithCompletion:self.purchaseIDCompletion];
    } else {
        NSError *error = [[NSError alloc] initWithDomain:kDustoDemoErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Can't get the receipt."}];
        !self.purchaseIDCompletion ?: self.purchaseIDCompletion(error, nil);
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    self.isRefreshing = NO;
    !self.purchaseIDCompletion ?: self.purchaseIDCompletion(error, nil);
}

@end
