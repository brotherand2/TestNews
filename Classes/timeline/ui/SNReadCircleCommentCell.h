//
//  SNReadCircleCommentCell.h
//  sohunews
//
//  Created by jialei on 13-12-16.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLabel.h"
#import "SNTableViewCell.h"
#import "SNTrendCommentsView.h"

typedef enum {
    SNTimelineCommentBgTypeTop = 0,
    SNTimelineCommentBgTypeMiddle,
    SNTimelineCommentBgTypeBottom
}SNTrendDetailCmtPosition;

@interface SNReadCircleCommentCell : SNTableViewCell<SNLabelDelegate>
{
    
}

@property (nonatomic, retain)SNTimelineCommentsObject *cmtObj;
@property (nonatomic, assign)id<SNTrendCmtsViewDelegate> delegate;
@property (nonatomic, assign)SNTrendDetailCmtPosition index;

+ (CGFloat)heightForReadCircleComment:(SNTimelineCommentsObject *)cmtObj objIndex:(int)index;
- (void)setObject:(SNTimelineCommentsObject *)cmtObj;

@end
