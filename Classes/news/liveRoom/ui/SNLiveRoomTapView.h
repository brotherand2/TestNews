//
//  SNLiveRoomTapView.h
//  sohunews
//
//  Created by chenhong on 13-5-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNLiveRoomContentCell;

@interface SNLiveRoomTapView : UIView<UIGestureRecognizerDelegate> {
    SNLiveRoomContentCell *__weak cell;
    UITapGestureRecognizer *_tapGesture;
}

@property(nonatomic,weak)SNLiveRoomContentCell *cell;
@property(nonatomic,assign)BOOL canReply;
@property(nonatomic,assign)BOOL canCopy;
@property(nonatomic,assign)BOOL canShare;

- (void)setMenuInvalid;

@end
