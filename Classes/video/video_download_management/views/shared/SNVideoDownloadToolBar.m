//
//  SNVideoDownloadToolBar.m
//  sohunews
//
//  Created by handy wang on 6/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNVideoDownloadToolBar.h"

#define SELF_ACTIONBTN_WIDTH                                        (86/2.0f)
#define SELF_ACTIONBTN_HEIGHT                                       (86/2.0f)

@implementation SNVideoDownloadToolBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _hadSelectedAll = NO;
        
        self.opaque = NO;
        
        UIImage* bg = [UIImage imageNamed:@"postTab0.png"];
        _toolbarBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, bg.size.height)];
        _toolbarBackgroundImageView.image = bg;
        [self addSubview:_toolbarBackgroundImageView];
        
        UIImage* clearImage = [[UIImage alloc] initWithCGImage:nil];
        UIColor* color = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1];

        _selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectAllBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_selectAllBtn setTitleColor:color forState:UIControlStateNormal];
        [_selectAllBtn setTitleColor:color forState:UIControlStateHighlighted];
        [_selectAllBtn setBackgroundImage:clearImage forState:UIControlStateNormal];
        [_selectAllBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_left.png"] forState:UIControlStateNormal];
        [_selectAllBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_left_hl.png"] forState:UIControlStateHighlighted];
        [_selectAllBtn addTarget:self action:@selector(selectOrDeselectAll) forControlEvents:UIControlEventTouchUpInside];
        CGFloat btnWidth = (kAppScreenWidth - 52)/3;
        CGRect _selectAllBtnFrame = CGRectMake(26, 10.5, btnWidth, 33);
        _selectAllBtn.frame = _selectAllBtnFrame;
        [self addSubview:_selectAllBtn];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:color forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:clearImage forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_middle.png"] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_middle_hl.png"] forState:UIControlStateHighlighted];
        [_deleteBtn addTarget:self action:@selector(deleteSelected) forControlEvents:UIControlEventTouchUpInside];
        CGRect _deleteBtnFrame = CGRectMake(26+btnWidth, 10.5, btnWidth, 33);
        _deleteBtn.frame = _deleteBtnFrame;
        [self addSubview:_deleteBtn];
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize: 16.0];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:color forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:clearImage forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_right.png"] forState:UIControlStateNormal];
        [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_right_hl.png"] forState:UIControlStateHighlighted];
        [_cancelBtn addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
        CGRect _cancelBtnFrame = CGRectMake(26+2*btnWidth, 10.5, btnWidth, 33);
        _cancelBtn.frame = _cancelBtnFrame;
        [self addSubview:_cancelBtn];
        
        [SNNotificationManager addObserver: self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
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
    
     //(_toolbarBackgroundImageView);
    [SNNotificationManager removeObserver:self];
    
}

#pragma mark - Private methods implementation
- (void)selectOrDeselectAll {
    if (_hadSelectedAll) {
        [self deselectAll];
    }
    else {
        [self selectAll];
    }
}

- (void)setSelectAllButtonState:(BOOL) selectAll {
    if (selectAll) {
        [_selectAllBtn setTitle:@"取消全选" forState:UIControlStateNormal];
        [_selectAllBtn setTitle:@"取消全选" forState:UIControlStateHighlighted];
        _hadSelectedAll = YES;
    }
    else {
        [_selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
        [_selectAllBtn setTitle:@"全选" forState:UIControlStateHighlighted];
        _hadSelectedAll = NO;
    }
}

- (void)selectAll {
    [self setSelectAllButtonState:YES];
    
    if ([_delegate respondsToSelector:@selector(selectAll)]) {
        [_delegate selectAll];
    }
}

- (void)deselectAll {
    [self setSelectAllButtonState:NO];
    
    if ([_delegate respondsToSelector:@selector(deselectAll)]) {
        [_delegate deselectAll];
    }
}

- (void)deleteSelected {
    if ([_delegate respondsToSelector:@selector(deleteSelected)]) {
        [_delegate deleteSelected];
    }
}

- (void)cancelEdit {
    if ([_delegate respondsToSelector:@selector(cancelEdit)]) {
        [_delegate cancelEdit];
    }
}

- (void)updateTheme {
    UIColor* color = [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1];
    _toolbarBackgroundImageView.image = [UIImage imageNamed:@"postTab0.png"];
    
    [_selectAllBtn setTitleColor:color forState:UIControlStateNormal];
    [_selectAllBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_left.png"] forState:UIControlStateNormal];
    [_selectAllBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_left_hl.png"] forState:UIControlStateHighlighted];
    
    [_deleteBtn setTitleColor:color forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_middle.png"] forState:UIControlStateNormal];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_middle_hl.png"] forState:UIControlStateHighlighted];
    
    [_cancelBtn setTitleColor:color forState:UIControlStateNormal];
    [_cancelBtn setBackgroundImage:[UIImage imageNamed:@"downloaded_edit_right.png"] forState:UIControlStateNormal];
}

@end
