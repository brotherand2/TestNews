//
//  SNFloorView.m
//  sohunews
//
//  Created by qi pei on 6/19/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNFloorView.h"
#import "UIColor+ColorUtils.h"
#import "SNDBManager.h"
#import "SNDatabase_FloorComment.h"
#import "SNDatabase_NewsComment.h"
#import "SNUserUtility.h"
#import "SNUserinfo.h"
#import "SNWebImageView.h"
#import "SNConsts.h"

#import "SNNameButton.h"
#import "UIImage+MultiFormat.h"

#define CEll_CONTENT_LINE_HEIGHT            ([SNUtility newsContentFontLineheight])
#define kSoundViewTag   1000

@implementation SNFloorView

@synthesize isLast, showSeparator, comment, newsId, gid, subFloorIndex,commentId,colseShare;
@synthesize cell = _cell;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (showSeparator) {

//        UIImage *sepImage = [UIImage imageNamed:@"floor_sep.png"];
        CGRect imageRect = CGRectMake(0, 0, kAppScreenWidth - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN + 10, self.bounds.size.height);
//        [sepImage drawInRect:imageRect];
       [UIView drawCellSeperateLine:imageRect margin:0];
    }
}

- (id)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];//RGBCOLOR(238, 238, 238);
        self.exclusiveTouch = YES;
        self.showFloorNum = YES;
        [self createView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIMenuController *contextMenu = [UIMenuController sharedMenuController];
    if ([contextMenu isMenuVisible])
        [contextMenu setMenuVisible:NO];
    

    if([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    return YES;
}

-(void)createView {
    CGRect screenRect = [UIScreen mainScreen].bounds;
    userInfoLabel = [[UILabel alloc] init];
    userInfoLabel.frame = CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, kFLOOR_COMMENT_CONTENT_TOP_MARGIN,
                                     CGRectGetWidth(screenRect) - kFLOOR_COMMENT_LEFT_RIGHT_MARGIN * 3 - CELL_CONTENT_LEFT_MARGIN + 10 - kFLOOR_COMMENT_FLOOR_NUM_WIDTH,
                                     kFLOOR_COMMENT_USER_INFO_HEIGHT);
    [userInfoLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    userInfoLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    userInfoLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:userInfoLabel];
    
    floorNumLabel = [[UILabel alloc] init];
    floorNumLabel.frame = CGRectMake(CGRectGetMaxX(userInfoLabel.frame), kFLOOR_COMMENT_CONTENT_TOP_MARGIN, kFLOOR_COMMENT_FLOOR_NUM_WIDTH, kFLOOR_COMMENT_USER_INFO_HEIGHT);
    [floorNumLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
    floorNumLabel.backgroundColor = [UIColor clearColor];
    floorNumLabel.textColor = SNUICOLOR(kThemeText4Color);
    floorNumLabel.textAlignment = NSTextAlignmentRight;
    floorNumLabel.right = kAppScreenWidth - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN + 10 - kFLOOR_COMMENT_LEFT_RIGHT_MARGIN;
    [self addSubview:floorNumLabel];

    contentLabel = [[SNLabel alloc] init];
    contentLabel.origin = CGPointMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, CGRectGetMaxY(userInfoLabel.frame) + kFLOOR_COMMENT_CONTENT_TOP_MARGIN);
    [contentLabel setFont:[UIFont systemFontOfSize:kFLOOR_COMMENT_CONTENT_FONT]];
    contentLabel.lineHeight = CEll_CONTENT_LINE_HEIGHT;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    contentLabel.delegate = self;
    contentLabel.alpha = themeImageAlphaValue();
    [self addSubview:contentLabel];

    userInfoLabel.tag = 101;
//    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    tapGes.delegate = self;
//    [userInfoLabel addGestureRecognizer:tapGes];
}

/*
 *设置评论内容，超过六行的缩略显示
 */
-(void)setComment:(SNNewsComment *)aComment {
    if (!aComment || comment == aComment) {
        return;
    }
    
    if (comment) {
         //(comment);
    }
    comment = aComment;
    NSString *city = [comment.city trim];
    if (city && city.length > 0) {
        userInfoLabel.text = [NSString stringWithFormat:@"%@（%@）", comment.author, city];
    } else {
        userInfoLabel.text = comment.author;
    }
    CGFloat floorHeingt = CGRectGetMaxY(userInfoLabel.frame) + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
    
    if (comment.floorNum > 0) {
        floorNumLabel.text = [NSString stringWithFormat:@"%d", comment.floorNum];
        floorNumLabel.accessibilityLabel = [NSString stringWithFormat:@"第%d楼", comment.floorNum];
    }
    
    contentLabel.text = [comment.content trim];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if ([contentLabel.text length] > 0) {
        CGSize maximumSize;
        UIFont *expandFont = [UIFont systemFontOfSize:kThemeFontSizeC];
        CGRect screenRect = [UIScreen mainScreen].bounds;
        CGSize originalSize = CGSizeMake(CGRectGetWidth(screenRect) - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN + 10 - kFLOOR_COMMENT_LEFT_RIGHT_MARGIN * 2, CGFLOAT_MAX_CORE_TEXT);
        CGSize revokeSize = CGSizeMake(kAppScreenWidth - CELL_RIGHT_MARGIN * 2 - CELL_CONTENT_LEFT_MARGIN + 10 - kFLOOR_COMMENT_LEFT_RIGHT_MARGIN * 2,
                                       CEll_CONTENT_LINE_HEIGHT * (KCOMMENT_THUMBNAIL_LINENUM + 1));
        if(self.comment.isCommentOpen){
            maximumSize = originalSize;
        } else {
            maximumSize = revokeSize;
        }
 
        CGSize changeSize = [SNLabel sizeForContent:contentLabel.text maxSize:maximumSize font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT];
        
        contentLabel.frame = CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, floorHeingt, changeSize.width, changeSize.height);

        int lines = 1;
        if (CEll_CONTENT_LINE_HEIGHT > 0 && changeSize.height > 0) {
            lines = ((int)changeSize.height%(int)CEll_CONTENT_LINE_HEIGHT == 0) ? changeSize.height/CEll_CONTENT_LINE_HEIGHT : changeSize.height/CEll_CONTENT_LINE_HEIGHT+1;
        }
        
        if (lines > KCOMMENT_THUMBNAIL_LINENUM && !self.comment.isCommentOpen) {
            int contentHeight = [SNLabel heightForContent:contentLabel.text maxWidth:changeSize.width font:kFLOOR_COMMENT_CONTENT_FONT lineHeight:CEll_CONTENT_LINE_HEIGHT maxLineCount:KCOMMENT_THUMBNAIL_LINENUM-2];
            
            contentLabel.frame = CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, floorHeingt, maximumSize.width, contentHeight);
        }
        floorHeingt += CGRectGetHeight(contentLabel.frame) + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
        
        if (lines > KCOMMENT_THUMBNAIL_LINENUM && !self.comment.isCommentOpen) {
            expandBtn = [[SNNameButton alloc]initWithFrame:CGRectZero];
            expandBtn.backgroundColor = [UIColor clearColor];
            expandBtn.exclusiveTouch = YES;
            [expandBtn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBlue1Color]] forState:UIControlStateNormal];
            [expandBtn setTitle:NSLocalizedString(@"OpenComment", @"") forState:UIControlStateNormal];
            [expandBtn.titleLabel setFont:expandFont];
            [expandBtn addTarget:self action:@selector(expandComment) forControlEvents:UIControlEventTouchUpInside];
            CGSize stringSize = [NSLocalizedString(@"OpenComment", @"") sizeWithFont:expandFont];
            expandBtn.frame = CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, floorHeingt,
                                         stringSize.width, expandBtn.titleLabel.font.pointSize);
            [self addSubview:expandBtn];
            floorHeingt += CGRectGetHeight(expandBtn.frame) + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
        }
