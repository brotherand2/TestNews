//
//  SNBookMarkView.m
//  sohunews
//
//  Created by H on 2016/10/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNBookMarkView.h"
#import "SNBookMarkViewModel.h"
#import "UIImage+Story.h"
#import "UIColor+StoryColor.h"

#define kTextPullToAddBookMark          @"向下拖拽可添加书签"
#define kTextReleaseToAddBookMark       @"松开添加书签"
#define kTextPullToCancelBookMark       @"向下拖拽可取消书签"
#define kTextReleaseToCancelBookMark    @"松开取消书签"

#define BookMarkLeftOffset              0.0//书签左边距
#define BookMarkTopOffset               0.0//书签上边距
#define BookMarkRightOffset             22.0//书签右边距
#define BookMarkWidth                   (38/2.0)//书签宽
#define BookMarkHeight                  (50/2.0)//书签高

#define TitleLabelLeftOffset            14.0//书签标题左边距
#define TitleLabelTopOffset             15.0//书签标题上边距
#define TitleLabelOriginX               0.0
#define TitleLabelOriginY               0.0
#define TitleLabelWidth                 120.0//书签标题宽
#define TitleLabelHeight                20.0//书签标题高
#define ImageViewEdgeInsets             (UIEdgeInsetsMake(0, 0, 0, 0))

@interface SNBookMarkView ()

/**
 添加书签成功后，右上角的书签标记。
 */
@property (nonatomic, strong) UIImageView * bookMark;
@property (nonatomic, strong) UIImageView * imageView;
/**
 下拉添加书签的文字提示。
 */
@property (nonatomic, strong) UILabel * titleLabel;

/**
 处理业务逻辑的ViewModel
 */
@property (nonatomic, strong) SNBookMarkViewModel * viewModel;

@end

@implementation SNBookMarkView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.estimatedRowHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _markState = SNBookMarkStateIdle;
        [self initDelegate];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.backgroundColor = [UIColor redColor];
        self.backgroundView = self.imageView;
    }

    if (!self.bookMarkView) {
        self.bookMarkView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.bookMarkView.backgroundColor = [UIColor redColor];
        [self addSubview:self.bookMarkView];
    }
    
    if (!self.bookMark) {
        self.bookMark = [[UIImageView alloc] initWithFrame:CGRectMake(BookMarkLeftOffset, - 5, BookMarkWidth, BookMarkHeight)];
        self.bookMark.right = self.width - BookMarkRightOffset;
        self.bookMark.top = BookMarkTopOffset;
        [self.backgroundView addSubview:self.bookMark];
        if ([SNBookMarkViewModel isAddedBookMark:self.model]) {
            self.bookMark.image = [UIImage imageStoryNamed:@"icofiction_shuqianpress_v5.png"];
            _markState = SNBookMarkStateDidAdded;
        }else{
            self.bookMark.image = [UIImage imageStoryNamed:@"icofiction_shuqian_v5.png"];
            _markState = SNBookMarkStateIdle;
        }
    }
    
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(TitleLabelOriginX, TitleLabelOriginY, TitleLabelWidth, TitleLabelHeight)];
        
        if ([[UIDevice currentDevice]platformTypeForSohuNews] == UIDeviceiPhoneX) {
            self.titleLabel.right = self.width - TitleLabelLeftOffset;
            self.titleLabel.top = TitleLabelTopOffset + IPHONEXOriginY;
        } else {
            self.titleLabel.right = self.bookMark.left - TitleLabelLeftOffset;
            self.titleLabel.top = TitleLabelTopOffset;
        }
        
        self.titleLabel.text = kTextPullToAddBookMark;
        self.titleLabel.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
        self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.backgroundView addSubview:self.titleLabel];
        
    }
}

- (void)initDelegate {
    self.viewModel = [[SNBookMarkViewModel alloc] init];
    self.delegate = self.viewModel;
}

