//
//  ServerEnvironment.h
//  Trader
//
//  Created by LiMing on 16/1/28.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    OACom,
    OATest,
    OADev,
    OAMe,
    OACustom,
    OACRM
} OAEnviroment;

@interface ServerEnvironment : NSObject

@property (nonatomic,assign) OAEnviroment enviroment;
@property (nonatomic,strong) NSString* SERVER_ENV;

//mqtt信息
@property (nonatomic,strong) NSString* MQTT_SERVER;
@property (nonatomic,assign) int MQTT_PORT;
@property (nonatomic,strong) NSString* MQTT_USERNAME;
@property (nonatomic,strong) NSString* MQTT_PASSWORD;;;
@property (nonatomic,strong) NSString* msgTopic;

//不同的server地址
@property (nonatomic,strong) NSString* API_BASE_URL;    //
//@property (nonatomic,strong) NSString* FILE_BASE_URL;   //如 http://oa.haizhi.com/
@property (nonatomic,strong) NSString* QINIU_BASE_URL;

//获取投票使用的host
@property (nonatomic,strong) NSString* API_BASE_HOST;    //

+(ServerEnvironment*)instance;

-(void)reset;
-(void)setEnviroment:(OAEnviroment)env;
-(BOOL)initFromLoginSetting:(NSDictionary*)dic;
-(NSString*)urlForResourceId:(NSString*)resId;

@end

#define SERVER_ENV_TITLE @"Title"
#define SERVER_ENV_FILE @"File"
#define SERVER_ENV_API @"setting_custom_api"
#define SERVER_ENV_MQTT @"setting_custom_mqtt"
#define SERVER_ENV_ISSELECT @"isSelect"

@interface ServerEnvironment (env)

// 返回所有可用的环境配置
+ (NSArray *)allEnvironments;
// 返回当前type所对应的所有配置信息，如：API_BASE_URL
+ (NSDictionary *)envConfigForType:(OAEnviroment)type;
// 返回诸如OA.COM OA.CUSTOM之类的文本
+ (NSString *)envTitleWithType:(OAEnviroment)type;

@end
