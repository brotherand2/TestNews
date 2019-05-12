//
//  SNTimelineContentView.h
//  sohunews
//
//  Created by jojo on 13-7-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTimelineCell.h"

@interface SNTimelineContentView : UIView<SNLabelDelegate> {
    SNHeadIconView *_headIconView;
    UILabel *_nameLabel;
    UILabel *_timeLabel;
    SNLabel *_contentLabel;
    SNLabel *_abstractLabel;
    
    CGRect _originalContentRect;
    UIView *_originalTapview;
    
    SNWebImageView *_originalImageView;
    UIImageView *_videoIconView;
    UILabel *_commentNumLabel;
    
    // size cache
    CGFloat _heightContent;
    CGFloat _heightTitle;
    CGFloat _heightFrom;
    CGFloat _heightAbstract;
}

@property(nonatomic, retain) SNTimelineTrendItem *timelineObj;

@end
