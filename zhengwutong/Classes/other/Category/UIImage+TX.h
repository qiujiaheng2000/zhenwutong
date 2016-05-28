//
//  UIImage+TX.h
//  taoXiu
//
//  Created by jhqiu on 15/9/10.
//  Copyright (c) 2015年 jhqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TX)

/**
 *  加载图片
 *
 *  @param name 图片名
 */
+(UIImage *)imageWithName:(NSString *)imageName;
/**
 *  返回一张自由拉伸的图片，不使边缘变形
 *
 *  @param name
 *
 *  @return 
 */
+(UIImage *)resizedImageWithName:(NSString *)name;
@end
