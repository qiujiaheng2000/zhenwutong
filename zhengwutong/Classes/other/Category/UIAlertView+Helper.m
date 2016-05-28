//
//  UIAlertView+Helper.m
//  HaipuUI
//
//  Created by Frank on 12-1-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+Helper.h"

@implementation UIAlertView (Helper)

+ (void)showAlertWithTitle:(NSString*)title message:(NSString*)message button:(NSString*)button
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:button otherButtonTitles:nil];
    [alertView show];
}

@end
