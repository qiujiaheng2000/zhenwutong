
//
//  YXClient.m
//  网络请求类
//  Created by jhqiu on 16/1/4.
//  Copyright © 2016年 jhqiu. All rights reserved.
//
#import "YXClient.h"
#import "NSData+CommonCrypto.h"
#import "AFNetworking.h"
#import "AlertBox.h"
#import "AppDelegate.h"
#import "NSMutableDictionary+Safe.h"
#import "NSObject+performBlockAfterDelay.h"

#import "YXUser.h"


@interface YXClient ()

@property (nonatomic, readonly) NSString *authString;

@end

#ifdef dev
static NSString * const FormalLocalErrorMsg = @"参数错误";
static NSString * const UserChangedErrorMsg = @"DEBUG ERROR:用户状态发生改变，不应该继续处理上一用户状态的数据";
#else
static NSString * const FormalLocalErrorMsg = networkErrorMesage;
static NSString * const UserChangedErrorMsg = @"";
#endif

@implementation YXClient

+(YXClient *)instance {
    static YXClient *inst = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^(){
        inst = [[YXClient alloc]init];
    });
    return inst;
}

// overide this to use different server url
-(NSString*)getServerUrl
{
    return [ServerEnvironment instance].API_BASE_URL;
    //要连服务端同学的机器 返回下面这行就OK了
//        return @"http://8009.weibangong.me/";
//    return @"http://8006.weibangong.me/";

}

-(NSString *)authString
{
    if (self.accessToken.length > 0) {
        return [@"Bearer " stringByAppendingString:self.accessToken];
    }
    
    return nil;
}

-(NSString *)requestCompleteURLWithAPI:(NSString *)api {
    NSString* completeUrl =nil;
    if ([[NSURL alloc] initWithString:api].scheme) {
        completeUrl = api;
    }
    else if ([api rangeOfString:@"?"].location!=NSNotFound) {
        completeUrl = [NSString stringWithFormat:@"%@%@&lang=utf8",[self getServerUrl],api];
    }
    else{
        completeUrl = [NSString stringWithFormat:@"%@%@?lang=utf8",[self getServerUrl],api];
    }
    return completeUrl;
}

# pragma mark - API Calls


-(AFHTTPRequestOperation *)requestWithAPI:(NSString *)api
                              requestType:(EMHttpRequestType)requestType
                               withParams:(NSDictionary *)aDict
                             successBlock:(void (^)(NSDictionary *, NSString *, NSString *))block {
    return [self __httpRequestWithAPI:api
                          requestType:requestType
                           withParams:aDict
                         successBlock:^(NSDictionary *dic, NSString *errorMsg, NSString *sStatus) {
                             !block ?: block(dic[@"data"], errorMsg, sStatus);
                         }];
}

-(AFHTTPRequestOperation *)__httpRequestWithAPI:(NSString *)api
                                    requestType:(EMHttpRequestType) requestType
                                     withParams:(NSDictionary *)aDict
                                   successBlock:(void(^)(NSDictionary* dic,NSString* errorMsg,NSString* sStatus))block
{
    // 黎明：AFNetworking的建议
    // Do not use Reachability to determine if the original request should be sent.
    // You should try to send it.
    //    if (!self.isNetworkEnabled) {
    //        block(nil,@"无法连接到网络",nil);
    //        return;
    //    }
    
    NSString *url = [self requestCompleteURLWithAPI:api];
    
    if (url.length == 0) {
        if (block) {
            block(nil, FormalLocalErrorMsg, @"403.10");
        }
        return nil;
    }
    
    __weak YXClient *this = self;
    NSString *accessToken = [self.accessToken copy];
    
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [this parseProcessHttpResult:responseObject
                                 url:url
                           userToken:accessToken
                            response:operation.response
                               error:nil
              yesIfYouWantToBeFucked:YES
                        successBlock:block];
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSDictionary *resultJsonDic = nil;
        @try {
            if (operation.responseData) {
                resultJsonDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception = %@",exception.description);
        }
        @finally {
            [this parseProcessHttpResult:resultJsonDic
                                     url:url
                               userToken:accessToken
                                response:operation.response
                                   error:error
                  yesIfYouWantToBeFucked:YES
                            successBlock:block];
        }
    };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [self addDefaultHeaderField:manager];
    
    AFHTTPRequestOperation *operation = nil;
    
    switch (requestType) {
        case httpGet:
            aDict = [self addEssentialParameters:aDict];
            operation = [manager GET:url parameters:aDict success:successBlock failure:failureBlock];
            break;
            
        case httpPost:
            operation = [manager POST:url parameters:aDict success:successBlock failure:failureBlock];
            break;
            
        case httpPut:
            operation = [manager PUT:url parameters:aDict success:successBlock failure:failureBlock];
            break;
            
        case httpDelete:
            manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET",@"HEAD", nil];
            operation = [manager DELETE:url parameters:aDict success:successBlock failure:failureBlock];
            break;
            
        case httpMax:
        default:
            if (block) {
                NSString *errorMsg = FormalLocalErrorMsg;
#ifdef DEBUG
                errorMsg = @"http method 不正确";
#endif
                block(nil, errorMsg, @"403.10");
            }
            return nil;
    }
    
    return operation;
}

