//
//  SNApprovalView.m
//  sohunews
//
//  Created by jialei on 13-12-2.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNApprovalButton.h"
#import "SNTimelineObjects.h"
#import "SNTimelinePostService.h"
#import "SNUserManager.h"

#define kApprovalNumLevel   (10000)
#define kApprovalNumDftTxt  (@"赞")

@interface SNApprovalButton()
{
    UIImage *_backgroundImage;
    UILabel *_numberLabel;
}

@property (nonatomic, strong)UIImage *backgroundImage;


@end

@implementation SNApprovalButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.backgroundImage = [UIImage themeImageNamed:@"trend_comment_bg.png"];
        
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = [UIFont systemFontOfSize:kApprovalFontSize];
        _numberLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
        _numberLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_numberLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(approvalActionSuc)];
        [self addGestureRecognizer:tap];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(reciveapprovalActionFail:)
                                                     name:kTLTrendSendApprovalFailNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(reciveApprovalActionSuc:)
                                                     name:kTLTrendSendApprovalSucNotification
                                                   object:nil];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.customBgImage) {
        [self.customBgImage drawInRect:self.bounds];
    }
    else {
        [self.backgroundImage drawInRect:self.bounds];
    }
    
    [super drawRect:rect];
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];    
}

- (void)setCustomBgImage:(UIImage *)customBgImage
{
    if ([customBgImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        customBgImage = [customBgImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    }
    else {
        customBgImage = [customBgImage stretchableImageWithLeftCapWidth:20 topCapHeight:10];
    }
    _customBgImage = customBgImage;
}

- (void)setTopNumbers:(int)topNumbers
{
    _topNumbers = topNumbers;
    NSString *text = kApprovalNumDftTxt;
    if (topNumbers > 0) {
        if(topNumbers - kApprovalNumLevel > 0) {
            int textNum = (int)(topNumbers / kApprovalNumLevel);
            text = [NSString stringWithFormat:@"%d万", textNum];
        }
        else {
            text = [NSString stringWithFormat:@"%d", topNumbers];
        }
    }
    _numberLabel.text = text;
    CGSize labelSize = [_numberLabel.text sizeWithFont:[UIFont systemFontOfSize:kApprovalFontSize]];
    _numberLabel.size = labelSize;
    float gapWidth = (kSNTLTrendApprovalWidth - kApprovalViewWidth - labelSize.width) / 2;
    _numberLabel.top = (self.bounds.size.height - labelSize.height) / 2;
    _numberLabel.right = kSNTLTrendApprovalWidth - gapWidth - 2;
    if (_dingImageView.left > 0) {
        _dingImageView.left = gapWidth - 2;
    }
}

- (void)resetTopNumbers
{
    if (!_hasApproval) {
        if ([_numberLabel.text isEqualToString:kApprovalNumDftTxt]) {
            _topNumbers = 1;
            self.trendItem.topNum = 1;
            [self setTopNumbers:1];
        }
        else {
            [self setTopNumbers:++_topNumbers];
            self.trendItem.topNum = _topNumbers;
        }
    }
    else {
        if ([_numberLabel.text isEqualToString:@"1"]) {
            _topNumbers = 0;
            self.trendItem.topNum = 0;
            [self setTopNumbers:0];
        }
        else {
            [self setTopNumbers:--_topNumbers];
            self.trendItem.topNum = _topNumbers;
        }
    }
}

- (void)setHasApproval:(BOOL)isApproval
{
    _hasApproval = isApproval;
    self.dingImageView.highlighted = isApproval;
}

#pragma mark - viewActions
//赞点击后立即更新UI
- (void)approvalActionSuc
{
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {

        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if([SNUserManager isLogin])
    {
        [[SNTimelinePostService sharedService] timelineTrendApproval:self.actId
                                                                spid:self.trendItem.pid
                                                        approvalType:!_hasApproval];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (self.actId.length) {
            [dic setObject:self.actId forKey:kSNTLTrendKeyActId];
        }
        [SNNotificationManager postNotificationName:kTLTrendSendApprovalSucNotification object:dic];
    }
    else
    {
        [SNGuideRegisterManager showGuideWithApproval:self.actId pid:self.trendItem.pid approvalType:!_hasApproval];
    }
}

//赞服务器返回失败后更新UI
- (void)reciveapprovalActionFail:(NSNotification *)notification
{
    
}

- (void)reciveApprovalActionSuc:(NSNotification *)notification
{
    NSDictionary *dic = [notification object];
    NSString *actId = [dic objectForKey:kSNTLTrendKeyActId];
    
    if (actId.length > 0 && [actId isEqualToString:self.actId]) {
        [self doAnimation:!_hasApproval];
        [self resetTopNumbers];
        _hasApproval = !_hasApproval;
        self.trendItem.isTop = _hasApproval;
    }
}

#pragma mark - updateTheme
- (void)updateTheme
{
    [super updateTheme];
    self.backgroundImage = [UIImage themeImageNamed:@"trend_comment_bg.png"];
    _numberLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    
    [self setNeedsDisplay];
}

@end