//        [contentLabel setNumberOfLines:lines];
    }
    
    if ([comment hasAudio]) {

        SNLiveSoundView *soundView = [[SNLiveSoundView alloc] initWithFrame:CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN - 3, floorHeingt, SOUNDVIEW_WIDTH, SOUNDVIEW_HEIGHT)];
        [soundView loadIfNeeded];
        soundView.commentID = commentId;
        soundView.url = comment.commentAudUrl;
        soundView.duration = comment.commentAudLen;
        soundView.tag = kSoundViewTag;
        //[soundView setBackgroundWithImage:soundBgImage];
        [self addSubview:soundView];
        
        floorHeingt += SOUNDVIEW_SPACE+SOUNDVIEW_HEIGHT;
    }
    
    //盖楼评论中的照片    
    if(comment.commentImageSmall && [comment.commentImageSmall length] > 0)
    {
        UIImage *defaultImage = [UIImage themeImageNamed:@"defaulticon.png"];
        CGRect frame = CGRectMake(kFLOOR_COMMENT_LEFT_RIGHT_MARGIN, floorHeingt,
                                  kPicViewWidth, kPicViewHeight);
        picView = [[SNWebImageView alloc] initWithFrame:frame];
        picView.showFade = NO;
        picView.tag = commentViewType_floorPicView;
        picView.defaultImage = defaultImage;
        picView.contentMode = UIViewContentModeScaleAspectFill;
        picView.clipsToBounds = YES;
        picView.layer.cornerRadius = 3;
        picView.alpha =  themeImageAlphaValue();
        [self addSubview:picView];
        
        if (picView.urlPath) {
            [picView unsetImage];
        }
        
        //图片添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPic:)];
        [picView addGestureRecognizer:tap];
        
        //是本地url加载本地图片
        NSRange range = [self.comment.commentImageBig rangeOfString:kCommentImageFolderId];
        if (range.location != NSNotFound && range.length != 0) {
            picView.image = [UIImage imageWithContentsOfFile:self.comment.commentImageSmall];
        } else {
            if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
                picView.defaultImage = [UIImage imageNamed:@"default_photolist_recommend.png"];
                [picView unsetImage];
                
                NSData* imageData = [[TTURLCache sharedCache] dataForURL:comment.commentImageSmall];
                if(imageData)
                {
                    UIImage *sdImage = [UIImage sd_imageWithData:imageData];
                    if (!sdImage) {
                        picView.image = [UIImage imageWithData:imageData];
                    }else{
                        picView.image = sdImage;
                    }
                    // 就算本地有这个图片  urlPath也要赋值
                    picView.urlPath = comment.commentImageSmall;
                }else {
                    picView.urlPath = comment.commentImageSmall;
                }
            } else {
                UIImage *defaultImage = [UIImage themeImageNamed:@"default_photolist_click_recommend.png"];
                picView.defaultImage = defaultImage;
                UIImage *diskImage = [[TTURLCache sharedCache] imageForURL:comment.commentImageSmall fromDisk:YES];
                if ( diskImage) {
                    [picView unsetImage];
                    picView.urlPath = comment.commentImageSmall;
                }
                else {
                    picView.urlPath = nil;
                }
            }
        }
        picView.hidden = NO;
        floorHeingt += CGRectGetHeight(picView.frame) + kFLOOR_COMMENT_CONTENT_TOP_MARGIN;
    } else {
        picView.hidden = YES;
        picView.urlPath = nil;
    }
    
    self.size = CGSizeMake(CGRectGetWidth(screenRect) - kFLOOR_COMMENT_LEFT_RIGHT_MARGIN - CELL_CONTENT_LEFT_MARGIN, floorHeingt);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(replyComment) ||
		action == @selector(copyComment) ||
        action == @selector(shareComment) ||
        action == @selector(deleteComment)) {
		return YES;
	}
	return NO;
}

