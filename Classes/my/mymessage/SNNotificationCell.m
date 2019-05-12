//
//  SNNotificationCell.m
//  sohunews
//
//  Created by weibin cheng on 13-6-27.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#define CELL_HEIGHT_MARGIN 13
#define CELL_WIDTH_MARGIN 13
#define CELL_HEAD_ICON_SIZE 32
#define CELL_TITLE_X 54
#define CELL_COTENT_Y 34
#define CELL_TITLE_FONT_SIZE 15
#define CELL_CONTENT_FONT_SIZE 12
#define CELL_TITLE_WIDTH (kAppScreenWidth - 130)
#define CELL_TIME_X (kAppScreenWidth - 74)
#define CELL_TIME_Y 20
#define CELL_TIME_WIDTH 60


#define kUpgradeIconTag 100
#define kUpgradeButtonTag 200
#define kBottomLineTag 300

#import "SNNotificationCell.h"
#import "SNConsts.h"
#import "UIColor+ColorUtils.h"

#import "SNNotificationModel.h"

@implementation SNNotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.exclusiveTouch = YES;
        self.backgroundColor = SNUICOLOR(kBackgroundColor);
        self.contentView.backgroundColor = SNUICOLOR(kBackgroundColor);
        _headImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH_MARGIN, CELL_HEIGHT_MARGIN, CELL_HEAD_ICON_SIZE, CELL_HEAD_ICON_SIZE)];
        _headImageView.showFade = YES;
        _headImageView.defaultImage = [UIImage themeImageNamed:@"login_user_defaultIcon.png"];
        //_headImageView.layer.cornerRadius = 3;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        _headImageView.alpha = themeImageAlphaValue();
        [self addSubview:_headImageView];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_TITLE_X, CELL_HEIGHT_MARGIN, CELL_TITLE_WIDTH, 16)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        //_titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kAuthorNameColor]];
        _titleLabel.font = [UIFont systemFontOfSize:CELL_TITLE_FONT_SIZE];
        [self addSubview:_titleLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_TITLE_X, CELL_COTENT_Y , CELL_TITLE_WIDTH, CELL_TITLE_FONT_SIZE)];
        _contentLabel.backgroundColor = [UIColor clearColor];
        //_contentLabel.lineBreakMode = UILineBreakModeClip;
        _contentLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorViewCommentContentColor]];
        _contentLabel.font = [UIFont systemFontOfSize:CELL_CONTENT_FONT_SIZE];
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_TIME_X , CELL_TIME_Y , CELL_TIME_WIDTH, 10)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.lineBreakMode = NSLineBreakByClipping;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorCommentDateColor]];
        _timeLabel.font = [UIFont systemFontOfSize:9];
        [self addSubview:_timeLabel];
        
        UIImageView* bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH_MARGIN, self.height-1, kAppScreenWidth-2*CELL_WIDTH_MARGIN, 1)];
        bottomLine.image = [UIImage themeImageNamed:@"weibo_detail_sepline.png"];
        bottomLine.tag = kBottomLineTag;
        [self addSubview:bottomLine];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
     //(_headImageView);
     //(_titleLabel);
     //(_contentLabel);
     //(_timeLabel);
    [SNNotificationManager removeObserver:self];
}
- (void)updateContent:(SNNotificationItem *)item
{
//    if(_headImageView.urlPath.length > 0)
//    {
//        [_headImageView unsetImage];
//        _headImageView.defaultImage = [UIImage themeImageNamed:@"login_user_defaultIcon.png"];
//    }
//    if(item.headUrl.length > 0)
//    {
//        _headImageView.urlPath = item.headUrl;
//    }
//     _headImageView.defaultImage = [UIImage themeImageNamed:@"login_user_defaultIcon.png"];
    self.backgroundColor = SNUICOLOR(kBackgroundColor);
    self.contentView.backgroundColor = SNUICOLOR(kBackgroundColor);
    self.bounds = CGRectMake(0, 0, self.width, item.height);
    if(![SNUtility getApplicationDelegate].shouldDownloadImagesManually)
    {
        _headImageView.urlPath = item.headUrl;
    }
    _titleLabel.text = item.nickName;
    _contentLabel.text = item.alert;
    _timeLabel.text = [NSDate relativelyDate:item.time];
    CGSize size = [item.alert sizeWithFont:[UIFont systemFontOfSize:CELL_CONTENT_FONT_SIZE]];
    int line = size.width / CELL_TITLE_WIDTH;
    if(((int)size.width) % (int)CELL_TITLE_WIDTH != 0)
    {
        ++line;
    }
    _contentLabel.frame = CGRectMake(CELL_TITLE_X, CELL_COTENT_Y , CELL_TITLE_WIDTH, CELL_TITLE_FONT_SIZE*line);
    UIImageView* bottomLine = (UIImageView*)[self viewWithTag:kBottomLineTag];
    bottomLine.frame = CGRectMake(CELL_WIDTH_MARGIN, self.height-1, kAppScreenWidth-2*CELL_WIDTH_MARGIN, 1);
    bottomLine.image = [UIImage themeImageNamed:@"weibo_detail_sepline.png"];
}

- (void)updateTheme
{
    _headImageView.alpha = themeImageAlphaValue();
    _titleLabel.textColor = SNUICOLOR(kAuthorNameColor);
    _contentLabel.textColor = SNUICOLOR(kFloorViewCommentContentColor);
    _timeLabel.textColor = SNUICOLOR(kFloorCommentDateColor);
    UIImageView* bottomLine = (UIImageView*)[self viewWithTag:kBottomLineTag];
    bottomLine.image = [UIImage themeImageNamed:@"weibo_detail_sepline.png"];
}

