//
//  SNUserinfoMediaObject.h
//  sohunews
//
//  Created by weibin cheng on 13-8-1.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNWebImageView.h"
#import "SNBadgeView.h"

#define kUserinfoMediaCellHeight 60

@interface SNUserinfoMediaObject : NSObject
@property (nonatomic, strong) NSString* iconUrl;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* count;
@property (nonatomic, strong) NSString* link;
@property (nonatomic, strong) NSString* mediaLink;
@property (nonatomic, strong) NSString* subId;
@property (nonatomic, strong) NSArray* subTypeIcon;
@end



@interface SNUserinfoMediaCell : UITableViewCell<SNBadgeViewDelegate>
{
    UIImageView* _cellSelectedBg;
    SNWebImageView* _headImageView;
    UILabel* _nameLabel;
    UILabel* _contentLabel;
    SNBadgeView* _badgeView;
}

@property (nonatomic, strong) SNUserinfoMediaObject* mediaObject;
-(void)setMediaObject:(SNUserinfoMediaObject*)object showSeperateLine:(BOOL)show;

@end
