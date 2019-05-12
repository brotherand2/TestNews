//
//  SNTrendCommentButton.m
//  sohunews
//
//  Created by jialei on 13-12-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendCommentButton.h"
#import "SNTimelineConfigs.h"
#import "SNBaseEditorViewController.h"

@interface SNTrendCommentButton()
{
    NSString *_text;
    int _startImageX;
    int _startImageY;
    int _startTextX;
    int _startTextY;
    int _textWidth;
}

@property (nonatomic, strong)UIImage *backgroundImage;
@property (nonatomic, strong)UIImage *cmtImage;

@end

@implementation SNTrendCommentButton
@synthesize referFrom;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.backgroundImage = [UIImage themeImageNamed:@"trend_comment_bg.png"];
        self.cmtImage = [UIImage themeImageNamed:@"trend_comment_btn.png"];
        _text = @"评论";
        CGSize textSize = [_text sizeWithFont:[UIFont systemFontOfSize:kApprovalFontSize]];
        CGSize imageSize = _cmtImage.size;
        float gapWidth = (frame.size.width - imageSize.width / 2 - textSize.width - 10) / 2;
        _startImageX = gapWidth;
        _startImageY = (frame.size.height - imageSize.height) / 2;
        _startTextX = frame.size.width - gapWidth - textSize.width;
        _startTextY = (frame.size.height - textSize.height) / 2;
        _textWidth  = textSize.width;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(commentAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)dealloc
{
     //(_actId);
     //(_pid);
     //(_fPid);
     //(_backgroundImage);
     //(_cmtImage);
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self.backgroundImage drawInRect:self.bounds];
    [self.cmtImage drawInRect:CGRectMake(_startImageX, _startImageY, _cmtImage.size.width, _cmtImage.size.height)];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, SNUICOLORREF(kFloorViewCommentContentColor));
    [_text textDrawAtPoint:CGPointMake(_startTextX, _startTextY)
                  forWidth:_textWidth
                  withFont:[UIFont systemFontOfSize:kApprovalFontSize]
             lineBreakMode:NSLineBreakByTruncatingTail
                 textColor:SNUICOLOR(kFloorViewCommentContentColor)];
    
    [super drawRect:rect];
}

#pragma mark -commentButtonAction
- (void)commentAction
{
//    [SNNotificationManagerpostNotificationName:kTLTrendSendComment object:self.actId];

    // cc统计
    if (self.referFrom == REFER_MORE) {
        SNUserTrack *curPage = [SNUserTrack trackWithPage:tab_me link2:nil];
        SNUserTrack *toPage = [SNUserTrack trackWithPage:circle_comment link2:nil];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_comment];
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    if (self.actId.length) {
        [dic setObject:self.actId forKey:kCircleCommentKeyActId];
    }
    
    if (self.pid.length > 0)
        [dic setObject:self.pid forKey:kCircleCommentKeySpid];
    
    if (self.fPid.length > 0)
        [dic setObject:self.fPid forKey:kCircleCommentKeyFpid];
    
    TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://modalCircleCommentEditor"] applyAnimated:YES]
                           applyQuery:dic];
    [[TTNavigator navigator] openURLAction:action];
}

#pragma mark - updateTheme
- (void)updateTheme
{
    self.backgroundImage = [UIImage themeImageNamed:@"trend_comment_bg.png"];
    self.cmtImage = [UIImage themeImageNamed:@"trend_comment_btn.png"];
    
    
    [self setNeedsDisplay];
}

@end
