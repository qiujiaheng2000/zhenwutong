//
//  NSDate+conversion.h
//  Trader
//
//  Created by Wenquan Xu on 12-11-9.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (conversion)

+(NSDate*) dateFromString:(NSString*)string;

+ (NSDate *)dateFromRFC1123String:(NSString *)string;

- (NSDictionary * )dateDictionary;

+(NSArray*) daysOfMonth:(NSInteger)month Year:(NSInteger)year;


@end
