//
//  AMKRouter+Utilities.h
//  AMKRouter
//
//  Created by 孟昕欣 on 2019/10/22.
//

#import <Foundation/Foundation.h>
@class AMKRouter;

/** 路由参数构造块 */
typedef void(^_Nullable AMKRouterParamsBlock)(NSMutableDictionary *_Nullable params);

/** 路由错误回调 */
typedef void(^_Nullable AMKRouterErrorBlock)(AMKRouter *_Nullable router, NSError *_Nullable error);

/** 路由错误域名 */
FOUNDATION_EXPORT NSString * _Nonnull const AMKRouterErrorDomain;

/** 路由错误状态码 */
typedef NSInteger AMKRouterErrorCode;
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterSuccessErrorCode;             //!< 路由错误状态码：成功
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterInvalidPatternErrorCode;      //!< 路由错误状态码：路由规则不合法
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterExistedPatternErrorCode;      //!< 路由错误状态码：路由规则已存在
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterInvalidTatgetErrorCode;       //!< 路由错误状态码：Target不合法
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterInvalidActionErrorCode;       //!< 路由错误状态码：Action不合法
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterInvalidSchemeErrorCode;       //!< 路由错误状态码：Scheme不合法
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterInvalidHostErrorCode;         //!< 路由错误状态码：Host不合法
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterInvalidPathErrorCode;         //!< 路由错误状态码：Path不合法
FOUNDATION_EXPORT AMKRouterErrorCode AMKRouterUnknowErrorCode;              //!< 路由错误状态码：未知错误

/** 路由相关状态码描述 */
NSString * _Nullable AMKLocalizedDescriptionFromRouterErrorCode(AMKRouterErrorCode errorCode);

/** 路由Url参数Key */
typedef NSString * _Nullable AMKRouterParamKey NS_EXTENSIBLE_STRING_ENUM;
FOUNDATION_EXPORT AMKRouterParamKey const AMKRouterUrlStringParamKey;           ///< 路由Url参数Key：路由地址
FOUNDATION_EXPORT AMKRouterParamKey const AMKRouterUrlPatternParamKey;          ///< 路由Url参数Key：路由规则
FOUNDATION_EXPORT AMKRouterParamKey const AMKRouterUrlSchemeParamKey;           ///< 路由Url参数Key：协议
FOUNDATION_EXPORT AMKRouterParamKey const AMKRouterUrlHostParamKey;             ///< 路由Url参数Key：主域名
FOUNDATION_EXPORT AMKRouterParamKey const AMKRouterUrlPathParamKey;             ///< 路由Url参数Key：路径(NSString)
FOUNDATION_EXPORT AMKRouterParamKey const AMKRouterUrlPathComponentsParamKey;   ///< 路由Url参数Key：路径(NSArray)
FOUNDATION_EXPORT AMKRouterParamKey const AMKRouterUrlParamsParamKey;           ///< 路由Url参数Key：参数字典
FOUNDATION_EXPORT AMKRouterParamKey const AMKRouterUrlDispatcherParamKey;       ///< 路由Url参数Key：Dispatcher信息

/** 路由Dispatcher参数Key */
typedef NSString * _Nullable AMKRouterDispatcherParamKey NS_EXTENSIBLE_STRING_ENUM;
FOUNDATION_EXPORT AMKRouterDispatcherParamKey const AMKRouterDispatcherNameParamKey;                ///< 路由Dispatcher参数Key：名称/说明
FOUNDATION_EXPORT AMKRouterDispatcherParamKey const AMKRouterDispatcherTargetParamKey;              ///< 路由Dispatcher参数Key：Target
FOUNDATION_EXPORT AMKRouterDispatcherParamKey const AMKRouterDispatcherActionParamKey;              ///< 路由Dispatcher参数Key：Action
FOUNDATION_EXPORT AMKRouterDispatcherParamKey const AMKRouterDispatcherDefaultsParamKey;            ///< 路由Dispatcher参数Key：默认参数（NSDictionary）
FOUNDATION_EXPORT AMKRouterDispatcherParamKey const AMKRouterDispatcherCompletionBlockParamKey;     ///< 路由Dispatcher参数Key：完成回调
FOUNDATION_EXPORT AMKRouterDispatcherParamKey const AMKRouterDispatcherShouldCacheTargetParamKey;   ///< 路由Dispatcher参数Key：ShouldCacheTarget（BOOL）

/** 路由Dispatcher参数 - 完成回调 */
typedef void(^_Nullable AMKRouterDispatcherCompletionBlock)(id _Nullable userInfo, NSError *_Nullable error);

/** 路由错误回调 */
FOUNDATION_EXPORT AMKRouterErrorBlock AMKRouterDefaultErrorBlock;


#pragma mark - NSString

@interface NSString (AMKRouterUtilities)

/// 当前字符串经过完全编码之后的字符串（包含 ":/?#[]@!$&’()*+,;=" x字符）
- (NSString *_Nullable)amkru_stringByAddingPercentEscapes;

/// 当前字符串经过完全解码之后的字符串（包含 ":/?#[]@!$&’()*+,;=" x字符）
- (NSString *_Nullable)amkru_stringByReplacingPercentEscapes;

/** 路由参数 */
- (NSDictionary<NSString *, NSString *> * _Nullable)amkru_paramsForRouteQuery;

@end
