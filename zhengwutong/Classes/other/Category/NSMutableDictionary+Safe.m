//
//  NSMutableDictionary+Safe.m
//  Trader
//
//  Created by LiMing on 1/16/15.
//
//

#import "NSMutableDictionary+Safe.h"

@implementation NSMutableDictionary (Safe)

- (void)setSafeObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (!anObject || !aKey || (anObject == [NSNull null])
        || (aKey == [NSNull null])) {
        return;
    }
    [self setObject:anObject forKey:aKey];
}

- (void)setSafeInteger:(NSInteger)integer forKey:(id<NSCopying>)aKey defaultValue:(NSInteger)defaultValue {
    if (integer == defaultValue) { return; }
    
    [self setObject:@(integer).stringValue forKey:aKey];
}

@end
