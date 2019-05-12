//
//  SNTrendUgcCell.m
//  sohunews
//
//  Created by jialei on 14-3-27.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNTrendUgcCell.h"
#import "SNShareManager.h"

@interface SNTrendUgcCell()
{
    BOOL _isMenuShow;
}

@property (nonatomic, retain)SNActionMenuController *actionMenuController;

@end

@implementation SNTrendUgcCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hanleTap:)];
    [self addGestureRecognizer:tap];
    [tap release];
    
    return self;
}

- (void)dealloc
{
    TT_RELEASE_SAFELY(_actionMenuController);
    
    [super dealloc];
}

#pragma mark - UIMenuController
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(shareTrend)) {
		return YES;
	}
	return NO;
}

- (void)hanleTap:(UITapGestureRecognizer *)tapGesture
{
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if (_isMenuShow)
    {
        _isMenuShow = NO;
        [contextMenu setMenuVisible:NO];
    }
    else {
        _isMenuShow = YES;
        contextMenu.arrowDirection = UIMenuControllerArrowDefault;
        [self becomeFirstResponder];
        
        NSMutableArray *menuItemsArray = [[NSMutableArray alloc] init];
        UIMenuItem *shareMenuItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareTrend)];
        [menuItemsArray addObject:shareMenuItem];
        [shareMenuItem release];
        
        contextMenu.menuItems = menuItemsArray;
        [menuItemsArray release];
        
        [contextMenu update];
        
        CGRect rect = CGRectMake(0, self.frame.size.height / 2, self.frame.size.width, self.frame.size.height);
        [contextMenu setTargetRect:rect inView:self];
        [contextMenu setMenuVisible:YES animated:YES];
    }
}

#pragma mark - shareAction
- (void)shareTrend
{
    self.actionMenuController = [[[SNActionMenuController alloc] init] autorelease];
    self.actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    self.actionMenuController.contextDic = [self createActionMenuContentContext];
    self.actionMenuController.sourceType = self.timelineTrendObj.originContentObj.sourceType;
    self.actionMenuController.timelineContentId = self.timelineTrendObj.originContentObj.referId;
    self.actionMenuController.disableLikeBtn = YES;
    
    [self.actionMenuController showActionMenu];
}

- (NSMutableDictionary *)createActionMenuContentContext {
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    
    self.timelineTrendObj.originContentObj.type = SNTimelineOriginContentTypeTextAndPics;
    self.timelineTrendObj.originContentObj.picUrl = @"timeline_share_default.png";
    
    if (self.timelineTrendObj.originContentObj.referId.length > 0) {
        dicShareInfo[kShareInfoKeyNewsId] = self.timelineTrendObj.originContentObj.referId;
    }
    if (self.timelineTrendObj.originContentObj.abstract.length > 0) {
        dicShareInfo[kShareInfoKeyShareComment] = self.timelineTrendObj.content;
        dicShareInfo[kShareInfoKeyContent] = self.timelineTrendObj.originContentObj.abstract;
        
        NSRange range = [self.timelineTrendObj.originContentObj.abstract rangeOfString:@"http://"];
        if (range.location > 0 && range.length > 0) {
            NSString *title = [self.timelineTrendObj.originContentObj.abstract substringToIndex:range.location];
            self.timelineTrendObj.originContentObj.title = @"分享语音";
            self.timelineTrendObj.originContentObj.abstract = title;
        }
    }
    
    dicShareInfo[kShareInfoKeyShareRead] = self.timelineTrendObj.originContentObj;
    
    return dicShareInfo;
}


@end
