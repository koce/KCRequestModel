//
//  KCAFRequest.h
//  KCRequestModel
//
//  Created by Koce on 2017/3/11.
//  Copyright © 2017年 Koce. All rights reserved.
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