- (void)bookMarkBackGroundColor:(UIColor *)color imageName:(NSString *)imageName
{
    if (imageName && ![imageName isEqualToString:@""]) {
        self.imageView.image = [[UIImage imageNamed:imageName]resizableImageWithCapInsets:ImageViewEdgeInsets];
        self.bookMarkView.image = [[UIImage imageNamed:imageName]resizableImageWithCapInsets:ImageViewEdgeInsets];
    } else {
        self.imageView.image = nil;
        self.imageView.backgroundColor = color;
        self.bookMarkView.image = nil;
        self.bookMarkView.backgroundColor = color;
    }
}

- (void)updateTheme{
    self.titleLabel.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
    if ([SNBookMarkViewModel isAddedBookMark:self.model]) {
        self.bookMark.image = [UIImage imageStoryNamed:@"icofiction_shuqianpress_v5.png"];
    }else{
        self.bookMark.image = [UIImage imageStoryNamed:@"icofiction_shuqian_v5.png"];
    }

}

- (void)setBookMarkEnable:(BOOL)enable {
    self.scrollEnabled = enable;
}
    
- (void)contentOffsetDidChanged:(CGFloat)offsetY {

    CGFloat offset = -40.0f;
    if ([[UIDevice currentDevice]platformTypeForSohuNews] == UIDeviceiPhoneX) {
        offset = offset - 20;
    }
    
    if (offsetY < offset ) {
        if (_markState == SNBookMarkStateDidAdded) {
            self.titleLabel.text = kTextReleaseToCancelBookMark;
        }else{
            self.titleLabel.text = kTextReleaseToAddBookMark;
        }
    }else{
        if (_markState == SNBookMarkStateDidAdded) {
            self.titleLabel.text = kTextPullToCancelBookMark;
        }else{
            self.titleLabel.text = kTextPullToAddBookMark;
        }
    }

}

- (void)didEndDragging:(CGFloat)offsetY {
    
    CGFloat offset = -40.0f;
    if ([[UIDevice currentDevice]platformTypeForSohuNews] == UIDeviceiPhoneX) {
        offset = offset - 20;
    }
    
    if (offsetY < offset) {
        if (_markState == SNBookMarkStateDidAdded) {
            _markState = SNBookMarkStatePulling;
            [SNBookMarkViewModel cancelBookMark:self.model completed:^(BOOL success, id completedInfo) {
                if (success) {
                    _markState = SNBookMarkStateIdle;
                    [UIView animateWithDuration:0.25 animations:^{
                        self.bookMark.image = [UIImage imageStoryNamed:@"icofiction_shuqian_v5.png"];
                        [self.backgroundView addSubview:self.bookMark];

                    } completion:^(BOOL finished) {
                    }];
                }
            }];
            return;
        }else{
            _markState = SNBookMarkStatePulling;
            [SNBookMarkViewModel addBookMark:self.model completed:^(BOOL success, id completedInfo) {
                if (success) {
                    _markState = SNBookMarkStateDidAdded;
                    [UIView animateWithDuration:0.25 animations:^{
                        self.bookMark.image = [UIImage imageStoryNamed:@"icofiction_shuqianpress_v5.png"];
                        [self.superview addSubview:self.bookMark];

                    }];
                }
            }];
        }
    }
    
    if (self.bookMarkDelegate && [self.bookMarkDelegate respondsToSelector:@selector(bookMarkViewDidScroll:)]) {
        [self.bookMarkDelegate bookMarkViewDidScroll:offsetY];
    }
}

- (void)checkBookMark {
    if ([SNBookMarkViewModel isAddedBookMark:self.model]) {
        self.bookMark.image = [UIImage imageStoryNamed:@"icofiction_shuqianpress_v5.png"];
        _markState = SNBookMarkStateDidAdded;
        [self.superview addSubview:self.bookMark];
    }else{
        self.bookMark.image = [UIImage imageStoryNamed:@"icofiction_shuqian_v5.png"];
        _markState = SNBookMarkStateIdle;
        [self.backgroundView addSubview:self.bookMark];
    }
}

@end
