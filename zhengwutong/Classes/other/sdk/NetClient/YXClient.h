//
//  YXClient.h
//
//  Created by jhqiu on 16/1/4.
//  Copyright © 2016年 jhqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ServerEnvironment.h"


@class UploadTask, AFHTTPRequestOperation;

typedef NS_ENUM(NSInteger,EMHttpRequestType) {
    httpGet,
    httpPost,
    httpPut,
    httpDelete,
    httpMax,
};


typedef enum : NSUInteger {
    
    ServerDefault,
    ServerApi,
    ServerMsg,
    
} EServerUrl;

@interface YXClient : NSObject

@property (nonatomic, copy) NSString *agentString;
@property (nonatomic, copy) NSString *accessToken;

+(YXClient *)instance;
# pragma mark - 网络请求
/**
 *  通用网络请求(异步操作)
 *
 *  @param url         请求的url地址
 *  @param requestType 请求类型 get post put delete
 *  @param aDict       请求参数
 *  @param block       请求回调
 *
 */
-(AFHTTPRequestOperation *)requestWithAPI:(NSString *)api
                              requestType:(EMHttpRequestType)requestType
                               withParams:(NSDictionary *)aDict
                             successBlock:(void (^)(NSDictionary *dic, NSString *errorMsg, NSString *sStatus))block;


# pragma mark - (NSData, NSDictionary) -> url
/**
 *  上传文件，不支持自动断点续传(异步操作)
 *
 *  @param url           上传接口地址
 *  @param fileData      要上传的文件
 *  @param contentType   类型
 *  @param param         参数
 *  @param successBlock  结束回调
 *  @param progressBlock 进度回调
 */
-(void)httpUploadFileWithURL:(NSString *)url
                    fileData:(NSData *)fileData
                 contentType:(NSString *)contentType
                      params:(NSDictionary *)param
                     success:(void (^)(NSDictionary *dic ,NSString *errorMsg,NSString *status)) successBlock
               progressBlock:(void (^)(float fProgress,float fUploadSpeed )) progressBlock;

# pragma mark - [UIImage] -> url
/**
 *  批量上传图片任务，传入一个文件或者图片的数组(异步操作)
 *
 *  @param url          上传的API
 *  @param images       要上传的图片
 *  @param successBlock 上传图片的回调
 */
-(void)httpUploadImagesWithURL:(NSString *)url
                        images:(NSArray *)images
                       success:(void (^)(NSDictionary *dic ,NSString *errorMsg,NSString *status,NSArray *results,NSArray *unCompleteImages)) successBlock;

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
                                         NSArray<NSDictionary *> *results,
                                         NSArray<UIImage *> *unCompleteImages))successBlock;

# pragma mark -
/**
 *  文件下载
 *
 *  @param paramDic      文件下载参数
 *  @param requestURL    要下载的文件的url
 *  @param destPath      下载后的文件存储地址
 *  @param successBlock  下载成功回调
 *  @param progressBlock 下载失败回调
 */
-(AFHTTPRequestOperation *)downloadFileWithOption:(NSDictionary *)paramDic
                                              url:(NSString *)requestURL
                          downloadDestinationPath:(NSString *)destPath
                                          success:(void (^)(BOOL success))successBlock
                                    progressBlock:(void (^)(float progress)) progressBlock;

@end


@interface YXClient (util)

//单个文件的大小
+(long long) fileSizeAtPath:(NSString*) filePath;
//遍历文件夹获得文件夹大小，返回多少M
+(float ) folderSizeAtPath:(NSString*) folderPath;
+(NSString *)getFileNameFromPath:(NSString *)path;

+(BOOL)isValidString:(id)obj;
+(BOOL)isValidDictionary:(id) obj;
+(BOOL)isValidArray:(id) obj;

@end






