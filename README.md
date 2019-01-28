# AMKRouter

[![CI Status](https://img.shields.io/travis/AndyM129/AMKRouter.svg?style=flat)](https://travis-ci.org/AndyM129/AMKRouter)
[![Version](https://img.shields.io/cocoapods/v/AMKRouter.svg?style=flat)](https://cocoapods.org/pods/AMKRouter)
[![License](https://img.shields.io/cocoapods/l/AMKRouter.svg?style=flat)](https://cocoapods.org/pods/AMKRouter)
[![Platform](https://img.shields.io/cocoapods/p/AMKRouter.svg?style=flat)](https://cocoapods.org/pods/AMKRouter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AMKRouter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AMKRouter'
```
## Usage

### 1. 配置AMKDispatcher分发服务（也可以省略，取默认值）

```objective-c
AMKDispatcher.sharedInstance.targetPrefix = @"AMKTarget_";
```

### 2. 配置路由
```objective-c
AMKRouter.sharedInstance.scheme = AMKRouterScheme;
AMKRouter.sharedInstance.debugEnable = YES;
```

### 3. 注册路由

```objective-c
NSString * const AMKRouterScheme = @"amkits";
NSString * const AMKRouterHost = @"demo.router.amkits.andy.com";
NSString * const AMKDemoTargetName = @"Demo";

[AMKRouter.sharedInstance addRouterWithHost:AMKRouterHost path:@"/view/gotoViewController" name:@"Goto ViewController（页面跳转）" forTarget:AMKDemoTargetName action:@"gotoViewControllerWithParams:" defaults:nil shouldCacheTarget:YES errorBlock:nil];
        
[AMKRouter.sharedInstance addRouterWithHost:AMKRouterHost path:@"/view/alert" name:@"创建并显示弹窗" forTarget:AMKDemoTargetName action:@"alertWithParams:" defaults:nil shouldCacheTarget:NO errorBlock:nil];

[AMKRouter.sharedInstance addRouterWithHost:AMKRouterHost path:@"/view/safari" name:@"前往GitHub查看完整说明" forTarget:AMKDemoTargetName action:@"gotoSafariWithParams:" defaults:nil shouldCacheTarget:NO errorBlock:nil];
```

### 4. 实现路由

```objective-c
@interface AMKTarget_Demo : NSObject

/** 创建并前往指定页面 */
- (UIViewController *_Nullable)Action_gotoViewControllerWithParams:(NSDictionary *_Nullable)params;

/** 创建并显示弹窗 */
- (UIAlertView *_Nullable)Action_alertWithParams:(NSDictionary *_Nullable)params;

/** 打开Safari */
- (NSError *)Action_gotoSafariWithParams:(NSDictionary *_Nullable)params;

@end
    
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
```

### 5. 按照业务逻辑，执行路由

```objective-c
// 示例路由
NSMutableDictionary *dataSource = [NSMutableDictionary dictionary];
        dataSource[@"amkits://demo.router.amkits.andy.com/view/safari?url=https%3a%2f%2fgithub.com%2fAndyM129%2fAMKLocaleDescription%2ftree%2fmaster"] = @"前往GitHub查看完整说明 👉";
        dataSource[@"amkits://demo.router.amkits.andy.com/view/gotoViewController?class=AMKViewController&title=路由跳转示例"] = @"创建并前往指定页面";
        dataSource[@"amkits://demo.router.amkits.andy.com/view/alert?title=标题&message=弹窗提示文案&cancelTitle=知道啦"] = @"创建并显示弹窗";
        
// 执行(支持返回值及异步回调)
NSString *router = self.dataSource.allKeys[indexPath.row];
id object = [AMKRouter performRouterUrl:router paramsBlock:nil errorBlock:nil];
```

### \*附：AMKRouter的属性&接口

```objective-c
/** 路由 */
@interface AMKRouter : NSObject

/** 单例 */
@property(nonatomic, strong, readonly, nonnull, class) AMKRouter *sharedInstance;

/** 路由协议 */
@property(nonatomic, copy, nonnull) NSString *scheme;

/** 路由表 */
@property(nonatomic, readonly, nonnull) NSDictionary<NSString*, NSDictionary*> *routingTable;

/** 调试模式 */
@property(nonatomic, assign) BOOL debugEnable;

/** 根据参数生成路由地址 */
- (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path params:(NSDictionary * _Nullable)params;
+ (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path params:(NSDictionary * _Nullable)params;
- (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path paramsBlock:(AMKRouterParamsBlock)paramsBlock;
+ (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path paramsBlock:(AMKRouterParamsBlock)paramsBlock;

/** 提取字符串中的路由地址 */
- (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string;
+ (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string;

/** 注册路由规则，成功则返回YES，否则NO */
- (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error;
+ (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error;
- (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock;

/** 注册路由规则，成功则返回YES，否则NO */
- (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error;
+ (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error;
- (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock;

/** 移除路由规则，成功则返回YES，否则NO */
- (BOOL)removeRouter:(NSString *_Nonnull)routingPattern error:(NSError *_Nullable *_Nullable)error;
+ (BOOL)removeRouter:(NSString *_Nonnull)routingPattern error:(NSError *_Nullable *_Nullable)error;
- (BOOL)removeRouter:(NSString *_Nonnull)routingPattern errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (BOOL)removeRouter:(NSString *_Nonnull)routingPattern errorBlock:(AMKRouterErrorBlock)errorBlock;

/** 校验是否可以路由 */
- (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl error:(NSError *_Nullable *_Nullable)error;
+ (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl error:(NSError *_Nullable *_Nullable)error;
- (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl errorBlock:(AMKRouterErrorBlock)errorBlock;

/** 执行路由，注：参数params的优先级要高于urlString中的参数值！ */
- (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl params:(NSDictionary * _Nullable)params error:(NSError * _Nullable * _Nullable)error;
+ (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl params:(NSDictionary * _Nullable)params error:(NSError * _Nullable * _Nullable)error;
- (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl params:(NSDictionary * _Nullable)params errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl params:(NSDictionary * _Nullable)params errorBlock:(AMKRouterErrorBlock)errorBlock;

/** 执行路由，注：参数params的优先级要高于urlString中的参数值！ */
- (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl paramsBlock:(AMKRouterParamsBlock)paramsBlock error:(NSError * _Nullable * _Nullable)error;
+ (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl paramsBlock:(AMKRouterParamsBlock)paramsBlock error:(NSError * _Nullable * _Nullable)error;
- (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl paramsBlock:(AMKRouterParamsBlock)paramsBlock errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl paramsBlock:(AMKRouterParamsBlock)paramsBlock errorBlock:(AMKRouterErrorBlock)errorBlock;

@end
```

## Author

AndyM129, mengxinxin@baidu.com

## License

AMKRouter is available under the MIT license. See the LICENSE file for more info.
