//
//  NSDate+conversion.m
//  Trader
//
//  Created by Wenquan Xu on 12-11-9.
//
//

#import "NSDate+conversion.h"

@implementation NSDate (conversion)


+(NSDate*) dateFromString:(NSString *)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
	NSDate* date= [formatter dateFromString:string];
    return date;
    
}

+ (NSDate *)dateFromRFC1123String:(NSString *)string
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	// Does the string include a week day?
	NSString *day = @"";
	if ([string rangeOfString:@","].location != NSNotFound) {
		day = @"EEE, ";
	}
	// Does the string include seconds?
	NSString *seconds = @"";
	if ([[string componentsSeparatedByString:@":"] count] == 3) {
		seconds = @":ss";
	}
	[formatter setDateFormat:[NSString stringWithFormat:@"%@dd MMM yyyy HH:mm%@ z",day,seconds]];
	return [formatter dateFromString:string];
}

- (NSDictionary * )dateDictionary
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString * year = [dateFormatter stringFromDate:self];
    [dateFormatter setDateFormat:@"M"];
    NSString * month = [dateFormatter stringFromDate:self];
    [dateFormatter setDateFormat:@"d"];
    NSString * day = [dateFormatter stringFromDate:self];
    [dateFormatter setDateFormat:@"H"];
    NSString * hour = [dateFormatter stringFromDate:self];
    [dateFormatter setDateFormat:@"m"];
    NSString * minute = [dateFormatter stringFromDate:self];
    
    [dict setObject:year forKey:@"year"];
    [dict setObject:month forKey:@"month"];
    [dict setObject:day forKey:@"day"];
    [dict setObject:hour forKey:@"hour"];
    [dict setObject:minute forKey:@"minute"];
    
    
    //设置日历和格式
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//设置成中国阳历
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    //获取时间组件
    NSDateComponents *compsDate = [calendar components:unitFlags fromDate:self];
    NSInteger nWeekDay =[compsDate weekday]-1;
    
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)nWeekDay] forKey:@"dayOfWeek"];
    
    return dict;
}

+(NSArray*) daysOfMonth:(NSInteger)month Year:(NSInteger)year
{
    NSDateComponents *dc = [[NSDateComponents alloc] init];
    [dc setYear:year];
    [dc setMonth:month];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSMutableArray* dayList=[NSMutableArray array];
    for (int i=1; i<=31;i++) {
        [dc setDay:i];
        NSDate* date=[gregorian dateFromComponents:dc];
        if (date) {
            NSDateComponents* dd2=[gregorian components:NSCalendarUnitDay fromDate:date];
            if (dc.day==dd2.day) {
                [dayList addObject:[NSString stringWithFormat:@"%d",i]];
            }
        }
    }
    return dayList;
}


@end
