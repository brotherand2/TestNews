//
//  SNVideoChannelHotCategorySectionHeadView.h
//  sohunews
//
//  Created by jojo on 13-10-8.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SNVideoSectionHeadTypeCenterTitleWithOutLine,
    SNVideoSectionHeadTypeLeadingTitleWithLine
}SNVideoSectionHeadType;

@interface SNVideoChannelHotCategorySectionHeadView : UIView

+ (SNVideoChannelHotCategorySectionHeadView *)headViewWithTitle:(NSString *)title headType:(SNVideoSectionHeadType)headType;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SNVideoChannelHotCategorySectionHeadViewV2 : UIView {
    
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *infoString;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;

+ (SNVideoChannelHotCategorySectionHeadViewV2 *)headViewWithTitle:(NSString *)title infoString:(NSString *)infoStr;

@end