# pragma mark - Private

-(void)addDefaultHeaderField:(AFHTTPRequestOperationManager *)manager {
    if (self.agentString.length > 0) {
        [[manager requestSerializer]setValue:self.agentString
                          forHTTPHeaderField:@"User-Agent"];
    }
    if (self.authString.length > 0) {
        [[manager requestSerializer]setValue:self.authString
                          forHTTPHeaderField:@"Authorization"];
    }
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
}

-(void)addDefaultHttpHeaderField:(NSMutableURLRequest *)request {
    if (self.agentString.length > 0) {
        [request setValue:self.agentString forHTTPHeaderField:@"User-Agent"];
    }
    if (self.authString.length > 0) {
        [request setValue:self.authString forHTTPHeaderField:@"Authorization"];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
}

-(NSMutableDictionary*) addEssentialParameters:(NSDictionary*)aDict{
    NSMutableDictionary* dict=[NSMutableDictionary dictionaryWithDictionary:aDict];
    
    NSString* devid=[[NSUserDefaults standardUserDefaults] objectForKey:DEV_UUID];
    if (devid && devid.length>0) {
        [dict setObject:devid forKey:@"dev_uuid"];
    }
    return dict;
}

/**
 *  解析response结果
 *
 *  @param responseObject 结果里面的json字典
 *  @param task
 *  @param error
 *  @param fuckMe         你要是想被坑的话就传个yes进来 我会把服务端返回的所有的数据都传到block里返回给你
 *                        你要是想像正常人一样用这个东西 得到已经解析好的结果 就传no
 */
-(void)parseProcessHttpResult:(id) responseObject
                          url:(NSString *)url
                    userToken:(NSString *)accessToken
                     response:(NSURLResponse *)response
                        error:(NSError *) error
       yesIfYouWantToBeFucked:(BOOL)fuckMe
                 successBlock:(void (^)(NSDictionary* dic,NSString* errorMsg,NSString* sStatus))block
{
    void (^successBlock)(NSDictionary* ,NSString* ,NSString* ) = ^(NSDictionary* dic,NSString* errorMsg,NSString* sStatus)
    {
        if (block) {
            if ([[self class] isLoginRequest:url]) {
                block(dic, errorMsg, sStatus);
            }else{
                // 不是登录接口的话:
                // 1. 防止用户已经切换了账号或公司，但后台仍在请求前一个公司的数据
                // 2. 防止未登录状态与已登录状态间窜数据
                if ([accessToken isEqualToString:self.accessToken]) {
                    block(dic, errorMsg, sStatus);
                } else {
                    block(nil, UserChangedErrorMsg, @"403");    // 禁止访问
                }
            }
        }
    };
    
    // 检查登录状态
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        // 401 并且不是登录接口，则特殊处理
        if (resp.statusCode == 401) {
            if (![[self class] isLoginRequest:url]) {
                [[AppDelegate currentAppDelegate] logoutByServer];
                // TODO: 这里是否需要block返回数据？
                return;
            }
        } else if (resp.statusCode >= 200 && resp.statusCode < 300) {
            [AppDelegate onNetworkOK];
        }
    }
    
    if ([YXClient isValidDictionary:responseObject]) {
        
        NSDictionary *data = (fuckMe ?
                              responseObject:
                              GetDictionaryFromDictionary(responseObject, @"data"));
        NSString *errMsg   =  GetStringFromDictionary(responseObject, @"message");
        NSString *status   =  GetStringFromDictionary(responseObject, @"status");
        
        if ([status isEqualToString:@"0"]) {
            if (![YXClient isValidDictionary:data] && ![YXClient isValidArray:data]) {
                data = @{};
            }
            successBlock(data,nil,status);
        } else {
            if ([errMsg isKindOfClass:NSDictionary.class]
                || errMsg == nil
                || ([errMsg isKindOfClass:NSString.class] ? errMsg.length == 0 : NO)) {
                errMsg = @"未知错误";
            }
            successBlock(nil,errMsg,status);
        }
    } else {
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSString *errorMsg = nil;
            
#ifdef dev
            NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
            NSError *underlyingError = [error.userInfo objectForKey:NSUnderlyingErrorKey];

            if (underlyingError.code == 1|| underlyingError.code == 2) {
                errorMsg = @"您当前的网络状况不佳或者不可用";
            }else{
                errorMsg = [NSString stringWithFormat:@"错误码：%ld,api = %@,error = %@,code = %ld",(long)resp.statusCode,url,error.localizedDescription,(long)error.code];
            }
            NSLog(@" sError = %@",errorMsg);
            [AlertBox showMessage:errorMsg hideAfter:3.0f];
#else
            errorMsg = @"您当前的网络状况不佳或者不可用";
#endif
            successBlock(nil,errorMsg,@"1");
        }else{
            NSString *errorMsg = @"";
            
#ifdef dev
            if ([error.domain isEqualToString:NSURLErrorDomain]) {
                switch (error.code) {
                    case NSURLErrorTimedOut://请求网络超时
                        errorMsg  = @"网络服务忙，请稍后再试";
                        break;
                    case NSURLErrorCancelled://用户退出网络请求
                        errorMsg = @"用户退出网络请求";
                    default:
                        break;
                }
            }
#else
            errorMsg = @"您当前的网络状况不佳或者不可用";
#endif
            NSLog(@" sError = %@",errorMsg);
            successBlock(nil,errorMsg,@"1");
        }
    }
}

