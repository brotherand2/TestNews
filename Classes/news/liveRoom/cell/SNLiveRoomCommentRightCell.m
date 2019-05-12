//
//  SNLiveRoomCommentRightCell.m
//  sohunews
//
//  Created by chenhong on 13-4-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveRoomCommentRightCell.h"
#import "SNLiveRoomConsts.h"

@implementation SNLiveRoomCommentRightCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    if (self) {
        _headIcon.left = self.contentView.width - HEAD_X - _headIcon.width;
        
        UIImage *img = [UIImage imageNamed:@"live_comment_bg_r.png"];
        
        if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            _bgnImgView.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(40, 30, 30, 30)];
        }
        else {
            _bgnImgView.image = [img stretchableImageWithLeftCapWidth:30 topCapHeight:40];
        }
    }
    return self;
}

- (void)updateTheme:(NSNotification *)notification {
    [super updateTheme:notification];
    
    UIImage *img = [UIImage imageNamed:@"live_comment_bg_r.png"];
    
    if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        _bgnImgView.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(40, 30, 30, 30)];
    }
    else {
        _bgnImgView.image = [img stretchableImageWithLeftCapWidth:30 topCapHeight:40];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _headIcon.left = self.contentView.width - HEAD_X - _headIcon.width;
}

@end
