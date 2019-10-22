//
//  AMKRouter.h
//  AMKRouter
//
//  Created by 孟昕欣 on 2019/1/28.
//

#import <Foundation/Foundation.h>
#import "AMKRouter+Utilities.h"

/** 路由 */
@interface AMKRouter : NSObject

#pragma mark - Properties

/** 单例 */
@property(nonatomic, strong, readonly, nonnull, class) AMKRouter *sharedInstance;

/** 路由协议 */
@property(nonatomic, copy, nonnull) NSString *scheme;

/** 路由表 */
@property(nonatomic, readonly, nonnull) NSDictionary<NSString*, NSDictionary*> *routingTable;

/** 调试模式 */
@property(nonatomic, assign) BOOL debugEnable;

#pragma mark - Create Router Url String

/** 根据参数生成路由地址 */
- (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host path:(NSString *_Nullable)path params:(NSDictionary * _Nullable)params;
+ (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host path:(NSString *_Nullable)path params:(NSDictionary * _Nullable)params;
- (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host path:(NSString *_Nullable)path paramsBlock:(AMKRouterParamsBlock)paramsBlock;
+ (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host path:(NSString *_Nullable)path paramsBlock:(AMKRouterParamsBlock)paramsBlock;

/** 根据参数生成路由地址 */
- (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path params:(NSDictionary * _Nullable)params;
+ (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path params:(NSDictionary * _Nullable)params;
- (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path paramsBlock:(AMKRouterParamsBlock)paramsBlock;
+ (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path paramsBlock:(AMKRouterParamsBlock)paramsBlock;

#pragma mark - Extract Router Url In String

/** 提取字符串中的路由地址 */
- (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string;
+ (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string;

#pragma mark - Add Router Url

/** 注册路由规则，成功则返回YES，否则NO */
- (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *_Nonnull)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error;
+ (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *_Nonnull)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error;
- (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *_Nonnull)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *_Nonnull)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock;

/** 注册路由规则，成功则返回YES，否则NO */
- (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *_Nonnull)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error;
+ (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *_Nonnull)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error;
- (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *_Nonnull)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *_Nonnull)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock;

#pragma mark - Remove Router Url

/** 移除路由规则，成功则返回YES，否则NO */
- (BOOL)removeRouter:(NSString *_Nonnull)routingPattern error:(NSError *_Nullable *_Nullable)error;
+ (BOOL)removeRouter:(NSString *_Nonnull)routingPattern error:(NSError *_Nullable *_Nullable)error;
- (BOOL)removeRouter:(NSString *_Nonnull)routingPattern errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (BOOL)removeRouter:(NSString *_Nonnull)routingPattern errorBlock:(AMKRouterErrorBlock)errorBlock;

#pragma mark - Verify Router Url

/** 校验是否可以路由 */
- (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl error:(NSError *_Nullable *_Nullable)error;
+ (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl error:(NSError *_Nullable *_Nullable)error;
- (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl errorBlock:(AMKRouterErrorBlock)errorBlock;
+ (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl errorBlock:(AMKRouterErrorBlock)errorBlock;

#pragma mark - Perform Router Url

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
