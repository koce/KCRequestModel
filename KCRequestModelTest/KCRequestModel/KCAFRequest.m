//
//  KCAFRequest.m
//  Koce_Weibo
//
//  Created by 赵嘉诚 on 16/7/6.
//  Copyright © 2016年 赵嘉诚. All rights reserved.
//

#import "KCAFRequest.h"
#import "AFNetworking.h"

typedef void (^KCAFSucceed)(NSURLSessionDataTask *request, id responseObject);
typedef void (^KCAFFailure)(NSURLSessionDataTask *request, NSError *error);

//@interface KCAFClient : AFHTTPSessionManager
//
//+ (instancetype)sharedManager;
//
//@end
//
//@implementation KCAFClient
//
//+ (instancetype)sharedManager
//{
//    static KCAFClient *client;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        client = [[KCAFClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
//    });
//    return client;
//}
//
//@end


@interface KCAFRequest () <KCAFRequestDelegate>

@property (nonatomic, strong) AFHTTPSessionManager* manager;
@property (nonatomic, strong) NSURLSessionDataTask* requestTask;
@property (nonatomic, strong) NSString* urlString;
@property (nonatomic, copy)   NSDictionary* params;

@end

@implementation KCAFRequest

#pragma mark -- KCAFRequest
@synthesize delegate        = _delegate;
@synthesize usePost         = _usePost;
@synthesize useTocken       = _useTocken;
//@synthesize useCache        = _useCache;
@synthesize timeOutSeconds  = _timeOutSeconds;
@synthesize responseObject  = _responseObject;

- (void)initRequestWithBaseURLString:(NSString *)urlString
{
    NSAssert(urlString, @"Model无urlPath");
    
    self.timeOutSeconds = 20.0f;
    self.urlString = urlString;
    
    self.manager = [AFHTTPSessionManager manager];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    self.manager.requestSerializer.timeoutInterval = self.timeOutSeconds;
}

- (void)addHeaderParams:(NSDictionary *)headerParams
{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (headerParams) {
        [dict addEntriesFromDictionary:headerParams];
    }
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

- (void)setParams:(NSDictionary *)params
{
    _params = params;
}

- (void)load
{
    if ([NSThread isMainThread]) {
        [self requestDidStartLoad:self];
    }else{
        //同步执行，先阻塞当前线程
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self requestDidStartLoad:self];
        });
    }
    
    __weak typeof(self) weakSelf = self;
    KCAFSucceed succeedBlock = ^(NSURLSessionDataTask *task, id responseObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf -> _responseObject = responseObject;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestDidFinished:responseObject];
        });
    };
    
    KCAFFailure failureBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestDidFailWithError:error];
        });
    };
    
    
    if (self.usePost) {
        self.requestTask = [self.manager POST:self.urlString parameters:self.params progress:nil success:succeedBlock failure:failureBlock];
    }else{
        self.requestTask = [self.manager GET:self.urlString parameters:self.params progress:nil success:succeedBlock failure:failureBlock];
    }
}

- (void)cancel
{
    if (self.requestTask) {
        [self.requestTask cancel];
    }
}

#pragma mark -- KCAFRequestDelegate
- (void)requestDidStartLoad:(KCAFRequest *)request
{
    if ([self.delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
        [self.delegate requestDidStartLoad:request];
    }
}

- (void)requestDidFinished:(id)JSON
{
    if ([self.delegate respondsToSelector:@selector(requestDidFinished:)]) {
        [self.delegate requestDidFinished:JSON];
    }
}

- (void)requestDidFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(requestDidFailWithError:)]) {
        [self.delegate requestDidFailWithError:error];
    }
}

#pragma mark -- private function








@end
