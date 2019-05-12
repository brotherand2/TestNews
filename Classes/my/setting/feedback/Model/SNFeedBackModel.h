//
//  SNFeedBackModel.h
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFBDateTopMargin   12.0f
#define kFBNameTopMargin   17.0f
#define kFBIconLeftMargin  14.0f
#define kFBIconWidth       34.0f
#define kFBDateTopMargin   12.0f
#define kFBNameLeftMargin  10.0f
#define kFBBubblrBottomMargin 10.0f
#define kFBTextLeftMargin  13.0f
#define kFBWarningWidth    30.0f

#define kFBImageWidth  200.0f
#define kFBImageHeight 355.0f

@interface SNFeedBackModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *fbID;     // 用户反馈ID
@property (nonatomic, copy) NSString *date;
@property (nonatomic, assign, getter=isSendFaild) BOOL sendFaild;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign,getter=isHideDate) BOOL hideDate;

+ (CGFloat)calRowHeightWithModel:(SNFeedBackModel *)model;


@end
