//
//  SNTableViewCell.m
//  sohunews
//
//  Created by Gao Yongyue on 13-9-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"
#import "NSCellLayout.h"

@interface SNTableViewCell ()
{
    UIView   *lineView;//收藏添加线
}
@end

@implementation SNTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //by 5.9.4 wangchuanwen add
        //cell分割线
        lineView = [[UIView alloc]initWithFrame:CGRectMake(CONTENT_LEFT, 0, kAppScreenWidth - 2*CONTENT_LEFT, 0.5)];
        lineView.backgroundColor = SNUICOLOR(kThemeBg6Color);
        lineView.hidden = YES;
        [self addSubview:lineView];
        //add end
        
        [SNNotificationManager addObserver:self
                                  selector:@selector(updateTheme)
                                      name:kThemeDidChangeNotification
                                    object:nil];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateTheme {
    [_selectButton setBackgroundImage:[UIImage imageNamed:@"icostock_unselect_v5.png"] forState:UIControlStateNormal];
    [_selectButton setBackgroundImage:[UIImage imageNamed:@"icostock_select_v5.png"] forState:UIControlStateSelected];
    
    //by 5.9.4 wangchuanwen add
    if (!lineView.hidden) {
        lineView.backgroundColor = SNUICOLOR(kThemeBg6Color);
    }
    //modify end
}

- (void)initSelectButton {
    _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectButton.frame = CGRectMake(0, 0, kSelectButtonWidth, kSelectButtonWidth);
    [_selectButton setBackgroundImage:[UIImage imageNamed:@"icostock_unselect_v5.png"] forState:UIControlStateNormal];
    [_selectButton setBackgroundImage:[UIImage imageNamed:@"icostock_select_v5.png"] forState:UIControlStateSelected];
    _selectButton.selected = NO;
    _selectButton.centerY = self.centerY;
    _selectButton.right = 0;
    _selectButton.userInteractionEnabled = NO;
    [self addSubview:_selectButton];
}

- (void)setEditMode{
}

- (void)setNormalMode {
}

-(void)setLineTop:(CGFloat)top hidden:(BOOL)hidden;
{
    lineView.top = top;
    lineView.hidden = hidden;
    [self bringSubviewToFront:lineView];
}

@end
