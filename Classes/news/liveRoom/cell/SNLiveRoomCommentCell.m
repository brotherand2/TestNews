//
//  SNLiveCommentCell.m
//  sohunews
//
//  Created by Chen Hong on 12-6-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveRoomCommentCell.h"
#import "UIColor+ColorUtils.h"
#import "SNLiveRoomTableViewController.h"
#import "SNLiveRoomConsts.h"
#import "SNLiveRoomTapView.h"
#import "SNUserUtility.h"
#import "UIImageView+WebCache.h"
#import "SNUserManager.h"
#import "SNNewsLoginManager.h"


@implementation SNLiveRoomCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    if (self) {
        UIImage *img = [UIImage imageNamed:@"live_comment_bg.png"];
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
    if ([self.object isKindOfClass:[SNLiveCommentObject class]]) {
        UIImage *img = [UIImage imageNamed:@"live_comment_bg.png"];
        
        if ([img respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            _bgnImgView.image = [img resizableImageWithCapInsets:UIEdgeInsetsMake(40, 30, 30, 30)];
        }
        else {
            _bgnImgView.image = [img stretchableImageWithLeftCapWidth:30 topCapHeight:40];
        }
    }
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
    SNLiveCommentObject* data = object;
    CGFloat top = kGap;
    top += AUTHOR_Y + 17 + AUTHOR_CONTENT_GAP;
    
    if (data.content.length > 0) {
        if (data.contentH1 <= 0) {
            CGSize contentSize = [SNLabel sizeForContent:data.content maxSize:CGSizeMake(CONTENT_W, CGFLOAT_MAX_CORE_TEXT) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
            data.contentH1 = contentSize.height;
        }
        
        if (data.showAllComment) {
            top += data.contentH1 + AUTHOR_CONTENT_GAP;
        } else {
            if (data.contentH2 <= 0) {
                CGSize newSize = [SNLabel sizeForContent:data.content maxSize:CGSizeMake(CONTENT_W, CONTENT_H) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];

                data.contentH2 = newSize.height;
            }
            
            if (data.contentH1 > data.contentH2 + CONTENT_H_2) {
                top += data.contentH2 + SHOW_MORE_GAP;
                top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
            } else {
                data.showAllComment = YES;
                top += data.contentH1 + AUTHOR_CONTENT_GAP;
            }
        }
    }
    
    // 音频
    if ([data hasSound]) {
        top += SOUND_H + AUTHOR_CONTENT_GAP;
    }
    
    // 图片
    if (data.imageUrl.length) {
        top += IMG_H + AUTHOR_CONTENT_GAP;
    }
    
    // 回复网友
    if ([data hasReply]) {
        top += REPLY_LINE_H + AUTHOR_CONTENT_GAP;
        top += 17 + AUTHOR_CONTENT_GAP;
        if (data.replyComment.content.length > 0) {
            if (data.replyComment.contentH1 <= 0) {
                CGSize contentSize = [SNLabel sizeForContent:data.replyComment.content maxSize:CGSizeMake(CONTENT_W, CGFLOAT_MAX_CORE_TEXT)  font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                data.replyComment.contentH1 = contentSize.height;
            }

            if (data.replyComment.showAllComment) {
                top += data.replyComment.contentH1 + AUTHOR_CONTENT_GAP;
            } else {
                if (data.replyComment.contentH2 <= 0) {
                    CGSize contentSize = [SNLabel sizeForContent:data.replyComment.content maxSize:CGSizeMake(CONTENT_W, CONTENT_H) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                    data.replyComment.contentH2 = contentSize.height;
                }
                
                if (data.replyComment.contentH1 > data.replyComment.contentH2 + CONTENT_H_2) {
                    top += data.replyComment.contentH2 + SHOW_MORE_GAP;
                    top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
                } else {
                    data.replyComment.showAllComment = YES;
                    top += data.replyComment.contentH1 + AUTHOR_CONTENT_GAP;
                }
            }
        }

        // 音频
        if ([data.replyComment hasSound]) {
            top += SOUND_H + AUTHOR_CONTENT_GAP;
        }
        
        if (data.replyComment.imageUrl.length) {
            top += IMG_H + AUTHOR_CONTENT_GAP;
        }
    }
    
    // 回复直播员
    else if ([data hasReplyCont]) {
        top += REPLY_LINE_H + AUTHOR_CONTENT_GAP;
        top += 17 + AUTHOR_CONTENT_GAP;
        if (data.replyContent.action.length > 0) {
            if (data.replyContent.contentH1 <= 0) {
                CGSize contentSize = [SNLabel sizeForContent:data.replyContent.action maxSize:CGSizeMake(CONTENT_W, CGFLOAT_MAX_CORE_TEXT) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                data.replyContent.contentH1 = contentSize.height;
            }
            
            if (data.replyContent.showAllContent) {
                top += data.replyContent.contentH1 + AUTHOR_CONTENT_GAP;
            } else {
                if (data.replyContent.contentH2 <= 0) {
                    CGSize contentSize = [SNLabel sizeForContent:data.replyContent.action maxSize:CGSizeMake(CONTENT_W, CONTENT_H) font:CONTENT_FONT.pointSize lineHeight:CONTENT_LINE_HEIGHT];
                    data.replyContent.contentH2 = contentSize.height;
                }
                
                if (data.replyContent.contentH1 > data.replyContent.contentH2 + CONTENT_H_2) {
                    top += data.replyContent.contentH2 + SHOW_MORE_GAP;
                    top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
                } else {
                    data.replyContent.showAllContent = YES;
                    top += data.replyContent.contentH1 + AUTHOR_CONTENT_GAP;
                }
            }
        }
        
        // 链接
        if (data.replyContent.link.length > 0) {
            top += LINK_H + AUTHOR_CONTENT_GAP;
        }

        // 音频
        else if ([data.replyContent hasSound]) {
            top += SOUND_H + AUTHOR_CONTENT_GAP;
        }
        
        // 视频
        if ([data.replyContent hasVideo]) {
            top += IMG_H + AUTHOR_CONTENT_GAP;
        }
        
        // 图片
        else if (data.replyContent.contentPic.length) {
            top += IMG_H + AUTHOR_CONTENT_GAP;
        }
    }
    
    return top + BOTTOM_GAP;
}

- (void)setObject:(id)object {
	if (_object != object) {
		[super setObject:object];

        if ([object isKindOfClass:[SNLiveCommentObject class]]) {
            SNLiveCommentObject* data = object;
            
            // 网友
            [self setTopWithCommentObj:data];
            
            // 回复
            if ([data hasReply]) {
                if ([data.replyComment hasSound]) {
                    _replySoundView.commentID = data.commentId;
                }
                [self setBottomWithCommentObj:data.replyComment];
            }
            
            // 回复直播员
            else if ([data hasReplyCont]) {
                if ([data.replyContent hasSound]) {
                    _replySoundView.commentID = data.commentId;
                }
                [self setBottomWithContentObj:data.replyContent];
            }
            
            else {
                [self hideBottom];
            }
        }
	}
}


- (void)layoutSubviews {
	[super layoutSubviews];
    
    if (![_object isKindOfClass:[SNLiveCommentObject class]]) {
        return;
    }

    SNLiveCommentObject *data = (SNLiveCommentObject *)_object;

    CGFloat width = self.contentView.width - 2*kTableCellMargin;
    _bgnImgView.width = width - _headIcon.width;
    
    BOOL bMyComment = [data isMyComment];
    CGFloat left = bMyComment ? AUTHOR_X_R : AUTHOR_X;
    CGFloat soundLeft = left - SOUND_OFFSETX;
    _authorBtn.frame = CGRectMake(left, AUTHOR_Y, (_authorBtn.width > AUTHOR_W ? AUTHOR_W : _authorBtn.width), AUTHOR_H);
    
    CGFloat top = AUTHOR_Y + 17 + AUTHOR_CONTENT_GAP;
    
    if (_timeLabel.text.length) {
        _timeLabel.frame = CGRectMake(_bgnImgView.width - TIME_RIGHT_GAP - _timeLabel.width, _authorBtn.frame.origin.y, _timeLabel.width, _authorBtn.frame.size.height);
    }
    
    [self layoutTopBadgeView];
    _contentLabel.alpha = themeImageAlphaValue();
    if (_contentLabel.text.length > 0) {
        if (data.showAllComment) {
            _contentLabel.frame = CGRectMake(left, top, CONTENT_W, data.contentH1);
            top += data.contentH1 + AUTHOR_CONTENT_GAP;
        } else {
            _contentLabel.frame = CGRectMake(left, top, CONTENT_W, data.contentH2);
            top += data.contentH2 + SHOW_MORE_GAP;
            
            _showAllContentBtn.frame = CGRectMake(left, top, _showAllContentBtn.width, SHOW_MORE_H);
            top += SHOW_MORE_H + AUTHOR_CONTENT_GAP;
        }
    } else {
        _showAllContentBtn.hidden = YES;
    }
    
    if ([data hasSound]) {
        _soundView.frame = CGRectMake(soundLeft, top, CONTENT_W, SOUND_H);
        top += SOUND_H + AUTHOR_CONTENT_GAP;
    }
    
    _topTapView.frame = CGRectMake(left, AUTHOR_Y, CONTENT_W, top - AUTHOR_Y);
    
    if (!_imgView.hidden) {
        _imgView.frame = CGRectMake(left, top, IMG_W, IMG_H);
        _maskBtn.frame = _imgView.frame;
        top += IMG_H + AUTHOR_CONTENT_GAP;
    }
    
    // 回复网友
    if ([data hasReply]) {
        top = [self layoutReplyComment:data.replyComment left:left top:top];
    }
    // 回复主持人
    else if ([data hasReplyCont]) {
        top = [self layoutReplyContent:data.replyContent left:left top:top];
    }
    else {
        _bottomTapView.frame = CGRectZero;
        _showAllReplyCommentBtn.hidden = YES;
    }
    
    if (data.showAllComment || data.contentH1 == 0) {
        _showAllReplyCommentBtn.hidden = YES;
    }
    
    _bgnImgView.frame = CGRectMake(bMyComment ? 12 : _headIcon.right, _headIcon.top - 4, width - _headIcon.width, top + BOTTOM_GAP);
}

- (void)onImgClick:(id)sender {
    SNWebImageView *imgView = nil;
    NSString *imageUrl = nil;
    
    SNLiveCommentObject *data = (SNLiveCommentObject *)self.object;
   
    BOOL bClickTop = sender == _maskBtn;
    
    if (bClickTop) {
        imgView = _imgView;
        imageUrl = [self topImageViewUrl];
    } else {
        imgView = _replyImgView;
        imageUrl = [self bottomImageViewUrl];
    }
    
    if (imgView.image == [self imgViewPlaceholderImage]) {
        [self loadImageView:imgView withUrl:imageUrl];
    } else {
        if (!imgView.isLoading && !imgView.isLoaded) {
            [self loadImageView:imgView withUrl:imageUrl];
        }
        else {
            // 视频
            if (!bClickTop && [data.replyContent hasVideo]) {
                [self showVideoControllerWithUrl:data.replyContent.mediaInfo.mediaUrl poster:imageUrl videoPlaceHolderFrame:_replyImgView.frame];
            } else if (imgView.isLoaded) {
                // 显示大图
                if ([_viewController respondsToSelector:@selector(showImageWithUrl:)]) {
                    [_viewController showImageWithUrl:imageUrl];
                }
            }
        }
    }
}

- (void)replyComment:(SNLiveRoomTapView *)sender {
    if (![SNUserManager isLogin]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
#pragma clang diagnostic pop
        NSDictionary *dict = [NSDictionary dictionaryWithObject:method forKey:@"method"];
        //[SNUtility openLoginViewWithDict:dict];
        
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111直播间边看边聊回复评论
            
        } Failed:nil];
        
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
//#pragma clang diagnostic pop
//
//        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://loginRegister"] applyAnimated:YES] applyQuery:[NSDictionary dictionaryWithObject:method forKey:@"method"]];
//        [[TTNavigator navigator] openURLAction:_urlAction];

        [SNUtility setUserDefaultSourceType:kUserActionIdForLiveChat keyString:kLoginSourceTag];
        return;
    }
    else {
//        SNUserinfoEx *userInfoEx = [SNUserinfoEx userinfoEx];
//        if (!userInfoEx.isRealName) {
//            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"手机绑定", @"headTitle", @"立即绑定", @"buttonTitle",  nil];
//            TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:@"tt://mobileNumBindLogin"] applyAnimated:YES] applyQuery:dic];
//            [[TTNavigator navigator] openURLAction:_urlAction];
//            return;
//        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (_viewController && [_viewController respondsToSelector:@selector(replyComment:type:name:pid:)]) {
        SNLiveCommentObject *data = (SNLiveCommentObject *)self.object;
        NSString *rid = nil, *type = nil, *replyName = nil, *replyPid = nil;
        if (sender == _topTapView) {
            rid = [NSString stringWithFormat:@"%lld", [data.rid longLongValue]];
            type = kReplyLiveComment;
            replyName = data.author;
            replyPid = data.authorInfo.pid;
        } else if (sender == _bottomTapView) {
            if ([data hasReply]) {
                rid = [NSString stringWithFormat:@"%lld", [data.replyComment.commentId longLongValue]];
                type = kReplyLiveComment;
                replyName = data.replyComment.author;
                replyPid = data.replyComment.authorInfo.pid;
            } else if ([data hasReplyCont]) {
                rid = [NSString stringWithFormat:@"%lld", [data.replyContent.contentId longLongValue]];
                type = kReplyLiveContent;
                replyName = data.replyContent.author;
                replyPid = data.replyContent.authorInfo.pid;
            }
        }
        [_viewController performSelector:@selector(replyComment:type:name:pid:) withObject:rid withObject:type withObject:replyName withObject:replyPid];
    }
#pragma clang diagnostic pop

}

- (void)clickHeadIcon:(id)sender {
    if ([self.object isKindOfClass:[SNLiveCommentObject class]]) {
        SNLiveCommentObject *data = (SNLiveCommentObject *)self.object;
        SNDebugLog(@"click head icon %@", data.authorInfo.authorimg);
        
        if (data.authorInfo) {
            [SNUtility shouldUseSpreadAnimation:NO];
            NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
            [referInfo setObject:@"0" forKey:kReferValue];
            [referInfo setObject:@"0" forKey:kReferType];

            [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Live_UserName] forKey:kRefer];
            [SNUserUtility openUserWithPassport:data.authorInfo.passport
                                     spaceLink:data.authorInfo.spaceLink
                                     linkStyle:data.authorInfo.linkStyle
                                           pid:data.authorInfo.pid
                                           push:@"0" refer:referInfo];
        }
    }
}

- (void)clickNameBtn:(id)sender {
    if ([self.object isKindOfClass:[SNLiveCommentObject class]]) {
        SNLiveCommentObject *data = (SNLiveCommentObject *)self.object;
        NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
        [referInfo setObject:@"0" forKey:kReferValue];
        [referInfo setObject:@"0" forKey:kReferType];
       
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Live_UserName] forKey:kRefer];
        if (sender == _authorBtn) {
            SNDebugLog(@"click name btn passport: %@ pid: %@", data.authorInfo.passport, data.authorInfo.pid);
            if (data.authorInfo) {
                [SNUserUtility openUserWithPassport:data.authorInfo.passport
                                         spaceLink:data.authorInfo.spaceLink
                                         linkStyle:data.authorInfo.linkStyle
                                               pid:data.authorInfo.pid
                                               push:@"0" refer:referInfo];
            }
        }
        else if (sender == _replyAuthorBtn) {
            SNDebugLog(@"click name btn passport: %@ pid: %@", data.replyComment.authorInfo.passport, data.replyComment.authorInfo.pid);
            if ([data hasReply]) {
                if (data.replyComment.authorInfo) {
                    [SNUserUtility openUserWithPassport:data.replyComment.authorInfo.passport
                                             spaceLink:data.replyComment.authorInfo.spaceLink
                                             linkStyle:data.replyComment.authorInfo.linkStyle
                                                   pid:data.replyComment.authorInfo.pid
                                                   push:@"0" refer:referInfo];
                }
            }
            else if ([data hasReplyCont]) {
                if (data.replyContent.authorInfo) {
                    [SNUserUtility openUserWithPassport:data.replyContent.authorInfo.passport
                                             spaceLink:data.replyContent.authorInfo.spaceLink
                                             linkStyle:data.replyContent.authorInfo.linkStyle
                                                   pid:data.replyContent.authorInfo.pid
                                                   push:@"0" refer:referInfo];
                }
            }
        }
    }
}

@end
