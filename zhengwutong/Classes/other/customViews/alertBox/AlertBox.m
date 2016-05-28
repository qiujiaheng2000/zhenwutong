//
//  AlertBox.m
//  Meilishuo
//
//  Created by yu yang on 11-6-3.
//  Copyright 2011 Meilishuo, Inc. All rights reserved.
//

#import "AlertBox.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"


@interface AlertBox()
@property (nonatomic, retain) UIView *mask;
@end

@implementation AlertBox

@synthesize textView=_textView;
@synthesize button=_button;
@synthesize background=_background;
@synthesize iconView=_iconView;

#define ICON_IMAGE_VIEW_SIZE 50

+ (AlertBox *) showMessage:(NSString *)text hideAfter:(NSTimeInterval)seconds {
    return [AlertBox showMessage:text withTitle:nil hideAfter:seconds];
}

+ (AlertBox *)showMessage: (NSString *)text withTitle:(NSString *)title hideAfter: (NSTimeInterval)seconds
{
    return [AlertBox showMessage:text withTitle:title Icon:nil hideAfter:seconds];
};

+ (AlertBox *)showMessage: (NSString *)text withTitle:(NSString *)title Icon:(UIImage *)icon hideAfter: (NSTimeInterval)seconds
{
    AlertBox *box = [[AlertBox alloc] initWithTitle:title WithText:text fontSize:16 icon:icon];
    box.button.hidden = YES;
    [box layout];
    // hide first
    box.alpha = 0;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    // remove other boxes
    [AlertBox removeBoxes];
    
    [window addSubview:box];
    [window bringSubviewToFront:box];

    // fade in
    NSTimeInterval durian = 0.3;
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:durian];
    box.alpha = 1;
    [UIView commitAnimations];
    
    if (seconds > 0) {
        [box performSelector:@selector(hide) withObject:nil afterDelay:seconds];
    }
    
    return box;
}

+ (AlertBox *)showMessage: (NSString *)text withIcon:(UIImage *)image hideAfter: (NSTimeInterval)seconds
{
    return [AlertBox showMessage:text withTitle:nil Icon:image hideAfter:seconds];
}

+ (void)removeBoxes {
    UIWindow *window = [AppDelegate currentAppDelegate].window;
    
    // remove other boxes
    for (UIView *view in [window subviews]) {
        if ([view isKindOfClass:[AlertBox class]]) {
            [view removeFromSuperview];
        }
    }
    
}

- (id)initWithText: (NSString *)text fontSize:(int)fontSize {
    
    return [self initWithTitle:nil WithText:text fontSize:fontSize icon:nil];
}

- (id)initWithTitle: (NSString *)title WithText: (NSString *)text fontSize:(int)fontSize icon:(UIImage *)icon {
    
    self = [super init];
    if (self) {
        // Initialization code.
        
        _background = [[UIView alloc] init];
        _background.backgroundColor = [UIColor blackColor];
        _background.alpha = .65;
        _background.layer.cornerRadius = 10;
        _background.layer.masksToBounds = YES;
        [self addSubview:_background];
        
        if (title != nil) {
            _title = [[UILabel alloc] init];
            self.title.font = [UIFont systemFontOfSize:fontSize+2];
            self.title.numberOfLines = 0;
            self.title.textColor = [UIColor whiteColor];
            self.title.backgroundColor = [UIColor clearColor];
            self.title.text = title;
            self.title.textAlignment = NSTextAlignmentCenter;
            [self addSubview:self.title];
        }
        
        if (icon != nil) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ICON_IMAGE_VIEW_SIZE, ICON_IMAGE_VIEW_SIZE)];
            _iconView.image = icon;
            _iconView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:_iconView];
        }
        
        _textView = [[UILabel alloc] init];
        self.textView.font = [UIFont systemFontOfSize:fontSize];
        self.textView.numberOfLines = 0;
        self.textView.textColor = [UIColor whiteColor];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.text = text;
        self.textView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textView];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        [_button setTitle:@"知道了" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(removeFromSuperview) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_button];
        
        _mask = [[UIView alloc] initWithFrame:[AppDelegate currentAppDelegate].window.bounds];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = .3f;
        _mask.hidden = YES;
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        [_mask setGestureRecognizers:@[tapGesture]];
        [[AppDelegate currentAppDelegate].window addSubview:_mask];
        [self layout];
    }
    return self;
}

