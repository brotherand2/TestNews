//
//  SNQRUtility.m
//  HZQRCodeDemo
//
//  Created by H on 15/11/5.
//  Copyright © 2015年 Hz. All rights reserved.
//

#define kSuccessCode             (10000000)

#import "SNQRUtility.h"
#import "SNUserManager.h"
#import "SNQRCheckRequest.h"
#import "SNImgFeatureCheckRequest.h"

@interface SNQRUtility () {
}

@property (nonatomic, assign) NSTimeInterval  reqTimestamp;

//用户行为
@property (nonatomic, assign) NSInteger openAlbumCount;
@property (nonatomic, assign) NSInteger readImgFailedCount;
@property (nonatomic, assign) NSInteger unselectedImgCount;
@property (nonatomic, assign) NSInteger     lightIsOnCount;

@end

@implementation SNQRUtility

+ (SNQRUtility *)sharedInstanced {
    static SNQRUtility *__qrUtility;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        __qrUtility = [[SNQRUtility alloc] init];
        __qrUtility.openAlbumCount = 0;
        __qrUtility.readImgFailedCount = 0;
        __qrUtility.unselectedImgCount = 0;
        __qrUtility.lightIsOnCount = 0;
        __qrUtility.reqTimestamp = 0;
        __qrUtility.picReqCount = 0;
    });
    return __qrUtility;
}

+ (BOOL)openQRCodeView {
    return YES;
}

+ (CGRect)screenBounds {
    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect;
    if (![screen respondsToSelector:@selector(fixedCoordinateSpace)] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        screenRect = CGRectMake(0, 0, screen.bounds.size.height, screen.bounds.size.width);
    } else {
        screenRect = screen.bounds;
    }
    
    return screenRect;
}

+ (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait) {
        return AVCaptureVideoOrientationPortrait;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return AVCaptureVideoOrientationLandscapeLeft;
    } else if (orientation == UIInterfaceOrientationLandscapeRight){
        return AVCaptureVideoOrientationLandscapeRight;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return AVCaptureVideoOrientationPortraitUpsideDown;
    }
    
    return AVCaptureVideoOrientationPortrait;
}

+ (void)delegate:(id)delegate {
    SNQRUtility * qrUtility = [SNQRUtility sharedInstanced];
    qrUtility.verifyDelegate = delegate;
}

+ (void)verifyOnServerWith:(NSString *)content {
    [[SNQRUtility sharedInstanced] checkWithContent:content];
}

+ (void)verifyOnServerWithImageBase64String:(NSString *)imageString fromAlbum:(BOOL)isFromAlbum{
    [[SNQRUtility sharedInstanced] checkImageWithImageString:imageString fromAlbum:isFromAlbum];
}

- (void)checkImageWithImageString:(NSString *)imageStr fromAlbum:(BOOL)isFromAlbum {
    _picReqCount ++;
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    _reqTimestamp = [[NSDate date] timeIntervalSince1970];;
    NSString * tk = [NSString stringWithFormat:@"%.0f",time * 1000];
    tk = [[@"sohupicid" stringByAppendingString:tk] md5Hash];
    [parameters setObject:tk forKey:@"tk"];
    [parameters setObject:[NSString stringWithFormat:@"%0.f",time * 1000] forKey:@"t"];
    [parameters setObject:imageStr forKey:@"picContent"];
    
    [[[SNImgFeatureCheckRequest alloc] initWithDictionary:parameters] send:^(SNBaseRequest *request, id responseObject) {
        BOOL success = NO;
        NSString * url = nil;
        NSString * msg = nil;
        NSInteger statusCode;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * data = responseObject[@"data"] ? : nil;
            if (data) {
                url = data[@"content"] ? : @"";
            }
            msg = responseObject[@"statusMsg"] ? : @"";
            statusCode = [responseObject[@"statusCode"] integerValue];
            if (statusCode == kSuccessCode) {
                success = YES;
            }
        }
        if (isFromAlbum) {
            msg = @"isFromAlbum";
        }
        
        if ([self.verifyDelegate respondsToSelector:@selector(verifyFinishedWithUrl:message:successed:)]) {
            [self.verifyDelegate verifyFinishedWithUrl:url message:msg successed:success];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        BOOL success = NO;
        NSString * url = nil;
        NSString * msg = nil;
        if (isFromAlbum) {
            msg = @"isFromAlbum";
        }
        
        if ([self.verifyDelegate respondsToSelector:@selector(verifyFinishedWithUrl:message:successed:)]) {
            [self.verifyDelegate verifyFinishedWithUrl:url message:msg successed:success];
        }
    }];
}

- (void)showError {
 }

