//
//  AMKRouter+Utilities.m
//  AMKRouter
//
//  Created by 孟昕欣 on 2019/10/22.
//

#import "AMKRouter+Utilities.h"

NSString * _Nonnull const AMKRouterErrorDomain = @"com.andy.amkits.router.error";

AMKRouterErrorCode AMKRouterSuccessErrorCode = 0;                               //!< 路由错误状态码：成功
AMKRouterErrorCode AMKRouterInvalidPatternErrorCode = 1;                        //!< 路由错误状态码：路由规则不合法
AMKRouterErrorCode AMKRouterExistedPatternErrorCode = 2;                        //!< 路由错误状态码：路由规则已存在
AMKRouterErrorCode AMKRouterInvalidTatgetErrorCode = 5;                         //!< 路由错误状态码：Target不合法
AMKRouterErrorCode AMKRouterInvalidActionErrorCode = 6;                         //!< 路由错误状态码：Action不合法
AMKRouterErrorCode AMKRouterInvalidSchemeErrorCode = 3;                         //!< 路由错误状态码：Scheme不合法
AMKRouterErrorCode AMKRouterInvalidHostErrorCode = 7;                           //!< 路由错误状态码：Host不合法
AMKRouterErrorCode AMKRouterInvalidPathErrorCode = 8;                           //!< 路由错误状态码：Path不合法
AMKRouterErrorCode AMKRouterUnknowErrorCode = NSNotFound;                       //!< 路由错误状态码：未知错误

NSString * _Nullable AMKLocalizedDescriptionFromRouterErrorCode(AMKRouterErrorCode errorCode) {
    NSString *localizedDescription = nil;
    if (errorCode == AMKRouterSuccessErrorCode) localizedDescription = @"成功";
    else if (errorCode == AMKRouterInvalidPatternErrorCode) localizedDescription = @"路由规则不合法";
    else if (errorCode == AMKRouterExistedPatternErrorCode) localizedDescription = @"路由规则已存在";
    else if (errorCode == AMKRouterInvalidTatgetErrorCode) localizedDescription = @"Target不合法";
    else if (errorCode == AMKRouterInvalidActionErrorCode) localizedDescription = @"Action不合法";
    else if (errorCode == AMKRouterInvalidSchemeErrorCode) localizedDescription = @"Scheme不合法";
    else if (errorCode == AMKRouterInvalidHostErrorCode) localizedDescription = @"Host不合法";
    else if (errorCode == AMKRouterInvalidPathErrorCode) localizedDescription = @"Path不合法";
    else localizedDescription = [NSString stringWithFormat:@"未知错误(%ld)", errorCode];
    return localizedDescription;
}

AMKRouterParamKey const AMKRouterUrlStringParamKey = @"__urlString";
AMKRouterParamKey const AMKRouterUrlPatternParamKey = @"__urlPattern";
AMKRouterParamKey const AMKRouterUrlSchemeParamKey = @"__urlScheme";
AMKRouterParamKey const AMKRouterUrlHostParamKey = @"__urlHost";
AMKRouterParamKey const AMKRouterUrlPathParamKey = @"__urlPath";
AMKRouterParamKey const AMKRouterUrlPathComponentsParamKey = @"__urlPathComponents";
AMKRouterParamKey const AMKRouterUrlParamsParamKey = @"__urlParams";
AMKRouterParamKey const AMKRouterUrlDispatcherParamKey = @"__urlDispatcher";

AMKRouterDispatcherParamKey const AMKRouterDispatcherNameParamKey = @"name";
AMKRouterDispatcherParamKey const AMKRouterDispatcherTargetParamKey = @"target";
AMKRouterDispatcherParamKey const AMKRouterDispatcherActionParamKey = @"action";
AMKRouterDispatcherParamKey const AMKRouterDispatcherDefaultsParamKey = @"defaults";
AMKRouterDispatcherParamKey const AMKRouterDispatcherCompletionBlockParamKey = @"completionBlock";
AMKRouterDispatcherParamKey const AMKRouterDispatcherShouldCacheTargetParamKey = @"shouldCacheTarget";

AMKRouterErrorBlock AMKRouterDefaultErrorBlock = ^(AMKRouter *router, NSError *error) {
    if (!error) return;
    NSLog(@"❌ 路由加载失败：%@ %@", error.localizedDescription, error.userInfo);
};


#pragma mark - NSString


@implementation NSString (AMKRouterUtilities)

- (NSString *)amkru_stringByAddingPercentEscapes {
    const char* original_str=[self UTF8String];
    NSString* sourceStr = [NSString stringWithCString:original_str encoding:NSUTF8StringEncoding];
    NSString *result = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)sourceStr, NULL, CFSTR(":/?#[]@!$&’()*+,;="), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return result;
}

- (NSString *)amkru_stringByReplacingPercentEscapes {
    const char* original_str=[self UTF8String];
    NSString* sourceStr = [NSString stringWithCString:original_str encoding:NSUTF8StringEncoding];
    NSString *result = (__bridge_transfer NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)sourceStr, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return result;
}

- (NSDictionary<NSString *, NSString *> * _Nullable)amkru_paramsForRouteQuery {
    NSMutableDictionary<NSString *, NSString *> *queryParams = [NSMutableDictionary dictionary];
    if (self.length) {
        NSArray *queryComponents = [self componentsSeparatedByString:@"&"];
        for (NSString *queryComponent in queryComponents) {
            if (!queryComponent.length) continue;
            
            NSString *key = @"";
            NSString *value = @"";
            NSRange range = [queryComponent rangeOfString:@"="];
            if (range.location != NSNotFound) {
                key = [queryComponent substringToIndex:range.location];
                value = [queryComponent substringFromIndex:range.location+range.length];
                value = [value amkru_stringByReplacingPercentEscapes]; // 完全解码
            } else {
                key = queryComponent;
            }
            [queryParams setObject:value forKey:key];
        }
    }
    return queryParams;
}

@end
