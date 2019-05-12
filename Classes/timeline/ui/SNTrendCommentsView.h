//
//  SNTrendCommentsView.h
//  sohunews
//
//  Created by jialei on 13-11-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNTimelineTrendItem;

@protocol SNTrendCmtsViewDelegate <NSObject>

- (void)snTrendCmtBtnOpenMore:(NSString *)cmtId;

@end

@interface SNTrendCommentsView : UIView

@property (nonatomic, retain)NSArray *commentsData;
@property (nonatomic, assign)CGRect moreBtnFrame;
@property (nonatomic, retain) SNTimelineTrendItem *timelineObj;
@property (nonatomic, assign) id<SNTrendCmtsViewDelegate> delegate;
@property (nonatomic, assign)int indexPath;
@property (nonatomic, assign)CGRect commentsRect;
@property (nonatomic, assign) int referFrom;

- (void)updateTheme;

@end
