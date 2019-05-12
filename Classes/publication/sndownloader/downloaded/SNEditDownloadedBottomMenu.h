//
//  SNEditDownloadedBottomMenu.h
//  sohunews
//
//  Created by handy wang on 6/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNEditDownloadedBottomMenuDelegate

- (void)selectAll;

- (void)deleteSelected;
    
@end


@interface SNEditDownloadedBottomMenu : UIView {
    id _delegate;
    
    UIButton *_selectAllBtn;
    UIButton *_deleteBtn;
    UIButton *_cancelBtn;
    UIImageView* _bgView;
    
    BOOL _hadSelectedAll;
}

- (id)initWithFrame:(CGRect)frame  andDelgate:(id)delegateParam;

- (void)deselectAll;
- (void)selectAll;
- (void)setSelectAllButtonState:(BOOL) selectAll;
- (void)updateTheme;

@end