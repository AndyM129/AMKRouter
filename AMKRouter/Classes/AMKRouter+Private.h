//
//  AMKRouter+Private.h
//  AMKDispatcher
//
//  Created by 孟昕欣 on 2019/1/28.
//

#import <AMKRouter/AMKRouter.h>

#pragma mark - NSError

@interface NSError (AMKRouterPrivate)

/** 根据错误码、自定义信息 创建Error 对象  */
+ (instancetype _Nullable)amkrp_routerErrorWithCode:(NSInteger)code userInfoBlock:(void(^_Nullable)(NSMutableDictionary * _Nonnull userInfo))userInfoBlock;

@end

#pragma mark - NSString

@interface NSString (AMKRouterPrivate)

/** 补全路由处理 */
- (NSString *_Nonnull)amkrp_urlByCompletingRouteWithScheme:(NSString *_Nonnull)scheme;

@end
