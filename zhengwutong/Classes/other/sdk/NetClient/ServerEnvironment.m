//
//  ServerEnvironment.m
//  Trader
//
//  Created by LiMing on 16/1/28.
//
//

#import "ServerEnvironment.h"
#import "YXClient.h"
#import "GlobalFunc.h"

@implementation ServerEnvironment
-(id) init
{
    self = [super init];
    if (self)
    {
        [self reset];
    }
    return self;
}
-(void)reset
{
#ifdef dev
    NSString* a=[[NSUserDefaults standardUserDefaults] objectForKey:@"OA_ENV"];
    if (a==nil) {
        [self setEnviroment:OACom];
    }
    else{
        [self setEnviroment:a.intValue];
    }
#else
    [self setEnviroment:OACom];
#endif
}
+(ServerEnvironment*)instance
{
    static ServerEnvironment *inst = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{inst = [[self alloc] init];});
    return inst;
}
-(BOOL)initFromLoginSetting:(NSDictionary*)dic
{
    // FILE
//    self.FILE_BASE_URL = GetStringFromDictionary(dic, @"file/baseUri");
    
    self.QINIU_BASE_URL=GetStringFromDictionary(dic, @"file/qiniuUri");
    
    NSRange rang =[self.QINIU_BASE_URL rangeOfString:@"http://"];
    if (rang.length<=0) {
        self.QINIU_BASE_URL=    [NSString stringWithFormat:@"http://%@/",self.QINIU_BASE_URL];
    }
    else
    {
        self.QINIU_BASE_URL=  [NSString stringWithFormat:@"%@/",self.QINIU_BASE_URL];
    }
    
    NSString *newApiBaseUrl = GetStringFromDictionary(dic, @"api/baseUri");
    
    // API
    self.API_BASE_URL = newApiBaseUrl;
    
    //HOST
    self.API_BASE_HOST = GetStringFromDictionary(dic, @"api/host");
    
    // MQTT
    NSDictionary* mqtt = GetDictionaryFromDictionary(dic, @"mqtt");
    self.msgTopic = GetStringFromDictionary(mqtt, @"topic");
    self.MQTT_SERVER = GetStringFromDictionary(mqtt, @"host");
    self.MQTT_PORT = [GetStringFromDictionary(mqtt, @"port") intValue];
    
    self.MQTT_USERNAME=@"haizhi";
    self.MQTT_PASSWORD=@"MpK2dTV8P";
    
    if( [YXClient isValidString:self.QINIU_BASE_URL] &&
       [YXClient isValidString:self.API_BASE_URL]&&
       [YXClient isValidString:self.MQTT_SERVER])
    {
        return YES;
    } else {
        //服务端传回的setting无效，清空
        [[NSUserDefaults standardUserDefaults] setValue:@{} forKey:@"mySetting"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //重新设置服务器环境
        [self reset];
        return NO ;
    }
}

-(void)setEnviroment:(OAEnviroment)env
{
    _enviroment=env;
    
    // 默认使用各环境内置的设置初始化以下变量
    NSDictionary * dict =[ServerEnvironment envConfigForType:env];
    self.SERVER_ENV = GetStringFromDictionary(dict, SERVER_ENV_TITLE);
    self.API_BASE_URL = GetStringFromDictionary(dict, SERVER_ENV_API);
    self.QINIU_BASE_URL = GetStringFromDictionary(dict, SERVER_ENV_FILE);
    self.MQTT_SERVER = GetStringFromDictionary(dict, SERVER_ENV_MQTT);
    
    self.msgTopic = @"messages/add";
    self.MQTT_PORT=18830;
    self.MQTT_USERNAME=@"haizhi";
    self.MQTT_PASSWORD=@"MpK2dTV8P";
    
    //如果服务器传回了配置信息，则必须使用服务器的信息
    NSDictionary* setting = [[NSUserDefaults standardUserDefaults]valueForKey:@"mySetting"];
    
    if (setting.count>0)
    {
        [self initFromLoginSetting:setting];
    }
}

-(NSString*)urlForResourceId:(NSString*)resId
{
    if(![YXClient isValidString:resId])
        return @"";
    if ([resId rangeOfString:@"://"].length>0)
    {
        return resId;
    }
    NSString* url = [self.QINIU_BASE_URL stringByAppendingString:resId];
    return url;
}
@end
