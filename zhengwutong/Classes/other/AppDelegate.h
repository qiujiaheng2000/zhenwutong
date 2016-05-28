//
//  AppDelegate.h
//  zhengwutong
//
//  Created by qiujiaheng on 16/5/27.
//  Copyright © 2016年 leqimin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (AppDelegate*) currentAppDelegate;
// 当任意一此的http请求返回200时调用，不要在此函数中执行长时间任务
+ (void)onNetworkOK;
-(void)logoutByServer;
@end

