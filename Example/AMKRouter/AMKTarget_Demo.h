//
//  AMKTarget_Demo.h
//  AMKRouter_Example
//
//  Created by 孟昕欣 on 2019/1/28.
//  Copyright © 2019 AndyM129. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMKTarget_Demo : NSObject

/** 创建并前往指定页面 */
- (UIViewController *_Nullable)Action_gotoViewControllerWithParams:(NSDictionary *_Nullable)params;

/** 创建并显示弹窗 */
- (UIAlertView *_Nullable)Action_alertWithParams:(NSDictionary *_Nullable)params;

/** 打开Safari */
- (NSError *)Action_gotoSafariWithParams:(NSDictionary *_Nullable)params;

@end

NS_ASSUME_NONNULL_END
