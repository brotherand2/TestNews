//
//  SNMoreCellWithIndicatorOnly.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingCellWithIndicatorOnly.h"

@implementation SNSettingCellWithIndicatorOnly

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        UIImage *imgArrow = [UIImage themeImageNamed:@"arrow.png"];
        _indicatorView = [[UIImageView alloc] initWithImage:imgArrow];
        if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
            _indicatorView.frame = CGRectMake(285, (kMoreViewCellHeight - imgArrow.size.height) / 2, imgArrow.size.width, imgArrow.size.height);
        else
            _indicatorView.frame = CGRectMake(kAppScreenWidth-20, (kMoreViewCellHeight - imgArrow.size.height) / 2, imgArrow.size.width, imgArrow.size.height);
        [self.contentView addSubview:_indicatorView];
    }
    return self;
}

- (void)dealloc {
     //(_indicatorView);
}

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    _indicatorView.image = [UIImage themeImageNamed:@"arrow.png"];
}

- (void)showSelectedBg:(BOOL)show{
    
    if (show) {
        _indicatorView.image = [UIImage themeImageNamed:@"arrow_hl.png"];
        _bgImageView.alpha = 1;
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationWillStartSelector:@selector(changeArrow)];
        [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
        _bgImageView.alpha = 0;
        [UIView commitAnimations];
    }
}

- (void)changeArrow{
    _indicatorView.image = [UIImage themeImageNamed:@"arrow.png"];
}

@end
