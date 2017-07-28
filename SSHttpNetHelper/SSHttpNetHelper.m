//
//  SSHttpNetHelper.m
//  SSHttpNetHelper
//
//  Created by Vimin on 2017/7/27.
//  Copyright © 2017年 广州方鼎软件科技发展有限公司. All rights reserved.
//

#import "SSHttpNetHelper.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation SSUploadParam

@end

typedef NS_ENUM(NSUInteger, SSRequestType) {
    SSRequestTypeGet = 0,
    SSRequestTypePost
};

@implementation SSHttpNetHelper

+ (void)ss_startNetworkStatusMonitoringWithReachabilityStatusChangeBlock:(ReachabilityStatusChangeBlock)reachabilityStatusChangeBlock {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager manager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                // 移动数据
                reachabilityStatusChangeBlock(SSNetworkReachabilityStatusReachableViaWWAN);
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                // WiFi
                reachabilityStatusChangeBlock(SSNetworkReachabilityStatusReachableViaWiFi);
                break;
            }
            case AFNetworkReachabilityStatusNotReachable: {
                // 无网络连接
                reachabilityStatusChangeBlock(SSNetworkReachabilityStatusNotReachable);
                break;
            }
            default: {
                // 网络状态未知
                reachabilityStatusChangeBlock(SSNetworkReachabilityStatusUnknown);
                break;
            }
        }
    }];
    // 开始监听
    [manager startMonitoring];
}

+ (instancetype)defaultHelper {
    static SSHttpNetHelper *defaultHelper = nil;
    // 创建单例
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHelper = [[self alloc] init];
    });
    return defaultHelper;
}

- (AFHTTPSessionManager *)getAFHttpSessionManager {
    static AFHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 打开状态栏旋转菊花
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        // 创建AFHttpSessionManager
        manager = [AFHTTPSessionManager manager];
        // 设置请求超时时间
        manager.requestSerializer.timeoutInterval = 30;
        // 返回数据序列化,返回二进制数据
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 设置接收数据类型
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*"]];
    });
    return manager;
}

- (SSURLSessionDataTask *)ss_GET:(NSString *)url
                      parameters:(NSDictionary *)parameters
                         success:(SSRequestSuccess)success
                         failure:(SSRequestFailure)failure {
    return [self ss_baseRequest:SSRequestTypeGet url:url parameters:parameters success:success failure:failure];
}

- (SSURLSessionDataTask *)ss_POST:(NSString *)url
                       parameters:(NSDictionary *)parameters
                          success:(SSRequestSuccess)success
                          failure:(SSRequestFailure)failure {
    return [self ss_baseRequest:SSRequestTypePost url:url parameters:parameters success:success failure:failure];
}

- (SSURLSessionDataTask *)ss_baseRequest:(SSRequestType)type
                                     url:(NSString *)url
                              parameters:(NSDictionary *)parameters
                                 success:(SSRequestSuccess)success
                                 failure:(SSRequestFailure)failure{
    SSURLSessionDataTask *dataTask = nil;
    AFHTTPSessionManager *manager = [self getAFHttpSessionManager];
    switch (type) {
        case SSRequestTypeGet: {
            // GET
            dataTask = [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                // 请求成功
                if (success) {
                    success([self dataHandleWithData:responseObject]);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                // 请求失败
                if (failure) {
                    failure(error);
                }
            }];
            break;
        }
        case SSRequestTypePost: {
            // POST
            dataTask = [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                // 请求成功
                if (success) {
                    success([self dataHandleWithData:responseObject]);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                // 请求失败
                if (failure) {
                    failure(error);
                }
            }];
            break;
        }
        default:
            break;
    }
    return dataTask;
}

- (SSURLSessionDataTask *)ss_UPLOAD:(NSString *)url
                         parameters:(NSDictionary *)parameters
                           progress:(SSUploadProgress)progress
                            success:(SSRequestSuccess)success
                            failure:(SSRequestFailure)failure
                        uploadParam:(SSUploadParam *)uploadParam {
    SSURLSessionDataTask *dataTask = nil;
    AFHTTPSessionManager *manager = [self getAFHttpSessionManager];
    dataTask = [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 拼接数据
        [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.fileName mimeType:uploadParam.mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success([self dataHandleWithData:responseObject]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    return dataTask;
}

// 二进制数据转OC对象
- (id)dataHandleWithData:(NSData *)data {
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        return data;
    }
    return obj;
}

@end
