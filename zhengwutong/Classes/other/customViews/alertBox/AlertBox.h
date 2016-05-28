//
//  AlertBox.h
//  Meilishuo
//
//  Created by yu yang on 11-6-3.
//  Copyright 2011 Meilishuo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AlertBox : UIView {

}

+ (AlertBox *)showMessage: (NSString *)text hideAfter: (NSTimeInterval)seconds;

+ (AlertBox *)showMessage: (NSString *)text withTitle:(NSString *)title hideAfter: (NSTimeInterval)seconds;

+ (AlertBox *)showMessage: (NSString *)text withIcon:(UIImage *)image hideAfter: (NSTimeInterval)seconds;

+ (void)removeBoxes;

@property (nonatomic, strong) UILabel *textView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, assign) BOOL hasMask;

// Designated initializer
//- (id)initWithText: (NSString *)text fontSize:(int)fontSize;
//- (id)initWithTitle: (NSString *)title WithText: (NSString *)text fontSize:(int)fontSize;
//// Create an alert box with given text, using default font size.
//- (id)initWithText:(NSString *)text;

-(void) setText:(NSString *)text;

- (void)layout;

// Show this alert box
- (void)show;

- (void)hideAfterTimeInterval:(NSTimeInterval)interval;

- (void)hide;

@end
