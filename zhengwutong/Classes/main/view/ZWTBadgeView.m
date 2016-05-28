//
//  TXBadgeView.m
//  taoXiu
//
//  Created by jhqiu on 15/9/11.
//  Copyright (c) 2015年 jhqiu. All rights reserved.
//

#import "ZWTBadgeView.h"

@implementation ZWTBadgeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        [self setBackgroundImage:[UIImage resizedImageWithName:@"main_badge" ] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
    }
    return self;
}

-(void)setBadgeValue:(NSString *)badgeValue
{
#warning copy
    _badgeValue = [badgeValue copy];
    
    if (badgeValue) {
        self.hidden = NO;
        
        int intvalue = [badgeValue intValue];
        if(intvalue>999){
            _badgeValue = badgeValue = @"999+";
        }
        
        //设置文字
        [self setTitle:badgeValue forState:UIControlStateNormal];
        //设置frame
        CGRect frame = self.frame;
        CGFloat badgeH = self.currentBackgroundImage.size.height;
        CGFloat badgeW = self.currentBackgroundImage.size.width;
        if (badgeValue.length > 1) {
            //文字的尺寸
            CGSize badgeSize = [badgeValue sizeWithFont:self.titleLabel.font];
            badgeW = badgeSize.width + 10;
        }
        frame.size.width = badgeW;
        frame.size.height = badgeH;
        self.frame = frame;
    }else{
        self.hidden = YES;
    }
    
}

@end