- (void)openPic:(UITapGestureRecognizer *)tapGesture{
    CGPoint tapPoint = [tapGesture locationInView:self];
    BOOL isTapInAuthImage = CGRectContainsPoint(picView.frame, tapPoint);
    //点击图片区域显示大图
    if (isTapInAuthImage)
    {
        if (picView.urlPath == nil)
        {
            // 加载失败后，点击加载小图
            if (self.comment.commentImageSmall &&
                self.comment.commentImageSmall.length > 0)
            {
                //是本地url加载本地图片
                NSRange range = [self.comment.commentImageSmall rangeOfString:kCommentImageFolderId];
                if (range.location != NSNotFound && range.length != 0 && self.comment.commentImageBig &&
                    [self.comment.commentImageBig length] > 0)
                {
                    
                    NSString *sourceUrl = self.comment.commentImageBig;
                    if (sourceUrl && sourceUrl.length > 0)
                    {
                        [self.cell performSelector:@selector(floorViewShowImageWithUrl:) withObject:sourceUrl];
                    }
                }
                else
                {
                    [picView loadUrlPath:self.comment.commentImageSmall];
                }
            }
        }
        else
        {
            // 没有正常加载，点击重新加载
            if (!picView.isLoading && !picView.isLoaded)
            {
                [picView loadUrlPath:self.comment.commentImageSmall];
            }
            else if (picView.isLoaded)
            {
                // 显示大图
                if ([self.cell respondsToSelector:@selector(floorViewShowImageWithUrl:)])
                {
                    NSString *sourceUrl = self.comment.commentImageBig;
                    if (sourceUrl && sourceUrl.length > 0)
                    {
                        [self.cell performSelector:@selector(floorViewShowImageWithUrl:) withObject:sourceUrl];
                    }
                }
            }
        }
    }
}