# pragma mark - [UIImage] -> url
/**
 *  批量上传图片
 *
 *  @param url          上传的API
 *  @param images       要上传的图片
 *  @param successBlock 上传图片的回调
 */
-(void)httpUploadImagesWithURL:(NSString *)url
                        images:(NSArray *)images
                       success:(void (^)(NSDictionary *dic ,NSString *errorMsg,NSString *status,NSArray *result,NSArray *unCompleteImages))successBlock
{
    [self httpUploadImagesWithURL:url
                           images:images
                           params:nil
                          success:successBlock];
}

# pragma mark - [UIImage]+[NSDictionary] -> url
/**
 *  批量上传一串图片 带一串参数
 *
 *  @param url          api
 *  @param images       图, 要是nil的话当做失败掉successBlock
 *  @param params       参数 - 每个参数和每个图片必须对应的 不对应就不干 直接当做失败掉successBlock. 要是nil或者空数组的话当做没有参数
 *  @param successBlock 回调
 */
-(void)httpUploadImagesWithURL:(NSString *)url
                        images:(NSArray<UIImage *> *)images
                        params:(NSArray<NSDictionary *> *)params
                       success:(void (^)(NSDictionary *dic,
                                         NSString *errorMsg,
                                         NSString *status,
                                         NSArray<NSDictionary *> *result,
                                         NSArray<UIImage *> *unCompleteImages))successBlock {
    if (!successBlock) {
        successBlock = ^(NSDictionary *dic ,NSString *errorMsg,NSString *status,NSArray *result,NSArray *unCompleteImages){};
    }
    
    // 没有传来图片
    // 或者同时传了图片和参数但是两个东西长度不一样
    if (images.count == 0)                                 { successBlock(nil, nil, @"0", @[], nil); return; }
    if (params.count != 0 && images.count != params.count) { successBlock(nil, FormalLocalErrorMsg, @"1", nil, nil); return; }
    
    [self httpUploadFileWithURL:url
                         images:images
                    contentType:@"image/jpeg"
                         params:params
                        success:successBlock
                         result:@[]];
}

/**
 *  递归回调上传文件
 *  非公开方法
 *  @param url          上传文件的url
 *  @param images       要上传的所有文件
 *  @param contentType  上传的文件类型
 *  @param param        参数
 *  @param successBlock 上传最终回调
 *  @param result       上传成功的集合
 */
