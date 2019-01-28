//
//  AMKRouter.m
//  AMKRouter
//
//  Created by 孟昕欣 on 2019/1/28.
//

#import "AMKRouter.h"
#import "AMKRouter+Private.h"
#import "AMKDispatcher.h"


@interface AMKRouter ()
@property(nonatomic, strong, nonnull) NSDictionary<NSString*, NSDictionary*> *routingTable;
@end

@implementation AMKRouter

#pragma mark - Init Methods

- (void)dealloc {
    
}

+ (instancetype _Nonnull)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self.class alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Properties

- (void)setScheme:(NSString *)scheme {
    NSAssert(scheme, @"无效参数值");
    NSAssert(!_scheme, @"请勿重复赋值");
    _scheme = scheme.copy;
}

- (NSDictionary<NSString *,NSDictionary *> *)routingTable {
    if (!_routingTable) {
        _routingTable = [NSMutableDictionary dictionary];
    }
    return _routingTable;
}

#pragma mark - Public Methods

- (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path params:(NSDictionary * _Nullable)params {
    __block NSMutableArray *keyValueStrings = [[NSMutableArray alloc] initWithCapacity:params.count];
    [params enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        [keyValueStrings addObject:[NSString stringWithFormat:@"%@=%@", key, obj?:@""]];
    }];
    return [NSString stringWithFormat:@"%@://%@%@%@%@%@%@%@", self.scheme, host?:@"", (port.length?@":":@""), port?:@"", ([path hasPrefix:@"/"]?@"":@"/"), path?:@"", ([path hasSuffix:@"?"]?@"":@"?"), [keyValueStrings componentsJoinedByString:@"&"]];
}

