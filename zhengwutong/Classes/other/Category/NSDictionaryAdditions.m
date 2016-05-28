//
//  NSDictionaryAdditions.m
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "NSDictionaryAdditions.h"
#import "NSDate+conversion.h"

@implementation NSDictionary (Additions)

- (BOOL)getBoolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    return [self objectForKey:key] == [NSNull null] ? defaultValue 
						: [[self objectForKey:key] boolValue];
}

- (id)getObjForKey:(NSString *)key defaultValue:(id)defaultValue {
	return [self objectForKey:key] == [NSNull null]
    ? defaultValue : [self objectForKey:key];
}


- (int)getIntValueForKey:(NSString *)key defaultValue:(int)defaultValue {
	return [self objectForKey:key] == [NSNull null] 
				? defaultValue : [[self objectForKey:key] intValue];
}

-(NSDate*) getDateForKey:(NSString*) key
{
    NSString *stringTime   = [self objectForKey:key];
    if ((id)stringTime == [NSNull null]) {
        stringTime = @"";
    }
    return [NSDate dateFromString:stringTime];
}

- (time_t)getTimeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue {
    
    return [[self getDateForKey:key] timeIntervalSince1970];
    
    NSString *stringTime   = [self objectForKey:key];
    if ((id)stringTime == [NSNull null]) {
        stringTime = @"";
    }
	struct tm created;
    time_t now;
    time(&now);
    
	if (stringTime) {
        strptime([stringTime UTF8String], "%Y-%m-%d %H:%M:%S", &created);
		return mktime(&created);
	}
	return defaultValue;
}

- (long long)getLongLongValueValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
	return [self objectForKey:key] == [NSNull null] 
		? defaultValue : [[self objectForKey:key] longLongValue];
}

- (NSString *)getStringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    if ([self objectForKey:key] == nil || [self objectForKey:key] == [NSNull null]) {
        return defaultValue;
    }
    else{
        id obj= [self objectForKey:key];
        if ([obj isKindOfClass:[NSString class]]) {
            return obj;
        }
        else
            return [NSString stringWithFormat:@"%@",obj];
    }
}

-(id)objectForKey:(id)aKey ofType:(Class)a
{
    id o=[self objectForKey:aKey];
    if ([o isKindOfClass:a]) {
        return o;
    }
    else{
        return nil;
    }
}

+(NSDictionary*) dictionaryWithArray:(NSArray*)arrayList
{
    NSMutableDictionary* dict=[NSMutableDictionary dictionary];
    for (id i in arrayList) {
        [dict setObject:@"1" forKey:i];
    }
    return dict;
}


@end
