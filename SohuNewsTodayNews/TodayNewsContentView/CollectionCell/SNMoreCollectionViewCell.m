//
//  SNMoreCollectionViewCell.m
//  sohunews
//
//  Created by wangyy on 15/10/30.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNMoreCollectionViewCell.h"
#import "SNDevice.h"
#import "UIColor+ColorUtils.h"
#import "SNTodayWidgetConst.h"

@interface SNMoreCollectionViewCell ()

@property (nonatomic, strong) UILabel *moreTitle;
@property (nonatomic, strong) UIImageView *arrowImg;

@end

@implementation SNMoreCollectionViewCell

@synthesize moreTitle = _moreTitle;
@synthesize arrowImg = _arrowImg;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        float x = (self.frame.size.width - 222) / 2;
        self.moreTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 15, self.frame.size.width- 2*x, self.frame.size.height - 15 *2)];
        //self.moreTitle.text = @"查看更多精彩新闻";
        self.moreTitle.text = @"查看更多";
        self.moreTitle.textColor = [UIColor blackColor];
        self.moreTitle.layer.cornerRadius = 6;
        self.moreTitle.layer.masksToBounds = YES;
        self.moreTitle.textAlignment = NSTextAlignmentCenter;
        self.moreTitle.font = [UIFont systemFontOfSize:15];
        self.moreTitle.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"vbg.png"]];
        [self addSubview:self.moreTitle];
        
        //ios10适配 5.7.2 delete wangchuanwen begin
        /*CGFloat x = (self.frame.size.width - 130 - 16) / 2 + 130 + 2;
        self.arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(x , 21, 16, 16)];
        self.arrowImg.image = [UIImage imageNamed:@"todaywidget_morenews_arrow.png"];
        [self addSubview:self.arrowImg];
         */
        //ios10适配 5.7.2 delete wangchuanwen end
    }
    
    return self;
}

@end
