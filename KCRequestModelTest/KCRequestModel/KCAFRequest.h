//
//  KCAFRequest.h
//  Koce_Weibo
//
//  Created by 赵嘉诚 on 16/7/6.
//  Copyright © 2016年 赵嘉诚. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KCAFRequestDelegate;

//接口
@protocol KCAFRequest <NSObject>

@property (nonatomic, assign) BOOL      usePost;
@property (nonatomic, assign) BOOL      useTocken;
//@property (nonatomic, assign) BOOL      useCache;
@property (nonatomic, assign) NSTimeInterval        timeOutSeconds;

@property (nonatomic, weak) id<KCAFRequestDelegate>     delegate;

//response
@property (nonatomic, strong, readonly) id responseObject;

- (void)initRequestWithBaseURLString:(NSString *)urlString;
- (void)addHeaderParams:(NSDictionary *)headerParams;
- (void)setParams:(NSDictionary *)params;

- (void)load;
- (void)cancel;

@end

@interface KCAFRequest : NSObject <KCAFRequest>

@end

//委托
@protocol KCAFRequestDelegate <NSObject>

@required

- (void)requestDidStartLoad:(id<KCAFRequest>)request;
- (void)requestDidFinished:(id)JSON;
- (void)requestDidFailWithError:(NSError *)error;

@end