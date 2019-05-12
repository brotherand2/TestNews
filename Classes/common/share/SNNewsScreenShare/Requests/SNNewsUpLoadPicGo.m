//
//  SNNewsUpLoadPicGo.m
//  sohunews
//
//  Created by wang shun on 2017/8/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsUpLoadPicGo.h"

@interface SNNewsUpLoadPicGo ()

@property (nonatomic,strong) NSData* fileData;

@end

@implementation SNNewsUpLoadPicGo

- (instancetype)initWithDictionary:(NSDictionary *)dict WithFile:(NSData*)file{
    if (self = [super initWithDictionary:dict]) {
        self.fileData = file;
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodUpload;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Screen_UploadPic;
}


/*发送反馈的图片数据拼到表单里*/
- (void)sn_appendFileDataWith:(id<AFMultipartFormData>)formData {
    
    if (self.fileData && [self.fileData isKindOfClass:[NSData class]]) {
        
        NSDate *date = [NSDate date];
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"HHmmssSSS"];
        NSString *now = [dateformatter stringFromDate:date];
        
        [formData appendPartWithFileData:self.fileData
                                    name:@"picData"
                                fileName:[NSString stringWithFormat:@"ScreenShare_%@",now]
                                mimeType:@"image/png"];

    }
}

/**
 
 /api/screen/upLoadPic.go
 
 参数
 
 newsId	int
 新闻id
 
 pid	long
 用户passportId
 
 p1	String
 客户端cid base64
 
 shareOn	String
 分享渠道 Default狐友,WeiXinChat微信好友,WeiXinMoments微信朋友圈
 
 thirdId	String
 第三方id 狐友不用传,微信传openid
 
 picHash	String
 图片MD5
 
 picLength	int
 图片大小字节数
 
 picData	byte[]	
 图片内容
 
 
 **/

/**
 Success 200
 
 statusCode	int
 返回状态码 31020000=成功,31020001=参数错误,31020002=图片信息错误,31020003=系统内部错误
 
 statusMsg	String
 返回信息
 
 data	Json
 
 数据
 {
 "statusCode": 31020000,
 "statusMsg": "Success"
 }
 **/

@end