-(void)openMenu:(UITapGestureRecognizer *)tapGesture {    
    CGPoint tapPoint = [tapGesture locationInView:self];
    BOOL isTapInAuthLabel = CGRectContainsPoint(userInfoLabel.frame, tapPoint);
    BOOL isTapInAuthImage = CGRectContainsPoint(picView.frame, tapPoint);

    //点击用户头像，名称
    if(isTapInAuthLabel)
    {
        NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];
        if (self.newsId.length > 0) {
            [referInfo setObject:self.newsId forKey:kReferValue];
            [referInfo setObject:@"Newsid" forKey:kReferType];
        }
        if (self.gid.length > 1) {
            [referInfo setObject:self.gid forKey:kReferValue];
            [referInfo setObject:@"gid" forKey:kReferType];
        }
        [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Article_CommentUser] forKey:kRefer];
        bool gotoSpace = [SNUserUtility openUserWithPassport:self.comment.passport
                                                  spaceLink:self.comment.spaceLink
                                                  linkStyle:self.comment.linkStyle
                                                        pid:self.comment.pid
                                                        push:@"0" refer:referInfo];
        
        if (gotoSpace) {
            return;
        }
    }
    
    //点击图片区域显示大图
    if (isTapInAuthImage)
    {
        if (picView.urlPath == nil)
        {
            // 加载失败后，点击加载小图
            if (self.comment.commentImageSmall &&
                self.comment.commentImageSmall.length > 0)
            {
                //是本地url加载本地图片
                NSRange range = [self.comment.commentImageSmall rangeOfString:kCommentImageFolderId];
                if (range.location != NSNotFound && range.length != 0 && self.comment.commentImageBig &&
                    [self.comment.commentImageBig length] > 0)
                {
                    
                    NSString *sourceUrl = self.comment.commentImageBig;
                    if (sourceUrl && sourceUrl.length > 0)
                    {
                        [self.cell performSelector:@selector(floorViewShowImageWithUrl:) withObject:sourceUrl];
                    }
                }
                else
                {
                    [picView loadUrlPath:self.comment.commentImageSmall];
                }
            }
        }
        else
        {
            // 没有正常加载，点击重新加载
            if (!picView.isLoading && !picView.isLoaded)
            {
                [picView loadUrlPath:self.comment.commentImageSmall];
            }
            else if (picView.isLoaded)
            {
                // 显示大图
                if ([self.cell respondsToSelector:@selector(floorViewShowImageWithUrl:)])
                {
                    NSString *sourceUrl = self.comment.commentImageBig;
                    if (sourceUrl && sourceUrl.length > 0)
                    {
                        [self.cell performSelector:@selector(floorViewShowImageWithUrl:) withObject:sourceUrl];
                    }
                }
            }
        }
    }
    else
    {
        if (self.comment.status == SNCommentStatusDelete)
            return;
        
        UIMenuController *contextMenu = [UIMenuController sharedMenuController];
        if (showMenu)
        {
            showMenu = NO;
            [self resignFirstResponder];
            [contextMenu setMenuVisible:NO];
            
            if (self.cell && [self.cell respondsToSelector:@selector(setCommentMenu:)])
            {
                [self.cell setCommentMenu:NO];
            }
            
            return;
        }
        
        if (self.cell && [self.cell respondsToSelector:@selector(setCommentMenu:)])
        {
            [self.cell setCommentMenu:YES];
        }

        showMenu = YES;
        contextMenu.arrowDirection = UIMenuControllerArrowDefault;
        [contextMenu setMenuVisible:NO];
        [self becomeFirstResponder];
        
        NSMutableArray *menuItemsArray = [[NSMutableArray alloc] init];
        
        UIMenuItem *markMenuItem = [[UIMenuItem alloc] initWithTitle:@"回复" action:@selector(replyComment)];
        [menuItemsArray addObject:markMenuItem];
        
        if (SNNewsCommentStatusDeleted != comment.status && comment.isAuthor) {
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteComment)];
            [menuItemsArray addObject:item];
        }
        
        UIMenuItem *recordMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyComment)];
        [menuItemsArray addObject:recordMenuItem];
        
        if (!colseShare) {
            UIMenuItem *shareMenuItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareComment)];
            [menuItemsArray addObject:shareMenuItem];
        }
        
        contextMenu.menuItems = menuItemsArray;
        
        [contextMenu update];
        CGPoint point = [tapGesture locationInView:self];
        [contextMenu setTargetRect:CGRectMake(0, point.y, self.frame.size.width, self.frame.size.height) inView:self];
        [contextMenu setMenuVisible:YES animated:YES];
    }
}

