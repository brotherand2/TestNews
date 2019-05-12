//
//  SNEditDownloadedBottomMenu.m
//  sohunews
//
//  Created by handy wang on 6/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNEditDownloadedBottomMenu.h"

#define SELF_ACTIONBTN_WIDTH                                        (86/2.0f)
#define SELF_ACTIONBTN_HEIGHT                                       (86/2.0f)


@interface SNEditDownloadedBottomMenu()

- (void)selectOrDeselectAll;

- (void)selectAll;

- (void)deselectAll;

@end


@implementation SNEditDownloadedBottomMenu

- (id)initWithFrame:(CGRect)frame  andDelgate:(id)delegateParam {
    self = [super initWithFrame:frame];
    if (self) {
        _hadSelectedAll = NO;
        
        _delegate = delegateParam;

        self.opaque = NO;
        
        UIImage* bg = [UIImage imageNamed:@"postTab0.png"];
        _bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, bg.size.height)];
        _bgView.image = bg;
        [self addSubview:_bgView];
        
        UIImage* clearImage = [[UIImage alloc] initWithCGImage:nil];
        UIColor* color = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1];
        NSString *_selectallPressImageName = @"downloaded_edit_left.png";
        NSString *_selectallPressImageNameHl = @"downloaded_edit_left_hl.png";
        _selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectAllBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_selectAllBtn setTitleColor:color forState:UIControlStateNormal];
        [_selectAllBtn setTitleColor:color forState:UIControlStateHighlighted];
        [_selectAllBtn setBackgroundImage:clearImage forState:UIControlStateNormal];
        [_selectAllBtn setBackgroundImage:[UIImage imageNamed:_selectallPressImageName] forState:UIControlStateNormal];
        [_selectAllBtn setBackgroundImage:[UIImage imageNamed:_selectallPressImageNameHl] forState:UIControlStateHighlighted];
        [_selectAllBtn addTarget:self action:@selector(selectOrDeselectAll) forControlEvents:UIControlEventTouchUpInside];
        CGFloat btnWidth = (kAppScreenWidth - 52)/3;
        CGRect _selectAllBtnFrame = CGRectMake(26, 10.5, btnWidth, 33);
        _selectAllBtn.frame = _selectAllBtnFrame;
        [self addSubview:_selectAllBtn];
        
        NSString *_deletebtnPressImageName = @"downloaded_edit_middle.png";
        NSString *_deletebtnPressImageNameHl = @"downloaded_edit_middle_hl.png";
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:color forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:clearImage forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:_deletebtnPressImageName] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:_deletebtnPressImageNameHl] forState:UIControlStateHighlighted];
        [_deleteBtn addTarget:_delegate action:@selector(deleteSelected) forControlEvents:UIControlEventTouchUpInside];
        CGRect _deleteBtnFrame = CGRectMake(26+btnWidth, 10.5, btnWidth, 33);
        _deleteBtn.frame = _deleteBtnFrame;
        [self addSubview:_deleteBtn];
        
        NSString *_btnImgName = @"downloaded_edit_right.png";
        NSString *_btnImgNameHl = @"downloaded_edit_right_hl.png";
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:color forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:clearImage forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:_btnImgName] forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:_btnImgNameHl] forState:UIControlStateHighlighted];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [_cancelBtn addTarget:_delegate action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
        CGRect _cancelBtnFrame = CGRectMake(26+2*btnWidth, 10.5, btnWidth, 33);
        _cancelBtn.frame = _cancelBtnFrame;
        [self addSubview:_cancelBtn];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect _selfBounds = self.bounds;
    CGRect _selectAllHotArea = CGRectMake(0, 0, _selfBounds.size.width/3.0f, _selfBounds.size.height);
    CGRect _deleteAllHotArea = CGRectMake(_selfBounds.size.width/3.0f, 0, _selfBounds.size.width/3.0f, _selfBounds.size.height);
    
	if (CGRectContainsPoint(_selectAllHotArea, point)) {
		return _selectAllBtn;
	}
    else if (CGRectContainsPoint(_deleteAllHotArea, point)) {
        return _deleteBtn;
    }
	else {
        return [super hitTest:point withEvent:event];
    }
}

- (void)dealloc {
    _selectAllBtn = nil;
    
    _deleteBtn = nil;
    
    _cancelBtn = nil;
    
    [SNNotificationManager removeObserver:self];
    
}

#pragma mark - Private methods implementation

- (void)selectOrDeselectAll {

    if (_hadSelectedAll) {
    
        [self deselectAll];
        
    } else {
    
        [self selectAll];
    
    }
    
    
}

- (void)setSelectAllButtonState:(BOOL) selectAll
{
    if (selectAll) {
        
        [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_selectAllBtn setTitle:@"全选" forState:UIControlStateHighlighted];
        _hadSelectedAll = NO;
    } else {
        
        [_selectAllBtn setTitle:@"取消全选" forState:UIControlStateNormal];
        [_selectAllBtn setTitle:@"取消全选" forState:UIControlStateHighlighted];
        _hadSelectedAll = YES;
    }
}

- (void)selectAll {

    if ([_delegate respondsToSelector:@selector(selectAll)]) {
        
        [self setSelectAllButtonState:NO];
        
        [_delegate selectAll];
        
    }
    
}

- (void)deselectAll {

    if ([_delegate respondsToSelector:@selector(deselectAll)]) {
        
        [self setSelectAllButtonState:YES];
        [_delegate deselectAll];
        
    }
    
}

- (void)updateTheme
{
    UIImage* bg = [UIImage imageNamed:@"postTab0.png"];
    [_bgView setImage:bg];
    
    UIColor* color = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1];
    NSString *_selectallPressImageName = @"downloaded_edit_left.png";
    NSString *_selectallPressImageNameHl = @"downloaded_edit_left_hl.png";
    [_selectAllBtn setTitleColor:color forState:UIControlStateNormal];
    [_selectAllBtn setTitleColor:color forState:UIControlStateHighlighted];
    [_selectAllBtn setBackgroundImage:[UIImage imageNamed:_selectallPressImageName] forState:UIControlStateNormal];
    [_selectAllBtn setBackgroundImage:[UIImage imageNamed:_selectallPressImageNameHl] forState:UIControlStateHighlighted];
    
    NSString *_deletebtnPressImageName = @"downloaded_edit_middle.png";
    NSString *_deletebtnPressImageNameHl = @"downloaded_edit_middle_hl.png";
    [_deleteBtn setTitleColor:color forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:_deletebtnPressImageName] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:_deletebtnPressImageNameHl] forState:UIControlStateHighlighted];
    
    NSString *_btnImgName = @"downloaded_edit_right.png";
    NSString *_btnImgNameHl = @"downloaded_edit_right_hl.png";
    [_cancelBtn setTitleColor:color forState:UIControlStateNormal];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:_btnImgName] forState:UIControlStateNormal];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:_btnImgNameHl] forState:UIControlStateHighlighted];
}

@end
