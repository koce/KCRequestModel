//
//  KCRequestModel.h
//  300Heros
//
//  Created by Koce on 2017/3/11.
//  Copyright © 2017年 赵嘉诚. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KCRequestModelNetworking <NSObject>

@required
/**
 *  请求参数
 */
- (NSDictionary *)dataParams;
/**
 *  请求地址
 */
- (NSString *)urlPath;
/**
 *  结果解析是否成功
 */
- (BOOL)parse:(id)JSON;
/**
 *  结果解析
 */
- (NSArray *)parseResponse:(id)response error:(NSError **)error;

@optional
/**
 *  是否可以开始请求数据
 */
- (BOOL)prepareForLoad;
/**
 *  是否可以开始解析
 */
- (BOOL)prepareParseResponse:(id)object error:(NSError **)error;
/**
 *  http header
 */
- (NSDictionary *)headerParams;
/**
 *  Post or Get
 */
- (BOOL)usePost;
/**
 *  是否需要已登录
 */
- (BOOL)needManualLogin;
/**
 *  如果requestType指定为custom，则这个方法要返回第三方request的类名
 *
 *  @return 第三方request的类名
 */
- (NSString *)customRequestClassName;

@end

@protocol KCRequestModelDelegate;

@interface KCRequestModel : NSObject <KCRequestModelNetworking>

@property (nonatomic, strong, readonly) NSMutableArray *models;

@property (nonatomic, weak)             id<KCRequestModelDelegate> delegate;
@property (nonatomic, strong, readonly) id  responseObject;

- (void)load;
- (void)reload;
- (void)loadMore;
- (void)cancel;
- (void)reset;

@end

//委托
@protocol KCRequestModelDelegate <NSObject>

@optional
- (void)loadModelDidStart:(KCRequestModel *)model;
- (void)loadModelDidFinished:(KCRequestModel *)model;
- (void)loadModelDidFail:(KCRequestModel *)model withError:(NSError *)error;

@end
