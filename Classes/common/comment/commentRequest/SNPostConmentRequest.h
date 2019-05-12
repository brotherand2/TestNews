//
//  SNPostConmentRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@class SNSendCommentObject;
@interface SNPostConmentRequest : SNDefaultParamsRequest

- (instancetype)initWithCommentObject:(SNSendCommentObject *)cmtObj andRefer:(NSInteger)refer;
- (instancetype)initWithDictionary:(NSDictionary *)dict withCommentImageData:(NSData *)imageData andCommentAudioData:(NSData *)audioData;
@end
