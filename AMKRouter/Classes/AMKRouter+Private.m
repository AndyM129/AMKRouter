//
//  AMKRouter+Private.m
//  AMKDispatcher
//
//  Created by 孟昕欣 on 2019/1/28.
//

#import "AMKRouter+Private.h"

#pragma mark - NSError

@implementation NSError (AMKRouterPrivate)

+ (instancetype)amkrp_routerErrorWithCode:(NSInteger)code userInfoBlock:(void(^_Nullable)(NSMutableDictionary * _Nonnull userInfo))userInfoBlock {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    // 错误描述
    NSString *localizedDescription = AMKLocalizedDescriptionFromRouterErrorCode(code);
    if (localizedDescription) {
        userInfo[NSLocalizedDescriptionKey] = localizedDescription;
    }
    
    // 自定义参数
    if (userInfoBlock) {
        userInfoBlock(userInfo);
    }
    
    return [NSError errorWithDomain:AMKRouterErrorDomain code:code userInfo:userInfo];
}

@end

#pragma mark - NSString

@implementation NSString (AMKRouterPrivate)

- (NSString *_Nonnull)amkrp_urlByCompletingRouteWithScheme:(NSString *)scheme {
    // 若路由完整，则直接返回，如 aa://aaa/bb/cc
    if ([self containsString:@"://"]) {
        return self;
    }
    // 若缺少scheme则补全，如 ://aaa/bb/cc
    if ([self rangeOfString:@"://"].location == 0) {
        return [NSString stringWithFormat:@"%@%@", scheme, self];
    }
    // 若缺少scheme则补全，如 //aaa/bb/cc
    if ([self rangeOfString:@"//"].location == 0) {
        return [NSString stringWithFormat:@"%@%@", scheme, [self substringFromIndex:MIN(2, self.length)]];
    }
    // 若缺少scheme则补全，如 /aaa/bb/cc
    if ([self rangeOfString:@"/"].location == 0) {
        return [NSString stringWithFormat:@"%@:/%@", scheme, self];
    }
    // host/path1/path2
    return [NSString stringWithFormat:@"%@://%@", scheme, self];;
}

@end
