//
//  SNTimelineCell.h
//  sohunews
//
//  Created by jojo on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTimelineTrendObjects.h"
#import "SNTimelineConfigs.h"
#import "SNTLCommonView.h"
#import "SNTLComViewBuilder.h"
#import "SNTLComViewOnlyTextBuilder.h"
#import "SNTLComViewSubscribeBuilder.h"
#import "SNTLComViewTextAndPicsBuilder.h"
#import "SNHeadIconView.h"
#import "NSAttributedString+Attributes.h"
#import "SNLabel.h"
#import "UIControl+Blocks.h"

@interface SNTimelineCell : UITableViewCell<SNLabelDelegate> {
    SNHeadIconView *_headIconView;
    UILabel *_nameLabel;
    UILabel *_timeLabel;
    SNLabel *_contentLabel;
    
    SNLabel *_abstractLabel;
    
    UIButton *_commentButton;
    UIButton *_deleteButton;
    
    UIButton *_moreCommentsButton;
    NSMutableArray *_commentViewsArray;
    NSMutableArray *_commentMoreButtonArray;
    NSMutableArray *_commentViewsFrameArray;
    
    CGRect _originalContentRect;
    UIView *_originalTapview;
    
    UIImageView *_videoIconView;
    UIButton *_subButton;
    UIButton*_moreButton;
}

@property(nonatomic, retain) SNTimelineTrendItem *timelineObj;
@property(nonatomic, retain) SNTLComViewBuilder *commonViewBuilder;

@property(nonatomic, assign) BOOL hideComment; // default is NO
@property(nonatomic, assign) BOOL showDetele;
@property(nonatomic, assign) BOOL ignoreUserInfoTap; // default is NO // 是否屏蔽点击人名跳转

@property(nonatomic, assign) int indexPath;
@property(nonatomic, assign) id delegate;

+ (CGFloat)heightForTimelineObj:(SNTimelineTrendItem *)timelineObj hideComment:(BOOL)hideComment;
- (UIButton*)makeMoreButton;

@end

