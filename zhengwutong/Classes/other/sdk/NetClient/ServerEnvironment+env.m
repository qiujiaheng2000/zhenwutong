//
//  YXClient+env.m
//  Trader
//
//  Created by djy on 15/11/11.
//
//

#import "ServerEnvironment.h"

#define SERVER_FILE_EXTENSION @"files/"

@implementation ServerEnvironment (env)

#pragma mark - Private Class Instances -

+ (NSDictionary *)dictForOACustom
{
    NSString* customApi=[[NSUserDefaults standardUserDefaults] objectForKey:SERVER_ENV_API];
    NSString* customMqtt=[[NSUserDefaults standardUserDefaults] objectForKey:SERVER_ENV_MQTT];
    if (customApi.length == 0) {
        customApi=@"http://8012.weibangong.me/";
    }
    if (customMqtt.length == 0) {
        customMqtt=@"103.235.225.31";
    }
    
    NSString *qiniuUrl=@"";
    if ([customApi isEqualToString:@"http://api.weibangong.com/"]) {
        qiniuUrl=@"http://static.weibangong.com/";
    }
    else{
        qiniuUrl=@"http://static.test.weibangong.com/";
    }
    
    NSDictionary * dict = nil;
    dict = @{SERVER_ENV_TITLE : @"OA.Custom",
             SERVER_ENV_API    : customApi,
             SERVER_ENV_FILE   : [qiniuUrl stringByAppendingPathExtension:SERVER_FILE_EXTENSION],
             SERVER_ENV_MQTT   : customMqtt
             };
    
    return dict;
}
+ (NSDictionary *)dictForOAME
{
    NSDictionary * dict = nil;
    dict = @{SERVER_ENV_TITLE  : @"OA.Me",
             SERVER_ENV_API     : @"http://oa.haizhi.me/",
             SERVER_ENV_FILE    : @"http://static.test.weibangong.com/files/",
             SERVER_ENV_MQTT    : @"103.235.225.31"};
    return dict;
    
}
+ (NSDictionary *)dictForOACRM
{
    NSDictionary * dict = nil;
    dict = @{SERVER_ENV_TITLE  : @"OA.CRM",
             SERVER_ENV_API     : @"http://8001.weibangong.me/",
             SERVER_ENV_FILE    : @"http://static.test.weibangong.com/files/",
             SERVER_ENV_MQTT    : @"103.235.225.31"};
    return dict;
    
}
+ (NSDictionary *)dictForOADev
{
    NSDictionary * dict = nil;
    dict = @{SERVER_ENV_TITLE  : @"OA.Dev",
             SERVER_ENV_API     : @"http://8012.weibangong.me/",
             SERVER_ENV_FILE    : @"http://static.test.weibangong.com/files/",
             SERVER_ENV_MQTT    : @"103.235.225.31"};
    return dict;
    
}
+ (NSDictionary *)dictForOACOM
{
    NSDictionary *dict = nil;
    dict = @{SERVER_ENV_TITLE  : @"OA.COM",
             SERVER_ENV_API     : @"http://api.weibangong.com/",
             SERVER_ENV_FILE    : @"http://static.weibangong.com/files/",
             SERVER_ENV_MQTT    : @"api.weibangong.com"};
    return dict;
}


+ (NSDictionary *)dictForOATest
{
    NSDictionary *dict = nil;
    dict = @{SERVER_ENV_TITLE  : @"OA.Test",
             SERVER_ENV_API     : @"http://8012.weibangong.me/",
             SERVER_ENV_FILE    : @"http://static.test.weibangong.com/files/",
             SERVER_ENV_MQTT    : @"103.235.225.31"};
    return dict;
}

#pragma mark - Public Methods -

+ (NSArray *)allEnvironments
{
    NSArray * dataSource = nil;
    dataSource = @[
                   [[ServerEnvironment envConfigForType:OACom] mutableCopy],
                   [[ServerEnvironment envConfigForType:OACustom] mutableCopy],
                   [[ServerEnvironment envConfigForType:OADev] mutableCopy],
                   [[ServerEnvironment envConfigForType:OAMe] mutableCopy],
                   [[ServerEnvironment envConfigForType:OATest] mutableCopy]
                ];
    
    for (NSMutableDictionary * dict in dataSource) {
        [dict setValue:@"NO" forKey:SERVER_ENV_ISSELECT];
    }
    
    OAEnviroment env = [ServerEnvironment instance].enviroment;
    NSString * title = [ServerEnvironment envTitleWithType:env];
    
    for (NSMutableDictionary *dict in dataSource) {
        if([dict[SERVER_ENV_TITLE] isEqualToString:title]){
            [dict setValue:@"YES" forKey:SERVER_ENV_ISSELECT];
            break;
        }
    }
    
    return dataSource;
}

+ (NSString *)envTitleWithType:(OAEnviroment)env
{
    switch (env) {
        case OATest:
            return [ServerEnvironment dictForOATest][SERVER_ENV_TITLE];
        case OADev:
            return [ServerEnvironment dictForOADev][SERVER_ENV_TITLE];
        case OAMe:
            return [ServerEnvironment dictForOAME][SERVER_ENV_TITLE];
        case OACustom:
            return [ServerEnvironment dictForOACustom][SERVER_ENV_TITLE];
        case OACRM:
            return [ServerEnvironment dictForOACRM][SERVER_ENV_TITLE];
        default:
            return [ServerEnvironment dictForOACOM][SERVER_ENV_TITLE];
    }
}

+ (NSDictionary *)envConfigForType:(OAEnviroment)type
{
    NSDictionary * dict = nil;
    switch (type) {
        case OADev:
            dict = [ServerEnvironment dictForOADev];
            break;
        case OAMe:
            dict = [ServerEnvironment dictForOAME];
            break;
        case OACustom:
            dict = [ServerEnvironment dictForOACustom];
            break;
        case OACRM:
            dict = [ServerEnvironment dictForOACRM];
            break;
        case OATest:
            dict = [ServerEnvironment dictForOATest];
            break;
        case OACom: default:
            // 默认为线上环境
            dict = [ServerEnvironment dictForOACOM];
            break;
    }
    return dict;
}

@end
