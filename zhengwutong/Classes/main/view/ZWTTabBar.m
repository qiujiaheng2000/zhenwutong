//
//  TXTabBar.m
//  taoXiu
//
//  Created by jhqiu on 15/9/11.
//  Copyright (c) 2015年 jhqiu. All rights reserved.
//

#import "ZWTTabBar.h"
#import "ZWTTabbarButton.h"


@interface ZWTTabBar()
//选中的button
@property(nonatomic,weak)ZWTTabbarButton *selectedButton;

@end

@implementation ZWTTabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/**
 *  根据UITabBarItem 来添加底部tabbarbutton
 *
 *  @param item UITabBarItem
 */
-(void)addTabbarButtonWithItem:(UITabBarItem *)item
{
    //创建按钮
    ZWTTabbarButton *button  = [[ZWTTabbarButton alloc]init];
    
    [self addSubview:button];
    //设置按钮的数据
    button.item = item;
    
    //设置按钮的点击
    [button addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchDown];
    
    //默认选中第0个按钮
    if (self.subviews.count == 1) {
        [self buttonOnClick:button];
    }
}

/**
 *  按钮的点击事件
 *
 *  @param button 被点击的按钮
 */
-(void)buttonOnClick:(ZWTTabbarButton *)button
{
    //1.通知代理
    if ([self.delegate respondsToSelector:@selector(tabbar:didSelectedButtonFrom:to:)]) {
        [self.delegate tabbar:self didSelectedButtonFrom:self.selectedButton.tag to:button.tag];
    }
    //设置按钮的状态
    self.selectedButton.selected = NO;
    button.selected = YES;
    self.selectedButton = button;
}

/**
 *  重写layout函数
 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat buttonW = self.frame.size.width / self.subviews.count;
    CGFloat buttonH = self.frame.size.height;
    CGFloat buttonY = 0;
    for (int i = 0; i < self.subviews.count; i++) {
        //获取按钮
        ZWTTabbarButton *button = self.subviews[i];
        
        //设置按钮的frame
        CGFloat buttonX = i * buttonW;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        //绑定tag
        button.tag = i;
    }
}
@end
