//
//  SNSelfCenterSearchCell.m
//  sohunews
//
//  Created by yangln on 14-9-28.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSelfCenterSearchCell.h"


@implementation SNSelfCenterSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, kAppScreenWidth-28, 35)];
        _bgImageView.layer.masksToBounds = YES;
        _bgImageView.layer.cornerRadius = 2;
        [self.contentView addSubview:_bgImageView];
        
        CGRect rect = CGRectMake(0, 0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
        
        _cellItemLabel = [[UILabel alloc] initWithFrame:rect];
        _cellItemLabel.left = 11;
        _cellItemLabel.backgroundColor = [UIColor clearColor];
        _cellItemLabel.font = [UIFont systemFontOfSize:13];
        _cellItemLabel.text = kRollingNewsSearchText;
        
        [_bgImageView addSubview:_cellItemLabel];
        UIImage *searchImage = [UIImage imageNamed:@"icopersonal_search_v5.png"];
        CGSize searchSize = searchImage.size;
        _cellItemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, searchSize.width, searchSize.height)];
        _cellItemImageView.top = (35-searchSize.height)/2;
        _cellItemImageView.right = _bgImageView.frame.size.width - 7;
        [_bgImageView addSubview:_cellItemImageView];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)setCellItem  {
    if (_cellItemImageView) {
        _cellItemImageView.image = nil;
    }
    _cellItemImageView.image = [UIImage imageNamed:@"icopersonal_search_v5.png"];
    
    _bgImageView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    _cellItemLabel.textColor = SNUICOLOR(kThemeText4Color);
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateTheme {
    [self setNeedsDisplay];
}

- (void)dealloc {
     //(_cellItemImageView);
     //(_cellItemLabel);
     //(_bgImageView);
    [SNNotificationManager removeObserver:self];
    
}

@end
