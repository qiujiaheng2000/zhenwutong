//
//  NSObject+performBlockAfterDelay.m
//  cartaobao
//
//  Created by xu wenquan on 9/15/12.
//  Copyright (c) 2012 Meilishuo. All rights reserved.
//

#import "NSObject+performBlockAfterDelay.h"

@implementation NSObject (performBlockAfterDelay)

+ (void)performBlock:(void (^)(void))block
          afterDelay:(NSTimeInterval)delay
{
    block = [block copy] ;
    [self performSelector:@selector(fireBlock:)
               withObject:block
               afterDelay:delay];
}

+ (void)performBlockOnBackground:(void (^)(void))block
{
    block = [block copy] ;
    [self performSelectorInBackground:@selector(fireBlock:) withObject:block];
}


+(void) performBlockOnMainThread:(void(^)(void))block waitUntilDone:(BOOL)wait
{
    block = [block copy] ;
    [self performSelectorOnMainThread:@selector(fireBlock:) withObject:block waitUntilDone:wait];
}

+(void) performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval) interval{
    block = [block copy];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        block();
    });
}

+ (void)cancelPreviousPerformRequestsWithBlock:(void (^)(void))block {
    block = [block copy];
    [self cancelPreviousPerformRequestsWithTarget:self selector:@selector(fireBlock:) object:block];
}

- (void)fireBlock:(void (^)(void))block {
    block();
}


@end
