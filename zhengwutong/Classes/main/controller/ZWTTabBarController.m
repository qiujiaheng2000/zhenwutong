//
//  TXTabBarController.m
//  taoXiu
//
//  Created by jhqiu on 15/9/10.
//  Copyright (c) 2015年 jhqiu. All rights reserved.
//

#import "ZWTTabBarController.h"
#import "ZWTNotificationTableViewController.h"
#import "ZWTCurriculumTableViewController.h"
#import "ZWTInteractionTableViewController.h" 
#import "ZWTSearchTableViewController.h"
#import "ZWTTabBar.h"


@interface ZWTTabBarController () <ZWTTabBarDelegate>

@property(nonatomic,weak)ZWTTabBar *customTabbar;
@property(nonatomic,strong)NSMutableArray *tabControllers;
@end

@implementation ZWTTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置tabbar
    [self setupTabbar];
    
    //初始化所有的子控制器
    [self setupAllChildViewControllers];


   }

-(NSMutableArray*)tabControllers{
    if(!_tabControllers){
        return [NSMutableArray array];
    }
    return _tabControllers;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    // 删除系统自动生成的UITabBarButton
    for (UIView *child in self.tabBar.subviews) {
        if ([child isKindOfClass:[UIControl class]]) {
            [child removeFromSuperview];
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setupTabbar
{
    ZWTTabBar *customTabBar = [[ZWTTabBar alloc] init];
    customTabBar.frame = self.tabBar.bounds;
    customTabBar.delegate = self;
    [self.tabBar addSubview:customTabBar];
    self.customTabbar = customTabBar;
}

-(void)setupAllChildViewControllers
{
    //通知
    ZWTNotificationTableViewController *notificationController = [[ZWTNotificationTableViewController alloc]init];
    [self setupChildViewController:notificationController title:@"通知" imageName:@"tabbar_message_center" selectedImageName:@"tabbar_message_center_selected"];
    notificationController.tabBarItem.badgeValue = @"11111";
    
    //课程表
    ZWTCurriculumTableViewController *curriculumController = [[ZWTCurriculumTableViewController alloc]init];
    [self setupChildViewController:curriculumController title:@"课程表" imageName:@"tabbar_home" selectedImageName:@"tabbar_home_selected"];

    //互动
    ZWTInteractionTableViewController *interactionController = [[ZWTInteractionTableViewController alloc]init];
    [self setupChildViewController:interactionController title:@"互动" imageName:@"tabbar_profile" selectedImageName:@"tabbar_profile_selected"];
    
    //搜索
    ZWTSearchTableViewController *searchController = [[ZWTSearchTableViewController alloc]init];
    [self setupChildViewController:searchController title:@"搜索" imageName:@"tabbar_discover" selectedImageName:@"tabbar_discover_selected"];

}

-(void)setupChildViewController:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName
{
    //设置控制器属性
    childVc.title = title;
    //设置图标
    childVc.tabBarItem.image = [UIImage imageWithName:imageName];
    
    //设置选中图标
    UIImage *selectedImage =[UIImage imageWithName:selectedImageName];
    
    childVc.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    

    //包装一个导航控制器
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:childVc];
    [self addChildViewController:nav];

    //添加tabbar内部的按钮
    [self.customTabbar addTabbarButtonWithItem:childVc.tabBarItem];
    
    //添加底部控制器到集合中
    [self.tabControllers addObject:childVc];
    
}


-(void)tabbar:(ZWTTabBar *)tabbar didSelectedButtonFrom:(int)from to:(int)to
{
    self.selectedIndex = to;
}

-(void)setTabbarBadge:(NSUInteger)index badgeValue:(NSString*)badgeValue{
    UIViewController *vc = [self.tabControllers objectAtIndex:index];
    vc.tabBarItem.badgeValue = @"11111";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
