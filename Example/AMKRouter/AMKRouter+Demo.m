//
//  AMKRouter+Demo.m
//  AMKRouter_Example
//
//  Created by 孟昕欣 on 2019/1/28.
//  Copyright © 2019 AndyM129. All rights reserved.
//

#import "AMKRouter+Demo.h"
#import "AMKDispatcher.h"

NSString * const AMKRouterScheme = @"amkits";
NSString * const AMKRouterHost = @"demo.router.amkits.andy.com";
NSString * const AMKDemoTargetName = @"Demo";

@implementation AMKRouter (Demo)

+ (void)initialize {
    if (self != [AMKRouter class]) return;
    
    // 1. 配置AMKDispatcher分发服务（也可以省略，取默认值）
    AMKDispatcher.sharedInstance.targetPrefix = @"AMKTarget_";
    
    // 2. 配置路由
    AMKRouter.sharedInstance.scheme = AMKRouterScheme;
    AMKRouter.sharedInstance.debugEnable = YES;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 3. 注册路由
        [AMKRouter.sharedInstance addRouterWithHost:AMKRouterHost path:@"/view/gotoViewController" name:@"Goto ViewController（页面跳转）" forTarget:AMKDemoTargetName action:@"gotoViewControllerWithParams:" defaults:nil shouldCacheTarget:YES errorBlock:nil];
        
        [AMKRouter.sharedInstance addRouterWithHost:AMKRouterHost path:@"/view/alert" name:@"创建并显示弹窗" forTarget:AMKDemoTargetName action:@"alertWithParams:" defaults:nil shouldCacheTarget:NO errorBlock:nil];

        [AMKRouter.sharedInstance addRouterWithHost:AMKRouterHost path:@"/view/safari" name:@"前往GitHub查看完整说明" forTarget:AMKDemoTargetName action:@"gotoSafariWithParams:" defaults:nil shouldCacheTarget:NO errorBlock:nil];
    });
}

@end
