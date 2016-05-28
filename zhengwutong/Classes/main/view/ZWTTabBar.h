//
//  TXTabBar.h
//  taoXiu
//
//  Created by jhqiu on 15/9/11.
//  Copyright (c) 2015年 jhqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZWTTabBar;

@protocol ZWTTabBarDelegate <NSObject>

@optional
-(void)tabbar:(ZWTTabBar *)tabbar didSelectedButtonFrom:(int) from to:(int) to;

@end

@interface ZWTTabBar : UIView
-(void)addTabbarButtonWithItem:(UITabBarItem *)item;

@property(nonatomic,weak) id<ZWTTabBarDelegate> delegate;
@end
