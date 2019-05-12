//
//  SNLiveStatisticTeamInfoView.h
//  sohunews
//
//  Created by wang yanchen on 13-4-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNLabel.h"
#import "SNLiveStatisticModel.h"

void drawTextVerticalCenter(CGRect rect, NSString *text, UIFont *font, UILineBreakMode lineBreak, UITextAlignment alignment);

@class SNLiveStatisticScoreBoard;
@interface SNLiveStatisticTeamInfoView : UIView<UIScrollViewDelegate> {
    SNLabel *_titleLabel;
    UIScrollView *_rightScrollView;
    SNLiveStatisticScoreBoard *_scoreBoard;
    
    UIImageView *_rightShadowView;
}

@property(nonatomic, strong) SNLiveStatisticModel *liveModel;

@end
