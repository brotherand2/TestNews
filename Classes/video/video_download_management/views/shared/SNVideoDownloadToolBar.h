//
//  SNVideoDownloadToolBar.h
//  sohunews
//
//  Created by handy wang on 6/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNVideoDownloadToolBarDelegate
- (void)selectAll;
- (void)deselectAll;
- (void)deleteSelected;
- (void)cancelEdit;
@end

@interface SNVideoDownloadToolBar : UIView {
    UIButton *_selectAllBtn;
    UIButton *_deleteBtn;
    UIButton *_cancelBtn;
    
    BOOL _hadSelectedAll;
    UIImageView *_toolbarBackgroundImageView;
}
@property (nonatomic, weak)id delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)deselectAll;
- (void)setSelectAllButtonState:(BOOL) selectAll;
@end
