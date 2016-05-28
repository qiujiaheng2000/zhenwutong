//
//  YXClient+util.m
//  Trader
//
//  Created by LiMing on 16/1/28.
//
//

#import "YXClient.h"

@implementation YXClient (util)

//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

+(NSString *)getFileNameFromPath:(NSString *)path {
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    if(range.length==0)
        return path ;
    NSString* filename = [path substringFromIndex:(range.location+1)] ;
    if (![self isValidString:filename])
    {
        return [self getFileNameFromPath:[path substringToIndex:range.location]];
    }
    return filename;
}

/**
 *  长度为非0字符串为yes，否则no
 *
 *  @param obj
 *
 *  @return
 */
+ (BOOL)isValidString:(id)obj
{
    if (obj != nil && [obj isKindOfClass:[NSString class]]) {
        NSString *s = (NSString*)obj;
        return s.length != 0;
    }
    return NO;
}
+ (BOOL)isValidDictionary:(id) obj {
    return obj!=nil &&[obj isKindOfClass:[NSDictionary class]];
}

+ (BOOL)isValidArray:(id) obj {
    return obj != nil && [obj isKindOfClass:[NSArray class]];
}

@end