- (void)cancelAllImageLoading
{
    if(_headImageView.urlPath.length > 0)
    {
        [_headImageView unsetImage];
    }
}
/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self showSelectedBg:selected];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self showSelectedBg:highlighted];
}

- (void)showSelectedBg:(BOOL)show
{
    if (show) {
        if (!_cellSelectedBg) {
            _cellSelectedBg = [[UIImageView alloc] init];
            [self insertSubview:_cellSelectedBg atIndex:0];
        }
        _cellSelectedBg.frame = self.bounds;
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
        _cellSelectedBg.alpha = 1;
    }
    else
    {
        if (_cellSelectedBg.alpha > 0) {
            [UIView beginAnimations:nil context:nil];
            _cellSelectedBg.alpha = 0;
            [UIView commitAnimations];
        }
    }
}*/
@end


@implementation SNNotificationUpgradeCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.exclusiveTouch = YES;
        self.backgroundColor = SNUICOLOR(kBackgroundColor);
        self.contentView.backgroundColor = SNUICOLOR(kBackgroundColor);
        UIImage* image = [UIImage themeImageNamed:@"notification_rocket.png"];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = kUpgradeIconTag;
        imageView.frame = CGRectMake(CELL_WIDTH_MARGIN, CELL_HEIGHT_MARGIN, CELL_HEAD_ICON_SIZE, CELL_HEAD_ICON_SIZE);
        [self addSubview:imageView];
        imageView.alpha = 1;
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_TITLE_X, CELL_HEIGHT_MARGIN, CELL_TITLE_WIDTH, 16)];
        titleLabel.backgroundColor = [UIColor clearColor];
        //titleLabel.lineBreakMode = UILineBreakModeClip;
        titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorViewCommentContentColor]];
        titleLabel.font = [UIFont systemFontOfSize:CELL_TITLE_FONT_SIZE];
        titleLabel.text = @"赶紧升级吧";
        [self addSubview:titleLabel];
        
        UILabel* contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_TITLE_X, CELL_COTENT_Y , CELL_TITLE_WIDTH, CELL_TITLE_FONT_SIZE)];
        contentLabel.backgroundColor = [UIColor clearColor];
        //contentLabel.lineBreakMode = UILineBreakModeClip;
        contentLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorViewCommentContentColor]];
        contentLabel.font = [UIFont systemFontOfSize:CELL_CONTENT_FONT_SIZE];
        contentLabel.text = @"当前版本不支持此类型通知";
        [self addSubview:contentLabel];
        
        image = [UIImage themeImageNamed:@"notification_upgrade.png"];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = kUpgradeButtonTag;
        button.alpha = 1;
        button.frame = CGRectMake(265, 18, image.size.width, image.size.height);
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickUpgrade) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        UIImageView* bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH_MARGIN, 57, kAppScreenWidth-2*CELL_WIDTH_MARGIN, 1)];
        bottomLine.image = [UIImage imageNamed:@"weibo_detail_sepline.png"];
        [self addSubview:bottomLine];
    }
    return self;
}
- (void)updateTheme
{
    UIImageView* iconView = (UIImageView*)[self viewWithTag:kUpgradeIconTag];
    iconView.alpha = 1;
    
    UIButton* button = (UIButton*)[self viewWithTag:kUpgradeButtonTag];
    [button setImage:[UIImage themeImageNamed:@"notification_upgrade.png"] forState:UIControlStateNormal];
}
-(void)clickUpgrade
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:FixedUrl_AppStore_Sohunews]];
}
@end

@implementation SNSimpleNotificationCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.exclusiveTouch = YES;
        self.backgroundColor = SNUICOLOR(kBackgroundColor);
        self.contentView.backgroundColor = SNUICOLOR(kBackgroundColor);
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_WIDTH_MARGIN, 12 , kAppScreenWidth - 85, 34)];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorViewCommentContentColor]];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 2;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_contentLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_TIME_X , CELL_TIME_Y , CELL_TIME_WIDTH, 10)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.lineBreakMode = NSLineBreakByClipping;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kFloorCommentDateColor]];
        _timeLabel.font = [UIFont systemFontOfSize:9];
        [self addSubview:_timeLabel];
        
        UIImageView* bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_WIDTH_MARGIN, 57, kAppScreenWidth-2*CELL_WIDTH_MARGIN, 1)];
        bottomLine.image = [UIImage imageNamed:@"weibo_detail_sepline.png"];
        bottomLine.tag = kBottomLineTag;
        [self addSubview:bottomLine];
    }
    return self;
}

-(void)dealloc
{
     //(_contentLabel);
     //(_timeLabel);
}

-(void)updateContent:(SNNotificationItem *)item
{
    _contentLabel.text = item.alert;
    _timeLabel.text = [NSDate relativelyDate:item.time];
    
    UIImageView* bottomLine = (UIImageView*)[self viewWithTag:kBottomLineTag];
    bottomLine.frame = CGRectMake(CELL_WIDTH_MARGIN, 57, kAppScreenWidth-2*CELL_WIDTH_MARGIN, 1);
    bottomLine.image = [UIImage themeImageNamed:@"weibo_detail_sepline.png"];
}
@end
