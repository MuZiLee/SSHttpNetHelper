//
//  SSHttpNetHelper.h
//  SSHttpNetHelper
//
//  Created by Vimin on 2017/7/27.
//  Copyright © 2017年 广州方鼎软件科技发展有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSUploadParam : NSObject

/**
 *  上传的二进制数据
 */
@property (strong, nonatomic) NSData *data;

/**
 *  上传的参数名称
 */
@property (copy, nonatomic) NSString *name;

/**
 *  上传到服务器文件名称
 */
@property (copy, nonatomic) NSString *fileName;

/**
 *  上传文件数据类型
 */
@property (copy, nonatomic) NSString *mimeType;

@end

typedef NS_ENUM(NSInteger, SSNetworkReachabilityStatus) {
    SSNetworkReachabilityStatusUnknown          = -1,
    SSNetworkReachabilityStatusNotReachable     = 0,
    SSNetworkReachabilityStatusReachableViaWWAN = 1,
    SSNetworkReachabilityStatusReachableViaWiFi = 2,
};

typedef NSURLSessionDataTask SSURLSessionDataTask;
typedef void(^SSRequestSuccess)(id data);
typedef void(^SSUploadProgress)(NSProgress *progress);
typedef void(^SSRequestFailure)(NSError *error);
typedef void(^ReachabilityStatusChangeBlock)(SSNetworkReachabilityStatus status);

@interface SSHttpNetHelper : NSObject

/**
 *  网络状态监听
 */
+ (void)ss_startNetworkStatusMonitoringWithReachabilityStatusChangeBlock:(ReachabilityStatusChangeBlock)reachabilityStatusChangeBlock;

/**
 *  单例
 */
+ (instancetype)defaultHelper;

/**
 *  GET请求
 */
- (SSURLSessionDataTask *)ss_GET:(NSString *)url
                      parameters:(NSDictionary *)parameters
                         success:(SSRequestSuccess)success
                         failure:(SSRequestFailure)failure;
/**
 *  POST请求
 */
- (SSURLSessionDataTask *)ss_POST:(NSString *)url
                       parameters:(NSDictionary *)parameters
                          success:(SSRequestSuccess)success
                          failure:(SSRequestFailure)failure;

/**
 *  上传单个文件
 */
- (SSURLSessionDataTask *)ss_UPLOAD:(NSString *)url
                         parameters:(NSDictionary *)parameters
                           progress:(SSUploadProgress)progress
                            success:(SSRequestSuccess)success
                            failure:(SSRequestFailure)failure
                        uploadParam:(SSUploadParam *)uploadParam;

@end
