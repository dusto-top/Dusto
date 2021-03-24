//
//  AppDelegate.m
//  DustoDemo
//
//  Copyright © 2021 Dusto. All rights reserved.
//

#import "AppDelegate.h"
#import "DustoApp.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DustoApp configureWithAccessKey:@"g_5odhWDLKivrqww" accessSecret:@"s4EvVXb1KvOUDLzLJNDna6wTwY0lvHn1"];
     
    return YES;
}

@end
