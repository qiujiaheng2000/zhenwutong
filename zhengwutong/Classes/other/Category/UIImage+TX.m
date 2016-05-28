//
//  UIImage+TX.m
//  taoXiu
//
//  Created by jhqiu on 15/9/10.
//  Copyright (c) 2015年 jhqiu. All rights reserved.
//

#import "UIImage+TX.h"

@implementation UIImage (TX)
+(UIImage *)imageWithName:(NSString *)imageName
{
    
    NSString *newName = [imageName stringByAppendingString:@"_os7"];
    UIImage *image = [UIImage imageNamed:newName];
    if(image == nil){
        image = [UIImage imageNamed:imageName];
    }
    return image;
}

+ (UIImage *)resizedImageWithName:(NSString *)name
{
    UIImage *image = [self imageWithName:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
@end
