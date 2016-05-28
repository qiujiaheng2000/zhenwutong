//
//  NSMutableDictionary+Safe.h
//  Trader
//
//  Created by LiMing on 1/16/15.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Safe)

/// If 'anObject' or 'aKey' is nil or NSNull, then ignore this operation
- (void)setSafeObject:(id)anObject forKey:(id<NSCopying>)aKey;

/// If integer == defaultValue, then ignore this operation
/// dict[aKey] = string(integer)
- (void)setSafeInteger:(NSInteger)integer forKey:(id<NSCopying>)aKey defaultValue:(NSInteger)defaultValue;

@end
