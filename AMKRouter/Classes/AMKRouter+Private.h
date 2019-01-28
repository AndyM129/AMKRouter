//
//  AMKRouter+Private.h
//  AMKDispatcher
//
//  Created by 孟昕欣 on 2019/1/28.
//

#import <AMKRouter/AMKRouter.h>

#pragma mark - NSError

@interface NSError (AMKRouter)

+ (instancetype)amk_routerErrorWithCode:(NSInteger)code userInfoBlock:(void(^_Nullable)(NSMutableDictionary * _Nonnull userInfo))userInfoBlock;

@end

#pragma mark - NSString

@interface NSString (AMKRouter)

/** 补全路由处理 */
- (NSString *_Nonnull)amk_urlByCompletingRouteWithScheme:(NSString *)scheme;

/** 路由参数 */
- (NSDictionary<NSString *, NSString *> * _Nullable)amk_paramsForRouteQuery;

@end