+ (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path params:(NSDictionary * _Nullable)params {
    return [[self sharedInstance] routerUrlWithHost:host port:port path:path params:params];
}

- (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path paramsBlock:(AMKRouterParamsBlock)paramsBlock {
    NSMutableDictionary *params = nil;
    if (paramsBlock) {
        params = [NSMutableDictionary dictionary];
        paramsBlock(params);
    }
    return [self routerUrlWithHost:host port:port path:path params:params];
}

+ (NSString *_Nullable)routerUrlWithHost:(NSString *_Nonnull)host port:(NSString *_Nullable)port path:(NSString *_Nullable)path paramsBlock:(AMKRouterParamsBlock)paramsBlock {
    return [[self sharedInstance] routerUrlWithHost:host port:port path:path paramsBlock:paramsBlock];
}

- (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string {
    return [self routerUrlInString:string appendParams:nil];
}

+ (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string {
    return [[self sharedInstance] routerUrlInString:string];
}

- (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string appendParams:(NSDictionary * _Nullable)params {
    if (!string.length) return nil;
    
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:@"%@://[^\\s]*", self.scheme];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAllowCommentsAndWhitespace error:&error];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSString *routerUrl = matches.count ? [string substringWithRange:matches.firstObject.range] : nil;
    return routerUrl;
}

+ (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string appendParams:(NSDictionary * _Nullable)params {
    return [[self sharedInstance] routerUrlInString:string appendParams:params];
}

- (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string appendParamsBlock:(AMKRouterParamsBlock)paramsBlock {
    NSMutableDictionary *params = nil;
    if (paramsBlock) {
        params = [NSMutableDictionary dictionary];
        paramsBlock(params);
    }
    return [self routerUrlInString:string appendParams:params];
}

+ (NSString *_Nullable)routerUrlInString:(NSString *_Nonnull)string appendParamsBlock:(AMKRouterParamsBlock)paramsBlock {
    return [[self sharedInstance] routerUrlInString:string appendParamsBlock:paramsBlock];
}

- (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error {
    NSAssert(_scheme.length, @"须先赋值 scheme 属性");
    
    NSMutableDictionary *dispatcherInfo = nil;
    if (!(error?*error:nil)) {
        // 参数信息
        dispatcherInfo = [NSMutableDictionary dictionary];
        dispatcherInfo[AMKRouterDispatcherNameParamKey] = name?:@"";
        dispatcherInfo[AMKRouterDispatcherTargetParamKey] = targetName?:@"";
        dispatcherInfo[AMKRouterDispatcherActionParamKey] = actionName?:@"";
        dispatcherInfo[AMKRouterDispatcherDefaultsParamKey] = defaults?:@{};
        dispatcherInfo[AMKRouterDispatcherShouldCacheTargetParamKey] = @(shouldCacheTarget);
        
        // 补全路由规则
        routingPattern = [routingPattern amk_urlByCompletingRouteWithScheme:self.scheme];
        
        // 参数有效性校验
        AMKRouterErrorCode errorCode = AMKRouterSuccessErrorCode;
        if (!routingPattern || ![routingPattern isKindOfClass:NSString.class] || !routingPattern.length) {
            errorCode = AMKRouterInvalidSchemeErrorCode;
        } else if (!targetName || ![targetName isKindOfClass:NSString.class] || !targetName.length) {
            errorCode = AMKRouterInvalidTatgetErrorCode;
        } else if (!actionName || ![actionName isKindOfClass:NSString.class] || !actionName.length) {
            errorCode = AMKRouterInvalidActionErrorCode;
        }
        
        // 判断是否已存在路由规则
        else if ([self.routingTable objectForKey:routingPattern]) {
            errorCode = AMKRouterExistedPatternErrorCode;
        }
        
        // 生成Error
        if (errorCode != AMKRouterSuccessErrorCode) {
            error!=nil ? *error = [NSError amk_routerErrorWithCode:errorCode userInfoBlock:^(NSMutableDictionary * _Nonnull userInfo) {
                userInfo[AMKRouterUrlPatternParamKey] = routingPattern?:@"";
                userInfo[AMKRouterUrlDispatcherParamKey] = dispatcherInfo;
            }] : nil;
        }
        
        // 校验规则有效性，并注册
        else if ([self respondsToRouterUrl:routingPattern error:error]){
            [(NSMutableDictionary *)self.routingTable setObject:dispatcherInfo forKey:routingPattern];
        }
    }
    
    // Debug信息
    if (self.debugEnable) NSLog(@"%@ 路由添加%@：%@ => %@%@", (error?*error:nil)?@"❌":@"✅", (error?*error:nil)?@"失败":@"成功", routingPattern.length?routingPattern:@"(空字符串)", [(error?*error:nil) localizedDescription]?:dispatcherInfo, [(error?*error:nil) userInfo]?:@"");
    
    return (error?*error:nil) ? NO : YES;
}

+ (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error {
    return [[self sharedInstance] addRouter:routingPattern name:name forTarget:targetName action:actionName defaults:defaults shouldCacheTarget:shouldCacheTarget error:error];
}

- (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock {
    NSError *error = nil;
    BOOL success = [self addRouter:routingPattern name:name forTarget:targetName action:actionName defaults:defaults shouldCacheTarget:shouldCacheTarget error:&error];
    errorBlock == nil ?: errorBlock(self, error);
    return success;
}

+ (BOOL)addRouter:(NSString *_Nonnull)routingPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock {
    return [[self sharedInstance] addRouter:routingPattern name:name forTarget:targetName action:actionName defaults:defaults shouldCacheTarget:shouldCacheTarget errorBlock:errorBlock];
}

- (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error {
    
    NSMutableDictionary *dispatcherInfo = nil;
    if (!(error?*error:nil)) {
        // 参数信息
        dispatcherInfo = [NSMutableDictionary dictionary];
        dispatcherInfo[AMKRouterDispatcherNameParamKey] = name?:@"";
        dispatcherInfo[AMKRouterDispatcherTargetParamKey] = targetName?:@"";
        dispatcherInfo[AMKRouterDispatcherActionParamKey] = actionName?:@"";
        dispatcherInfo[AMKRouterDispatcherDefaultsParamKey] = defaults?:@{};
        dispatcherInfo[AMKRouterDispatcherShouldCacheTargetParamKey] = @(shouldCacheTarget);
        
        // 参数有效性校验
        AMKRouterErrorCode errorCode = AMKRouterSuccessErrorCode;
        if (!host || ![host isKindOfClass:NSString.class] || !host.length || [host containsString:@"/"] || [host containsString:@"?"]) {
            errorCode = AMKRouterInvalidHostErrorCode;
        } else if (pathPattern && (![pathPattern isKindOfClass:NSString.class] || [pathPattern containsString:@"?"])) {
            errorCode = AMKRouterInvalidPathErrorCode;
        }
        
        // 错误信息
        if (errorCode != AMKRouterSuccessErrorCode) {
            error!=nil ? *error = [NSError amk_routerErrorWithCode:errorCode userInfoBlock:^(NSMutableDictionary * _Nonnull userInfo) {
                userInfo[AMKRouterUrlHostParamKey] = host?:@"";
                userInfo[AMKRouterUrlPathParamKey] = pathPattern?:@"";
                userInfo[AMKRouterUrlDispatcherParamKey] = dispatcherInfo;
            }] : nil;
        }
        
        // 执行
        [self addRouter:[NSString stringWithFormat:@"%@%@%@", host, [pathPattern hasPrefix:@"/"]?@"":@"/", pathPattern]  name:name forTarget:targetName action:actionName defaults:defaults shouldCacheTarget:shouldCacheTarget error:error];
    }
    
    return (error?*error:nil) ? NO : YES;
}

+ (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget error:(NSError *_Nullable *_Nullable)error {
    return [[self sharedInstance] addRouterWithHost:host path:pathPattern name:name forTarget:targetName action:actionName defaults:defaults shouldCacheTarget:shouldCacheTarget error:error];
}

- (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock {
    NSError *error = nil;
    BOOL success = [self addRouterWithHost:host path:pathPattern name:name forTarget:targetName action:actionName defaults:defaults shouldCacheTarget:shouldCacheTarget error:&error];
    errorBlock == nil ?: errorBlock(self, error);
    return success;
}

+ (BOOL)addRouterWithHost:(NSString *_Nullable)host path:(NSString *_Nonnull)pathPattern name:(NSString *)name forTarget:(NSString *_Nonnull)targetName action:(NSString *_Nonnull)actionName defaults:(NSDictionary *_Nullable)defaults shouldCacheTarget:(BOOL)shouldCacheTarget errorBlock:(AMKRouterErrorBlock)errorBlock {
    return [[self sharedInstance] addRouterWithHost:host path:pathPattern name:name forTarget:targetName action:actionName defaults:defaults shouldCacheTarget:shouldCacheTarget errorBlock:errorBlock];
}

- (BOOL)removeRouter:(NSString *_Nonnull)routingPattern error:(NSError *_Nullable *_Nullable)error {
    if (!(error?*error:nil)) {
        // 补全路由规则
        routingPattern = [routingPattern amk_urlByCompletingRouteWithScheme:self.scheme];
        
        // 移除路由规则
        [(NSMutableDictionary *)self.routingTable removeObjectForKey:routingPattern];
    }
    
    // Debug信息
    if (self.debugEnable) NSLog(@"%@ 路由移除%@：%@ => %@", (error?*error:nil)?@"❌":@"✅", (error?*error:nil)?@"失败":@"成功", routingPattern.length?routingPattern:@"(空字符串)", [(error?*error:nil) localizedDescription], [(error?*error:nil) userInfo]?:@"");
    
    return YES;
}

+ (BOOL)removeRouter:(NSString *_Nonnull)routingPattern error:(NSError *_Nullable *_Nullable)error {
    return [[self sharedInstance] removeRouter:routingPattern error:error];
}

- (BOOL)removeRouter:(NSString *_Nonnull)routingPattern errorBlock:(AMKRouterErrorBlock)errorBlock {
    NSError *error = nil;
    BOOL success = [self removeRouter:routingPattern error:&error];
    errorBlock == nil ?: errorBlock(self, error);
    return success;
}

+ (BOOL)removeRouter:(NSString *_Nonnull)routingPattern errorBlock:(AMKRouterErrorBlock)errorBlock {
    return [[self sharedInstance] removeRouter:routingPattern errorBlock:errorBlock];
}

- (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl error:(NSError *_Nullable *_Nullable)error {
    static NSString *routerUrlPrefix = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routerUrlPrefix = [NSString stringWithFormat:@"%@://", self.scheme];
    });
    
    BOOL respondsToRouterUrl = YES;
    if (!(error?*error:nil) && (!routerUrl || ![routerUrl isKindOfClass:NSString.class] || ![routerUrl hasPrefix:routerUrlPrefix])) {
        respondsToRouterUrl = NO;
        error!=nil ? *error = [NSError amk_routerErrorWithCode:AMKRouterInvalidSchemeErrorCode userInfoBlock:nil] : nil;
    }
    
    // Debug信息
    //if (self.debugEnable) NSLog(@"%@ 路由%@响应：%@ %@ %@", (error?*error:nil)?@"❌":@"✅", (error?*error:nil)?@"无法":@"可以", routerUrl.length?routerUrl:@"(空字符串)", (error?*error:nil)?@"=>":@"" ,[(error?*error:nil) localizedDescription]?:@"", [(error?*error:nil) userInfo]?:@"");
    
    return respondsToRouterUrl;
}

+ (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl error:(NSError *_Nullable *_Nullable)error {
    return [[self sharedInstance] respondsToRouterUrl:routerUrl error:error];
}

- (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl errorBlock:(AMKRouterErrorBlock)errorBlock {
    NSError *error = nil;
    BOOL success = [self respondsToRouterUrl:routerUrl error:&error];
    errorBlock == nil ?: errorBlock(self, error);
    return success;
}

+ (BOOL)respondsToRouterUrl:(NSString *_Nullable)routerUrl errorBlock:(AMKRouterErrorBlock)errorBlock {
    return [[self sharedInstance] respondsToRouterUrl:routerUrl errorBlock:errorBlock];
}

- (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl params:(NSDictionary * _Nullable)params error:(NSError * _Nullable * _Nullable)error {
    id returnObject = nil;
    
    if (!(error?*error:nil)) {
        // 有效性校验
        if ([self respondsToRouterUrl:routerUrl error:error]) {
            // 解析参数
            NSDictionary *routerUrlParams = [self paramsWithRouterUrl:routerUrl params:params];
            NSDictionary *dispatcherInfo = [routerUrlParams objectForKey:AMKRouterUrlDispatcherParamKey];
            if (![dispatcherInfo isKindOfClass:NSDictionary.class]) dispatcherInfo = nil;
            
            // 执行
            NSString *targetName = [dispatcherInfo objectForKey:AMKRouterDispatcherTargetParamKey];
            NSString *actionName = [dispatcherInfo objectForKey:AMKRouterDispatcherActionParamKey];
            BOOL shouldCacheTarget = [[dispatcherInfo objectForKey:AMKRouterDispatcherShouldCacheTargetParamKey] boolValue];
            NSMutableDictionary *dispatcherParams = nil;
            if (!targetName.length || !targetName.length) {
                dispatcherParams = routerUrlParams.mutableCopy;
            } else {
                dispatcherParams = ({
                    NSDictionary *urlParams = [routerUrlParams objectForKey:AMKRouterUrlParamsParamKey];
                    NSDictionary *dispatcherDefaultParams = [dispatcherInfo objectForKey:AMKRouterDispatcherDefaultsParamKey]?:@{};
                    NSMutableDictionary *dispatcherParams = [dispatcherDefaultParams mutableCopy];
                    [dispatcherParams addEntriesFromDictionary:urlParams];
                    dispatcherParams;
                });
            }
            returnObject = [AMKDispatcher.sharedInstance performTarget:targetName action:actionName params:dispatcherParams shouldCacheTarget:shouldCacheTarget];
        }
    }
    
    // Debug信息
    if (self.debugEnable) NSLog(@"%@ 路由执行%@：%@ => %@", (error?*error:nil)?@"❌":@"✅", (error?*error:nil)?@"失败":@"成功", routerUrl.length?routerUrl:@"(空字符串)", [(error?(error?*error:nil):nil) localizedDescription]?:returnObject, [(error?*error:nil) userInfo]?:@"");
    
    return returnObject;
}

+ (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl params:(NSDictionary * _Nullable)params error:(NSError * _Nullable * _Nullable)error {
    return [[self sharedInstance] performRouterUrl:routerUrl params:params error:error];
}

- (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl params:(NSDictionary * _Nullable)params errorBlock:(AMKRouterErrorBlock)errorBlock {
    NSError *error = nil;
    id object = [self performRouterUrl:routerUrl params:params error:&error];
    errorBlock == nil ?: errorBlock(self, error);
    return object;
}

+ (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl params:(NSDictionary * _Nullable)params errorBlock:(AMKRouterErrorBlock)errorBlock {
    return [[self sharedInstance] performRouterUrl:routerUrl params:params errorBlock:errorBlock];
}

- (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl paramsBlock:(AMKRouterParamsBlock)paramsBlock error:(NSError * _Nullable * _Nullable)error {
    NSMutableDictionary *params = nil;
    if (paramsBlock) {
        params = [NSMutableDictionary dictionary];
        paramsBlock(params);
    }
    return [self performRouterUrl:routerUrl params:params error:error];
}

+ (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl paramsBlock:(AMKRouterParamsBlock)paramsBlock error:(NSError * _Nullable * _Nullable)error {
    return [[self sharedInstance] performRouterUrl:routerUrl paramsBlock:paramsBlock error:error];
}

- (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl paramsBlock:(AMKRouterParamsBlock)paramsBlock errorBlock:(AMKRouterErrorBlock)errorBlock {
    NSError *error = nil;
    id object = [self performRouterUrl:routerUrl paramsBlock:paramsBlock error:&error];
    errorBlock == nil ?: errorBlock(self, error);
    return object;
}

+ (id _Nullable)performRouterUrl:(NSString * _Nullable)routerUrl paramsBlock:(AMKRouterParamsBlock)paramsBlock errorBlock:(AMKRouterErrorBlock)errorBlock {
    return [[self sharedInstance] performRouterUrl:routerUrl paramsBlock:paramsBlock errorBlock:errorBlock];;
}

#pragma mark - Private Methods

#pragma mark - Notifications

#pragma mark - KVO

#pragma mark - Delegate

#pragma mark - Override

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@, %p> %@", NSStringFromClass(self.class), self, self.routingTable];
}

#pragma mark - Helper Methods

- (NSDictionary *)paramsWithRouterUrl:(NSString *)routerUrl params:(NSDictionary * _Nullable)params {
    NSMutableDictionary *routerUrlParams = [NSMutableDictionary dictionary];
    
    // 解析并合并 routerUrl 与 params 参数
    NSArray<NSString *> *schemaHostPathParams = [routerUrl componentsSeparatedByString:@"?"];
    NSString *schemaHostPathStr = schemaHostPathParams.firstObject;
    NSArray<NSString *> *schemaHostPath = [schemaHostPathStr componentsSeparatedByString:@"://"];
    NSString *schema = schemaHostPath.firstObject;
    routerUrlParams[AMKRouterUrlSchemeParamKey] = schema?:@"";
    
    NSString *hostPathStr = schemaHostPath.count>1 ? [schemaHostPath objectAtIndex:1] : nil;
    NSArray<NSString *> *hostPath = [hostPathStr componentsSeparatedByString:@"/"];
    routerUrlParams[AMKRouterUrlHostParamKey] = hostPath.count>0 ? hostPath.firstObject : hostPathStr;
    routerUrlParams[AMKRouterUrlPathComponentsParamKey] = hostPath.count>0 ? [hostPath subarrayWithRange:NSMakeRange(1, hostPath.count-1)] : [NSArray array];
    routerUrlParams[AMKRouterUrlParamsParamKey] = (schemaHostPathParams.count > 1 ? [schemaHostPathParams objectAtIndex:1].amk_paramsForRouteQuery : @{}).mutableCopy;
    if (params && [params isKindOfClass:NSDictionary.class] && params.count) {
        [routerUrlParams[AMKRouterUrlParamsParamKey] addEntriesFromDictionary:params];
    }
    routerUrlParams[AMKRouterUrlStringParamKey] = routerUrl?:@"";
    
    // 解析Target、Action
    NSDictionary *dispatcherInfo = [self.routingTable objectForKey:schemaHostPathStr];
    if (![dispatcherInfo isKindOfClass:NSDictionary.class]) dispatcherInfo = nil;
    routerUrlParams[AMKRouterUrlDispatcherParamKey] = dispatcherInfo?:@{};
    return routerUrlParams;
}

@end

#pragma mark -

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