-(void)httpUploadFileWithURL:(NSString *)url
                      images:(NSArray<UIImage *> *)images
                 contentType:(NSString *)contentType
                      params:(NSArray<NSDictionary *> *)params
                     success:(void (^)(NSDictionary *dic ,NSString *errorMsg,NSString *status,NSArray *result,NSArray *unCompleteImages)) successBlock
                      result:(NSArray *)result
{
    __weak YXClient *this = self;
    
    // 没有传来图片
    // 或者同时传了图片和参数但是两个东西长度不一样
    if (images.count == 0)                                 { successBlock(nil, nil, @"0", @[], nil); return; }
    if (params.count != 0 && images.count != params.count) { successBlock(nil, FormalLocalErrorMsg, @"1", nil, nil); return; }
    
    UIImage *image = images.firstObject;
    NSDictionary *param = params.firstObject;
    NSData *data = UIImageJPEGRepresentation(image, 0.6);
    
    [self httpUploadFileWithURL:url fileData:data contentType:contentType params:param success:^(NSDictionary *dic, NSString *errorMsg, NSString *status) {
        
        // 失败了直接break
        if (![status isEqualToString:@"200"]) {
            successBlock(dic, errorMsg, status, result, images);
        }
        else {
            // 成功了更新数据
            NSMutableArray *mImages  = images.mutableCopy;
            NSMutableArray *mParams  = params.mutableCopy;
            NSMutableArray *mResults = result.mutableCopy;
            [mImages removeObjectIdenticalTo:image];
            [mParams removeObjectIdenticalTo:param];
            if (dic) { [mResults addObject:dic]; }
            
            if (mImages.count == 0) {
                successBlock(nil, nil, @"0", mResults, @[]);
            } else {
                [this httpUploadFileWithURL:url images:mImages contentType:contentType params:mParams success:successBlock result:mResults];
            }
        }
    } progressBlock:nil];
}



# pragma mark -

-(AFHTTPRequestOperation*)downloadFileWithOption:(NSDictionary *)paramDic
                                             url:(NSString *)requestURL
                         downloadDestinationPath:(NSString *)destPath
                                         success:(void (^)(BOOL success))successBlock
                                   progressBlock:(void (^)(float progress)) progressBlock
{
    //文件临时存储路径
    NSString *temporaryFileDownloadPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request =[serializer requestWithMethod:@"GET" URLString:requestURL parameters:paramDic error:nil];
    [self addDefaultHttpHeaderField:request];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:temporaryFileDownloadPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float p = (float)totalBytesRead / totalBytesExpectedToRead;
        if (progressBlock) {
            progressBlock(p);
        }
        NSLog(@"download：%f", (float)totalBytesRead / totalBytesExpectedToRead);
    }];
    __weak YXClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [this copyTempFile:temporaryFileDownloadPath toDestination:destPath successBlcok:successBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        successBlock(NO);
    }];
    
    [operation start];
    return operation;
}

-(void)copyTempFile:(NSString *)tempPath toDestination:(NSString *)destPath successBlcok:(void (^)(BOOL success))successBlock
{
    [NSObject performBlockOnBackground:^{
        //Remove any file at the destination path
        __block NSError *fileError = nil;
        __block NSError *moveError = nil;
        if (![[self class] removeFileAtPath:destPath error:&moveError]) {
            fileError = moveError;
        }
        //Move the temporary file to the destination path
        if (!fileError) {
            [[[NSFileManager alloc] init] moveItemAtPath:tempPath toPath:destPath error:&moveError];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (moveError) {
                    fileError = moveError;
                    successBlock(NO);
                }else{
                    successBlock(YES);
                }
            });
        }else{
            successBlock(NO);
        }
    }];
}

- (NSString *)accessToken
{
    if (!_accessToken) {
        // 增加安全验证，防止accessToken为nil且进行isEqualToString操作时出错
        _accessToken = @"";
    }
    return _accessToken;
}

+(BOOL)removeFileAtPath:(NSString *)path error:(NSError **)err
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSError *removeError = nil;
        [fileManager removeItemAtPath:path error:&removeError];
        if (removeError) {
            if (err) {
                *err = removeError;
            }
            return NO;
        }
    }
    return YES;
}

+(BOOL)isLoginRequest:(NSString *)url
{
    BOOL isLoginRequest = NO;
    
    isLoginRequest = [url rangeOfString:LOGIN_API options:NSCaseInsensitiveSearch].location != NSNotFound;
    
    return isLoginRequest;
}

@end
