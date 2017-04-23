//
//  KCRequestModel.m
//  300Heros
//
//  Created by Koce on 2017/3/11.
//  Copyright © 2017年 赵嘉诚. All rights reserved.
//

#import "KCRequestModel.h"
#import "KCAFRequest.h"

@interface KCRequestModel () <KCAFRequestDelegate>

@property (nonatomic, strong) id<KCAFRequest> request;

@property (nonatomic, strong) NSMutableArray *models;

@end

@implementation KCRequestModel

#pragma mark - life cycle
- (void)dealloc
{
    [self cancel];
}

#pragma mark - KCAFRequestDelegate
- (void)requestDidStartLoad:(id<KCAFRequest>)request
{
    if ([self.delegate respondsToSelector:@selector(loadModelDidStart:)]) {
        [self.delegate loadModelDidStart:self];
    }
}

- (void)requestDidFinished:(id)JSON
{
    _responseObject = self.request.responseObject;
    
    BOOL rec = [self parse:JSON];
    
    if (rec) {
        if ([self.delegate respondsToSelector:@selector(loadModelDidFinished:)]) {
            [self.delegate loadModelDidFinished:self];
        }
    }
}

- (void)requestDidFailWithError:(NSError *)error
{
    _responseObject = self.request.responseObject;
    
    if ([self.delegate respondsToSelector:@selector(loadModelDidFail:withError:)]) {
        [self.delegate loadModelDidFail:self withError:error];
    }
}

#pragma mark - KCRequestModelNetworking
- (NSDictionary *)dataParams
{
    return nil;
}

- (NSString *)urlPath
{
    return nil;
}

- (BOOL)parse:(id)JSON
{
    NSError *error = nil;
    
    if (![self prepareParseResponse:JSON error:&error] || error) {
        [self requestDidFailWithError:error];
        return NO;
    }
    
    NSArray *list;
    if ([JSON isKindOfClass:[NSData class]]) {
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:JSON options:NSJSONReadingMutableContainers error:&err];
        if (err) {
            list = [self parseResponse:JSON error:&error];
        }else {
            list = [self parseResponse:dic error:&error];
        }
    }else {
        list = [self parseResponse:JSON error:&error];
    }
    
    if (error) {
        [self requestDidFailWithError:error];
        return NO;
    }else{
        [self.models addObjectsFromArray:list];
        return YES;
    }
}

- (NSArray *)parseResponse:(id)response error:(NSError *__autoreleasing *)error
{
    return nil;
}

- (BOOL)prepareForLoad
{
    return YES;
}

- (BOOL)prepareParseResponse:(id)object error:(NSError *__autoreleasing *)error
{
    return YES;
}

- (NSDictionary *)headerParams
{
    return nil;
}

- (BOOL)usePost
{
    return NO;
}

- (BOOL)needManualLogin
{
    return NO;
}

- (NSString *)customRequestClassName
{
    return @"KCAFRequest";
}

#pragma mark - public function
- (void)load
{
    [self reset];
    
    if ([self prepareForLoad]) {
        [self loadInternal];
    }
}

- (void)reload
{
    [self reset];
    
    if ([self prepareForLoad]) {
        [self loadInternal];
    }
}

- (void)loadMore
{
    [self cancel];
    [self loadInternal];
}

- (void)cancel
{
    if (self.request) {
        [self.request cancel];
        self.request = nil;
    }
}

- (void)reset
{
    [self cancel];
    [self.models removeAllObjects];
}

#pragma mark - private function
- (void)loadInternal
{
    Class cls = NSClassFromString([self customRequestClassName]);
    self.request = [cls new];
    
    self.request.delegate = self;
    self.request.usePost = [self usePost];
    [self.request initRequestWithBaseURLString:[self urlPath]];
    [self.request setParams:[self dataParams]];
    [self.request addHeaderParams:[self headerParams]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.request load];
    });
}

#pragma mark - getter
- (NSMutableArray *)models
{
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}


@end
