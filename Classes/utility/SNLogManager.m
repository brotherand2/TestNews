//
//  SNLogManager.m
//  sohunews
//
//  Created by wangyy on 15/4/29.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNLogManager.h"
#import "SNUserLocationManager.h"
#import "SNPickStatisticRequest.h"
#import "SNUploadLogRequest.h"

#define kLogMsgTriggerNumber    100
#define kLogMsgTriggerTime      5*60

@interface SNLogManager ()

@property (nonatomic, strong) NSMutableArray        * logArray;

@end

@implementation SNLogManager
+ (SNLogManager *)sharedInstance {
    static SNLogManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNLogManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.logArray = [[NSMutableArray alloc] init];
        
//        NSString *urlString = SNLinks_Pick_sGifLogBaseUrl;
//        self.URL = [[NSURL alloc] initWithString:urlString];
        
        [NSTimer scheduledTimerWithTimeInterval:kLogMsgTriggerTime target:self selector:@selector(logAndFileSend) userInfo:nil repeats:YES];
        
        [SNNotificationManager addObserver:self selector:@selector(terminateNotification) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)addLog:(NSString *)log
{
    [self.logArray addObject:log];
    
    //触发条件， 写满规定条数
    if ([self.logArray count] >= kLogMsgTriggerNumber) {
        [self sendLogList];
    }
}

- (void)logManagerWithCid:(NSString *)cid
                     Plat:(NSString *)plat
                  Version:(NSString *)version
                  Channle:(NSString *)channle
                  NetType:(NSString *)netType
                ProductId:(NSString *)productId
                     Time:(NSString *)time
                   GbCode:(NSString *)gbCode
                     Type:(NSString *)type
                 StatType:(NSString *)statType
                  ObjType:(NSString *)objType
              Immediately:(BOOL)immediately
{
    NSString *logMsg = [NSString stringWithFormat:@"c=%@&p=%@&v=%@&h=%@&net=%@&u=%@&t=%@&gbcode=%@&Type=%@&statType=%@&objType=%@", cid, plat,version, channle, netType, productId, time, gbCode, type, statType, objType];
    
    [self.logArray addObject:logMsg];
    
    //触发条件， 写满规定条数
    if ([self.logArray count] >= kLogMsgTriggerNumber || immediately == YES) {
        [self sendLogList];
    }
}

- (void)sendLogList{
   
    NSString* postString = [self.logArray componentsJoinedByString:@"\n"];
    NSMutableData *postData = [NSMutableData dataWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    [[[SNUploadLogRequest alloc] initWithPostData:postData] send:^(SNBaseRequest *request, id responseObject) {
        [self.logArray removeAllObjects];
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self writeToLogFile];
    }];
}

- (void)sendLogFile:(NSString *)filePath{
    
    NSArray *logArray = [NSMutableArray arrayWithContentsOfFile:filePath];
    NSString* postString = [logArray componentsJoinedByString:@"\n"];
    NSMutableData *postData = [NSMutableData dataWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[[SNUploadLogRequest alloc] initWithPostData:postData] send:^(SNBaseRequest *request, id responseObject) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if(error != nil){
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
    }];
}

- (void)writeToLogFile{
    NSString* path = [SNUtility getDocumentPath];
    path = [path stringByAppendingPathComponent:@"logManager"];
    BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    NSAssert(bo,@"创建目录失败");
    
    NSString* filePath = [path stringByAppendingFormat:@"/logFile_%@", [self getCurrentTime]];
    BOOL success =[self.logArray writeToFile:filePath atomically:YES];
    if (success == YES) {
        [self.logArray removeAllObjects];
    }
}

- (NSString *)getCurrentTime{
    NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
    [fomatter setDateFormat:@"YYYY_MM_DD_HH_MM_SS"];
    return [fomatter stringFromDate:[NSDate date]];
}

- (void)logAndFileSend{
    
    //内存日志上传
    if ([self.logArray count] > 0) {
        [self sendLogList];
    }
    
    //本地日志上传
    NSString* path = [SNUtility getDocumentPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    path = [path stringByAppendingPathComponent:@"logManager"];
    if ([fileManager fileExistsAtPath:path]) {
        NSError * error = nil;
        NSArray *tempFileList = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:path error:&error]];
        if(error != nil){
            return;
        }
        for (int i = 0; i < [tempFileList count]; i++) {
            NSString *filePath = [path stringByAppendingFormat:@"/%@",[tempFileList objectAtIndex:i]];
            [self sendLogFile:filePath];
        }
    }
}

- (void)terminateNotification{
    if ([self.logArray count] > 0) {
        [self writeToLogFile];
    }
}

/**
 * 通用log上报接口。LogType为业务类型项(必传),LogStatType为统计需求项(必传).
 */
+ (BOOL)sendLogWithType:(LogType)type StatType:(LogStatType)statType Query:(NSDictionary *)query {
    
    switch (type) {
        case kLogType_qrcode: // 二维码功能log收集
        {
            return [[SNLogManager sharedInstance] sendQRCodeLogWith:statType Query:query];
            
            break;
        }
            
        default:
            break;
    }

    return NO;
}

- (BOOL)sendQRCodeLogWith:(LogStatType)statType Query:(NSDictionary *)query {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:[[UIDevice currentDevice] systemVersion] forKey:@"sdk"];
    [params setValue:@"qrcode" forKey:@"Type"];
    
    switch (statType) {
        case kLogStatType_open:
        {
            [params setValue:[query objectForKey:kRefer defalutObj:nil] forKey:@"from"];
            [params setValue:@"open" forKey:@"statType"];
            return [self sendLogWithParams:params];
            break;
        }
            
        case kLogStatType_kp:
        {
            [params setValue:[self qrParameterizeWithDictionary:query] forKey:@"objType"];
            [params setValue:@"kp" forKey:@"statType"];
            return [self sendLogWithParams:params];
            break;
        }
            
        default:
            break;
    }
    return NO;
}


/**
 *  解析二维码用户行为参数的
 */
- (NSString *)qrParameterizeWithDictionary:(NSDictionary *)dictionary {
    /*
     （当statType=kp时必须有值）
     
     objType=imgs,readfails,flashstatus,noselect
     
     例:objType=2,1,0,0
     
     imgs 打开图片选取的次数
     
     readfails 图片识别失败的次数
     
     flashstatus, 0闪光灯关闭,1 闪光灯打开
     
     noselect 打开图片选取后未选择图片直接返回的次数

     */
    return [NSString stringWithFormat:@"%@,%@,%@,%@",
            dictionary[@"imgs"]?:@"",
            dictionary[@"readfails"]?:@"",
            dictionary[@"flashstatus"]?:@"",
            dictionary[@"noselect"]?:@""];
}

/**
 *  通用get方式上报log
 */

- (BOOL)sendLogWithParams:(NSDictionary *)params {
    if (params.count > 0) {
        [[[SNPickStatisticRequest alloc] initWithDictionary:params
                                           andStatisticType:PickLinkDotGifTypeS
                                             needAESEncrypt:NO] send:nil failure:nil];
        return YES;
    }
    return NO;
}

@end