- (id)initWithText:(NSString *)text {
    return [self initWithText:text fontSize:16];
}

- (void)layout {
    [self.textView sizeToFit];
    
    float frameWidth = 0;
    float frameHeight = 15;
    const float MAX_FRAME_WIDTH = 225.0/375.0 * SCREEN_WIDTH;
    
    CGRect titleFrame = CGRectZero;
    if (self.title != nil) {
        CGSize titleSize = [self.title.text sizeWithFont:self.title.font
                           constrainedToSize:CGSizeMake(MAX_FRAME_WIDTH, 2000)
                               lineBreakMode:NSLineBreakByWordWrapping];
        titleFrame = CGRectMake(15,
                                frameHeight,
                                MAX_FRAME_WIDTH,
                                titleSize.height);
        self.title.frame = titleFrame;
        
        frameWidth = MAX(frameWidth, self.title.frame.size.width);
        frameHeight = CGRectGetMaxY(self.title.frame) + 15;
    }

    CGRect iconViewFrame;
    
    if (self.iconView != nil) {
        iconViewFrame = self.iconView.frame;
        iconViewFrame.origin.y = frameHeight;
        frameWidth = MAX(frameWidth, iconViewFrame.size.width);
        frameHeight = CGRectGetMaxY(iconViewFrame) + 12;
    } else {
        iconViewFrame = CGRectZero;
    }
    
    NSString *text = self.textView.text;
    CGSize textSize = [text sizeWithFont:self.textView.font
                       constrainedToSize:CGSizeMake(MAX_FRAME_WIDTH, 2000)
                       lineBreakMode:NSLineBreakByWordWrapping];
    
    if (textSize.width < iconViewFrame.size.width) {
        textSize.width = iconViewFrame.size.width;
    }
    
    self.textView.frame = CGRectMake(15,
                                     frameHeight,
                                     textSize.width,
                                     textSize.height);
    
    frameWidth = MAX(frameWidth, self.textView.frame.size.width) + 30;
    frameHeight = CGRectGetMaxY(self.textView.frame) + 15;
    
    if (self.iconView) {
        iconViewFrame.origin.x = (frameWidth - iconViewFrame.size.width)/2;
        self.iconView.frame = iconViewFrame;
    }

    if (self.button.hidden == NO) {
        self.button.frame = CGRectMake((frameWidth - self.button.frame.size.width)/2,
                                       frameHeight,
                                       self.button.frame.size.width,
                                       self.button.frame.size.height);
        frameHeight += self.button.frame.size.height + 15;
    }

    self.background.frame = CGRectMake(self.background.frame.origin.x, 
                                       self.background.frame.origin.y, 
                                       frameWidth,
                                       frameHeight);
    
    if (GetIosVersion() < 5.0) {
        self.frame = CGRectMake((SCREEN_WIDTH - frameWidth)/2,
                               (SCREEN_HEIGHT - 20 - frameHeight)/2,
                               frameWidth,
                               frameHeight);   
    } else if(GetIosVersion() < 6.0){
        self.frame = CGRectMake((SCREEN_WIDTH- frameWidth)/2,
                               (SCREEN_HEIGHT - frameHeight)/2,
                               frameWidth,
                               frameHeight);
    }
    else{
        self.frame = CGRectMake((SCREEN_WIDTH - frameWidth)/2,
                                (SCREEN_HEIGHT - frameHeight)/2-44,
                                frameWidth,
                                frameHeight);
        
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad) {
        self.transform = CGAffineTransformMakeRotation(M_PI/2);;
    }
}

- (void)show {
    [self layout];    

    [[AppDelegate currentAppDelegate].window addSubview:self];
}

- (void)hide {
    [self hideAfterTimeInterval:0.3];
}

- (void)hideAfterTimeInterval:(NSTimeInterval)interval {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:interval];
    self.alpha = 0;
    _mask.alpha = 0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(removeFromSuperview)
               withObject:nil
               afterDelay:interval];
    [_mask performSelector:@selector(removeFromSuperview)
               withObject:nil
               afterDelay:interval];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.button.hidden == YES) {
        [self hide];
    }
    else {
        [super touchesBegan:touches withEvent:event];
    }

}

-(void) setText:(NSString *)text{
    self.textView.text = text;
    [self show];
}

-(void)setHasMask:(BOOL)hasMask
{
    _mask.hidden = !hasMask;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [_mask removeFromSuperview];
}


@end
