//
//  SNChannelManageContants.h
//  sohunews
//
//  Created by jojo on 13-10-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#ifndef sohunews_SNChannelManageContants_h
#define sohunews_SNChannelManageContants_h

///////////////////////////////////////////////////
// configure
///////////////////////////////////////////////////
#define kChannelMininumChannelCount                             (4)
#define kChannelMaxRowCount                                     (4)
#define kChannelMaxVolum                                        (10000)
#define kChannelMaxNum                                          (10000)

///////////////////////////////////////////////////
// time duration
///////////////////////////////////////////////////
#define kSNChannelManageViewV2AnimationDuration                 (0.4)
#define kSNChannelManageViewMovingAnimationDuration             (0.5)
#define kSNChannelViewMovingToSwitchAnimationDuration           (0.5)

#define kSNChannelViewActiveTimeInterval                        (0.008)
#define kDelayDuration                                          (0.3)

///////////////////////////////////////////////////
// channel view
///////////////////////////////////////////////////
#define kChannelViewExpandingScale      (kThemeFontSizeF/kThemeFontSizeD)
#define kChannelViewWidth               (154 / 2)
#define kChannelViewHeight              (66 / 2)
#define kChannelViewTextFont            (24 / 2)

#define kDeleteButtonWidth              (36 / 2)
#define kDeleteButtonHeight             (36 / 2)

///////////////////////////////////////////////////
// channel manage view
///////////////////////////////////////////////////
#define kChannelSectionViewHeight           (80 / 2)
#define kChannelSwitchViewTop               (100 / 4 +9)
#define kChannelSwitchViewLeft              (110 / 2)
#define kChannelSwithViewWidth              (420 / 2)
#define kChannelSwithViewHeight             (60 / 2)

#define kChannelSectionViewTextSideMargin   (20 / 2)
#define kChannelSectionViewTextFont         (24 / 2)

#define kChannelSectionViewInfoTextFont     (24 / 2)
#define kChannelEmptyHeight                 (100 / 2)

/*5.2 add*/
#define kChannelTitleWidth             ((kAppScreenWidth == 320.0) ? 140.0/2 : (kAppScreenWidth == 375.0) ? 166.0/2 : 274.0/3)
#define kChannelTitleHeight             ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 66.0/2 : 120.0/3)
#define kChannelTitleBackgroundWidth ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? (96.0/kChannelViewExpandingScale) : (106.0/kChannelViewExpandingScale))
#define kChannelTitleBackgroundHeight ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? (37/kChannelViewExpandingScale) : 122.0/(3*kChannelViewExpandingScale))
#define kChannelTitleBackgroundOriginX (kChannelTitleWidth - kChannelTitleBackgroundWidth)/2
#define kChannelTitleBackgroundOriginY (kChannelTitleHeight - kChannelTitleBackgroundHeight)/2

#define kAnimationImageViewDuration (0.8)
#define kAnimationImageViewWidth ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 42.0/2 : 63.0/3)
#define kIcoNormalSettingCloseButtonWidth ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 49.0 : 147.0/3)
#define kIcoNormalSettingCloseButtonHeight ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 44.0 : 132.0/3)
#define kIcoNormalSettingCloseButtonTopDistance (44.0-kAnimationImageViewWidth)/2
#define kIcoNormalSettingCloseButtonRightDistance ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 14.0 : 30.0/3)   // 由于动画本身距离右边有一个10的间距，所以这里的实际值应该是 (42 - 8.5) / 3） comment by cae

#define kIcoNormalSettingLeft ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0) ? 14.0 : 42.0/3)
#define kChannelAreaLeftDistance ((kAppScreenWidth > 375.0) ? 42.0/3 : ((kAppScreenWidth == 320.0) ? 10.0 : 28.0/2))
#define kIcoNormalSettingSearchIconRightDistance ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 4.0 : 20.0/3)
#define kIconNormalSettingMyChannelTextTopDistance ((kAppScreenWidth == 320.0) ? 20.0 : ((kAppScreenWidth == 375.0) ? 18.0 : 70.0/3))
#define kIconNormalSettingMyChannelTextBellowDistance ((kAppScreenWidth == 320.0) ? 13.0 : ((kAppScreenWidth == 375.0) ? 10.0 : 50.0/3 - 11))

#define kStaticMyChannelTextFont ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? kThemeFontSizeC : kThemeFontSizeG)

#define kHorizenDistanceBetweenChannels ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? (kAppScreenWidth - kChannelTitleWidth*4 - kChannelAreaLeftDistance*2)/3.0 : (kAppScreenWidth - kChannelTitleWidth*4 - kChannelAreaLeftDistance*2)/3.0)
#define kVerticalDistanceBetweenChannels ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 18.0/2 : 27.0/3)

#define kChannelEditTabBarAlpha (0.95)
#define kChannelEditTabBarButtonWidth ((kAppScreenWidth == 320.0) ? (kAppScreenWidth/4) : ((kAppScreenWidth == 375.0) ? 94.0 : 310.0/3))
#define kChannelEditImageTopDistance ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 8.0 : 30.0/3)
#define kChannelEditBetweenImageAndLabelDistance ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 6.0 : 22.0/3)

#define kMoreItemAnimationDuration (0.2)
#define kMoreItemViewWidth ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 264.0 : 292.0)
#define kMoreItemViewHeight ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 152.0 : 504.0/3)
#define kMoreItemViewRight ((kAppScreenWidth == 320.0) ? 55.0/2 : ((kAppScreenWidth == 375.0) ? 69.0/2 : 115.0/3))
#define kMoreItemViewBottom ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 27.0 : 30.0)
#define kMoreItemImageWidth ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 25.0 : 80.0/3)
#define kMoreItemCount 4
#define kItemLineCount 3
#define kItemButtonWidth ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 176.0/2 : 292.0/3)
#define kItemButtonHeight ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 152.0/2 : 252.0/3)
#define kItemBetweenImageAndLabelDistance ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 19.0/2 : 34.0/3)
#define kItemImageTopDistance ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 14.0 : 48.0/3)
#define kItemImageLeftDistance ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 63.0/2 : 106.0/3)

#define kEmptyChannelSmileImageWidth ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 42.0/2 : 63.0/3)
#define kEmptyChannelImageViewTop ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 122.0/2 : 184.0/3)
#define kEmptyChannelImageViewBellow ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 28.0/2 : 42.0/3)
#define kEmptyChannelLabelBellow ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 88.0/2 : 126.0/3)
#define kEmptyChannelViewHeight (kEmptyChannelImageViewTop + kEmptyChannelSmileImageWidth + kEmptyChannelImageViewBellow + kStaticMyChannelTextFont + kEmptyChannelLabelBellow + 2)

/*end*/

///////////////////////////////////////////////////
// notifications
///////////////////////////////////////////////////

#endif
