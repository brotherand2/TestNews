//
//  SNCommentActivityBtn.h
//  sohunews
//
//  Created by wang yanchen on 12-9-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWaitingActivityView.h"

@interface SNCommentActivityBtn : UIView {
    NSString *_title;
    SNWaitingActivityView *_actView;
    UILabel *_titleView;
    UIImageView *_commentIconView;
    UIImageView *_sepView;
    UIImageView *_sofaView;
    
    id _target;
    SEL _fuction;
    
    BOOL _enable;
}

@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) BOOL enable;

- (void)showLoading:(BOOL)bShow;
- (void)addTarget:(id)target selecor:(SEL)sel;
- (void)setCommentRead:(BOOL)hasRead;

@end
