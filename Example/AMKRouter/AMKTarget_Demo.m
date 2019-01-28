//
//  AMKTarget_Demo.m
//  AMKRouter_Example
//
//  Created by 孟昕欣 on 2019/1/28.
//  Copyright © 2019 AndyM129. All rights reserved.
//

#import "AMKTarget_Demo.h"
#import "AMKRouter+Demo.h"

@implementation AMKTarget_Demo

- (UIViewController *_Nullable)Action_gotoViewControllerWithParams:(NSDictionary *_Nullable)params {
    NSString *className = params[@"class"];
    NSString *title = params[@"title"];
    Class class = NSClassFromString(className);
    if (!class) return nil;
    
    UIViewController *viewController = [[class alloc] init];
    if (![viewController isKindOfClass:UIViewController.class]) return nil;
    
    viewController.title = title;
    UINavigationController *rootViewController = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootViewController isKindOfClass:UINavigationController.class]) {
        [rootViewController pushViewController:viewController animated:YES];
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [rootViewController presentViewController:navigationController animated:YES completion:nil];
    }
    return viewController;
}

- (UIAlertView *_Nullable)Action_alertWithParams:(NSDictionary *_Nullable)params {
    NSString *title = params[@"title"];
    NSString *message = params[@"message"];
    NSString *cancelTitle = params[@"cancelTitle"]?:@"OK";

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelTitle otherButtonTitles:nil];
    [alertView show];
    return alertView;
}

- (NSError *)Action_gotoSafariWithParams:(NSDictionary *_Nullable)params {
    NSError *error = nil;
    NSString *url = [params[@"url"] stringByRemovingPercentEncoding];
    NSURL *URL = [[NSURL alloc] initWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    } else {
        error = [NSError errorWithDomain:AMKRouterErrorDomain code:-1 userInfo:nil];
    }
    return error;
}

@end
