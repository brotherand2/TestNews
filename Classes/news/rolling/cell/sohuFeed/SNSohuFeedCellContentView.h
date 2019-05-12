//
//  SNSohuFeedCellContentView.h
//  sohunews
//
//  Created by wangyy on 2017/5/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SNFeedType) {
    SohuFeedPhotos,
    SohuFeedBigPic
};

@interface SNSohuFeedCellContentView : UIView

@property (nonatomic, strong) UIColor *userNameColor;
@property (nonatomic, strong) NSString *avatorUrl;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) CGFloat titleWidth;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, strong) NSMutableAttributedString *titleAttStr;
@property (nonatomic, strong) NSString *feedTitle;
@property (nonatomic, assign) NSInteger transferNum;
@property (nonatomic, assign) NSInteger commentNum;
@property (nonatomic, strong) NSString *recomTime;
@property (nonatomic, strong) NSString *recomReasons;
@property (nonatomic, assign) SNFeedType cellType;
@end
