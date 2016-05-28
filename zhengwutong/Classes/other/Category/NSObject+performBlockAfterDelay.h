//
//  NSObject+performBlockAfterDelay.h
//  cartaobao
//
//  Created by xu wenquan on 9/15/12.
//  Copyright (c) 2012 Meilishuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (performBlockAfterDelay)

+ (void)performBlock:(void (^)(void))block 
          afterDelay:(NSTimeInterval)delay;
+(void)performBlockOnBackground:(void (^)(void))block;
+(void) performBlockOnMainThread:(void(^)(void))block waitUntilDone:(BOOL)wait;
+(void) performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval) interval;
+ (void)cancelPreviousPerformRequestsWithBlock:(void (^)(void))block;
@end
