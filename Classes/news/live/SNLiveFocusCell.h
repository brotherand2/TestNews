//
//  SNLiveFocusCell.h
//  sohunews
//
//  Created by yanchen wang on 12-6-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveFocusTableItem.h"
#import "SNRollingNewsOnePicHeadlineCell.h"

@interface SNLiveFocusCell : SNRollingNewsOnePicHeadlineCell {
    SNLiveFocusTableItem *_liveItem;
    UIImageView *_liveStatusIcon;
}

@property(nonatomic, strong)SNLiveFocusTableItem *liveItem;

@end
