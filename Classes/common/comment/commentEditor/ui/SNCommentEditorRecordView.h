//
//  SNRecordView.h
//  sohunews
//
//  Created by jialei on 13-6-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPowerViewMaxHeight         88.0
#define kPowerViewMaxWidth          54.0

@protocol SNCommentRecordViewDelegate <NSObject>

- (void)snRecordChangedBegin;

- (void)snRecordChangedEnd;

@end

@interface SNRecordView : UIView
{
    UIButton *_recordButton;
    UIButton *_timerLabel;
    UIView   *_powerValueView;
    float    _powerViewPointX;
}

@property (nonatomic, strong)UIButton *recordButton;
@property (nonatomic, strong)UILabel  *timerLabel;
@property (nonatomic, strong)UIView   *powerValueView;
@property (nonatomic, weak)id <SNCommentRecordViewDelegate>recordDelegate;

- (void)powerValueChange:(float)avgPower;

@end