- (void)deleteComment
{
    showMenu = NO;
    [self resignFirstResponder];
    if (self.cell && [self.cell respondsToSelector:@selector(floorViewDeleteFloorCommentId:floorIndex:)]) {
        [self.cell floorViewDeleteFloorCommentId:commentId floorIndex:subFloorIndex];
    }
}

-(void)copyComment {
    showMenu = NO;
    [self resignFirstResponder];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = comment.content;
}

- (void)shareComment {
    showMenu = NO;
    [self resignFirstResponder];
    if (self.cell && [self.cell respondsToSelector:@selector(floorViewShareFloorComment:)]) {
        [self.cell floorViewShareFloorComment:comment];
    }
}

-(void)replyComment {
    showMenu = NO;
    [self resignFirstResponder];
    if (self.cell && [self.cell respondsToSelector:@selector(floorViewReplyFloorComment:)]) {
        [self.cell floorViewReplyFloorComment:comment];
    }
}

- (void)expandComment {
    showMenu = NO;
    [self resignFirstResponder];
    if(self.cell && [self.cell respondsToSelector:@selector(floorViewExpandFloorComment:)]) {
        [self.cell  floorViewExpandFloorComment:subFloorIndex];
    }
}

#pragma mark - SNLabelDelegate
- (void)tapOnLink:(NSString *)link
{
    SNDebugLog(@"link : %@",link);
    if ([link length] > 0) {
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        
        [query setObject:link forKey:@"address"];
        
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://simpleWebBrowser"] applyAnimated:YES] applyQuery:query];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
    
}

#pragma mark -
#pragma mark SNDingServiceDelegate
//-(void)didFinishDingComment {
//    self.comment.hadDing = YES;
//    int digNum = [self.comment.digNum intValue];
//    self.comment.digNum = [NSString stringWithFormat:@"%d",digNum+1];
//    [cell changeCommentDigNumTo:self.comment.digNum commentId:self.comment.commentId];
//    if (self.comment.commentId) {
//        NSString *newsType = newsId ? kNewsId : kGid;
//        [[SNDBManager currentDataBase] updateCommentDigNumByNewsId:newsId andCommentId:self.comment.commentId andNewsType:newsType];
//    } else {
//        [[SNDBManager currentDataBase] updateMyCommentDigNumById:self.comment.cid];
//    }
//}

- (void)updateTheme {
    [expandBtn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeBlue1Color]] forState:UIControlStateNormal];
    userInfoLabel.textColor = SNUICOLOR(kThemeBlue1Color);
    floorNumLabel.textColor = SNUICOLOR(kThemeText4Color);
    contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    contentLabel.alpha = themeImageAlphaValue();
    picView.alpha = themeImageAlphaValue();
    
    SNLiveSoundView *soundView = (SNLiveSoundView *)[self viewWithTag:kSoundViewTag];
    [soundView updateTheme];
    
    [self setNeedsDisplay];
}

-(void)dealloc {
    [SNNotificationManager removeObserver:self];
    dingService.delegate = nil;
     //(dingService);
//    [JSMenuController sharedMenu].delegate = nil;
     //(comment);
     //(newsId);
     //(gid);
     //(commentId);
     //(picView);
     //(expandBtn);
}

@end
