//
//  SNDownloadingSectionHeaderView.h
//  sohunews
//
//  Created by handy wang on 1/16/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNDownloadingSectionHeaderViewDelegate
- (void)foldAtSectionTag:(NSString *)sectionTag;
- (void)unfoldAtSectionTag:(NSString *)sectionTag;
@end

@interface SNDownloadingSectionHeaderView : UIView {
    id _delegate;
    NSString *_sectionTag;
}
- (id)initWithFrame:(CGRect)frame icon:(NSString *)iconImageName title:(NSString *)title sectionTag:(NSString *)sectionTag
      seperatorLine:(BOOL)showSeparatorLine delegate:(id)delegateParam;
- (void)updateProgres:(CGFloat)progress;
- (void)resetProgress;
@end