- (void)checkWithContent:(NSString *)content {
    [[[SNQRCheckRequest alloc] initWithDictionary:@{@"content":content}] send:^(SNBaseRequest *request, id responseObject) {
        BOOL success = NO;
        NSString * url = nil;
        NSString * msg = nil;
        NSInteger statusCode;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * data = responseObject[@"data"] ? : nil;
            if (data) {
                url = data[@"content"] ? : @"";
            }
            msg = responseObject[@"statusMsg"] ? : @"";
            statusCode = [responseObject[@"statusCode"] integerValue];
            if (statusCode == kSuccessCode) {
                success = YES;
            }
        }
        
        if ([self.verifyDelegate respondsToSelector:@selector(verifyFinishedWithUrl:message:successed:)]) {
            [self.verifyDelegate verifyFinishedWithUrl:url message:msg successed:success];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        BOOL success = NO;
        NSString * url = nil;
        NSString * msg = nil;
        
        if ([self.verifyDelegate respondsToSelector:@selector(verifyFinishedWithUrl:message:successed:)]) {
            [self.verifyDelegate verifyFinishedWithUrl:url message:msg successed:success];
        }
    }];
}

#pragma mark - 用户行为分析
/**
 *  <扫一扫·埋点> 重置用户行为统计
 */
- (BOOL)resetStat {
    self.openAlbumCount = 0;
    self.readImgFailedCount = 0;
    self.unselectedImgCount = 0;
    self.lightIsOnCount = 0;
    return YES;
}

/**
 *  <扫一扫·埋点> 用户打开相册埋点
 */
+ (void)dotOpenAlbum {
    [[SNQRUtility sharedInstanced] addDotOpenAlbum];
}

- (void)addDotOpenAlbum {
    ++ self.openAlbumCount;
}

+ (NSString *)getDotOpenAlbum{
    return [NSString stringWithFormat:@"%ld",(long)[SNQRUtility sharedInstanced].openAlbumCount];
}

/**
 *  <扫一扫·埋点> 用户打开闪光灯埋点
 */
+ (void)dotOpenLight:(BOOL)on {
    [[SNQRUtility sharedInstanced] addDotOpenLight:on];
}

- (void)addDotOpenLight:(BOOL)on {
    if (on) {
        ++ self.lightIsOnCount;
    }
}

+(NSString *)getDotOpenLight {
    return [NSString stringWithFormat:@"%ld",(long)[SNQRUtility sharedInstanced].lightIsOnCount];
}

/**
 *  <扫一扫·埋点> 图片识别失败
 */
+ (void)dotImgReadFail {
    [[SNQRUtility sharedInstanced] addDotImgReadFail];
}

- (void)addDotImgReadFail{
    ++ self.readImgFailedCount;
}

+ (NSString *)getDotImgReadFail{
    return [NSString stringWithFormat:@"%ld",(long)[SNQRUtility sharedInstanced].readImgFailedCount];
}

/**
 *  <扫一扫·埋点> 打开相册未选取图片直接退出
 */
+ (void)dotNoSelectedImg {
    [[SNQRUtility sharedInstanced] addDotNoSelectedImg];
}

- (void)addDotNoSelectedImg {
    ++ self.unselectedImgCount;
}

+ (NSString *)getDotNoSelectedImg{
    return [NSString stringWithFormat:@"%ld",(long)[SNQRUtility sharedInstanced].unselectedImgCount];
}

- (void)handlePushWithFinish:(HandlePushFinishBlock)finishedBlock {
    if (self.qrviewController && [self.qrviewController respondsToSelector:@selector(didReceiveRemote:)]) {
        [self.qrviewController didReceiveRemote:^{
            finishedBlock();
        }];
    }
}

- (void)handleEnterBackground:(HandleEnterBackgroundFinishBlock)finishedBlock {
    if (self.qrviewController && [self.qrviewController respondsToSelector:@selector(didEnterBackground)]) {
        [self.qrviewController didEnterBackground];
    }
    finishedBlock();
}

- (NSString *)multipleStrGetHexByBinary:(NSString *)multipleStr{
    NSArray * tempArr = [multipleStr componentsSeparatedByString:@","];
    NSMutableArray * container = [NSMutableArray array];
    if (tempArr.count > 0) {
        for (NSString * tmp in tempArr) {
            [container addObject:[self getHexByBinary:tmp]];
        }
    }
    return [container componentsJoinedByString:@","];
}

//进制转换 2进制转16进制
-(NSString *)getHexByBinary:(NSString *)binary {
    NSMutableDictionary  *binaryDic = [[NSMutableDictionary alloc] init];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"a" forKey:@"1010"];
    [binaryDic setObject:@"b" forKey:@"1011"];
    [binaryDic setObject:@"c" forKey:@"1100"];
    [binaryDic setObject:@"d" forKey:@"1101"];
    [binaryDic setObject:@"e" forKey:@"1110"];
    [binaryDic setObject:@"f" forKey:@"1111"];
    NSString *hexString=[[NSString alloc] init];
    for (int i=0; i<[binary length]; i++) {
        if (i*4+4 > binary.length) {
            break;
        }
        NSString *key = [binary substringWithRange:NSMakeRange(i*4, 4)];
        hexString = [NSString stringWithFormat:@"%@%@",hexString,[NSString stringWithFormat:@"%@",[binaryDic objectForKey:key]]];
    }
    return hexString;
}

@end
