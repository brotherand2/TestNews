//
//  SNMoreViewBaseCell.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingBaseCell.h"
#import "SNUserManager.h"
#import "SNNewsReport.h"
@implementation SNSettingBaseCell
@synthesize cellData = _cellData;
@synthesize cellBgType = _bgType;
@synthesize bgImageName = _bgImageName;
@synthesize viewController = _viewController;
@synthesize selectable = _selectable;

- (void)dealloc {
     //(_cellData);
     //(_bgImageView);
     //(_bgImageName);
     //(_newMark);
     //(_titleLabel);
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.alpha = 0;
        [self.contentView addSubview:_bgImageView];
//        self.textLabel.backgroundColor = [UIColor clearColor];
//        self.textLabel.font = [UIFont systemFontOfSize:16.0f];
        self.textLabel.hidden = YES;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 240, self.height)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.numberOfLines = 1;
        [self.contentView addSubview:_titleLabel];
        _newMark = [[SNBubbleTipView alloc] initWithType:SNTableBubbleType];
        _newMark.alignType = SNBubbleAlignRight;
        _newMark.frame = CGRectMake(35, 3, _newMark.defaultWidth, _newMark.defaultHeight);
        [self.contentView addSubview:_newMark];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.left = 20;
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
        _bgImageView.frame = CGRectMake(0, 0, 300, self.contentView.height);
    else
        _bgImageView.frame = CGRectMake(0, 0, kAppScreenWidth, self.contentView.height);
    
    _titleLabel.height = self.contentView.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
    if (_selectable) {
        _bgImageView.image = [self.bgImageName length] > 0 ? [UIImage themeImageNamed:self.bgImageName] : nil;
        [self showSelectedBg:selected];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {

//    [self setSelected:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
    } else {
        self.backgroundColor = SNUICOLOR(kThemeBg3Color);
    }
}

- (void)showSelectedBg:(BOOL)show {
    if (show) {
        _bgImageView.alpha = 1;
    }
    else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
        _bgImageView.alpha = 0;
        [UIView commitAnimations];
    }
}

- (void)setCellBgType:(SNMoreCellBgType)cellBgType {
    _bgType = cellBgType;
    
    switch (_bgType) {
        case SNMoreCellBgTypeTop:
            self.bgImageName = @"topCell.png";
            break;
        case SNMoreCellBgTypeMiddle:
            self.bgImageName = @"middleCell.png";
            break;
        case SNMoreCellBgTypeBottom:
            self.bgImageName = @"bottomCell.png";
            break;
        case SNMoreCellBgTypeSingle:
            self.bgImageName = @"singleCell.png";
            break;
            
        default:
            self.bgImageName = nil;
            break;
    }
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        self.bgImageName = @"cell-press.png";
        
}

- (void)setCellData:(NSDictionary *)cellData {
     //(_cellData);
    _cellData = cellData;
    //by 5.9.4 wangchuanwen modify
    //_titleLabel.textColor= SNUICOLOR(kThemeText10Color);
    _titleLabel.textColor= SNUICOLOR(kThemeTextRIColor);
    //modify end
    _titleLabel.text = [_cellData stringValueForKey:kMoreViewCellDicKeyTitle
                                          defaultValue:@""];
    
    NSString *selectorStr = [_cellData stringValueForKey:kMoreViewCellDicKeySelector defaultValue:@""];
    self.selectable = [selectorStr length] > 0;

}

- (void)setSelectable:(BOOL)selectable
{
    _selectable = selectable;
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") && !_selectable)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        
}
- (void)setTipCount:(int)count
{
    if (count > 0) {
        count = -1;
    }
    [_newMark setTipCount:count];
}
@end

@implementation SNSettingViewController (openUrl)

- (void)kickOpenUrl:(SNSettingBaseCell *)cell {
    NSDictionary *dic = cell.cellData;
    NSString *url = [dic stringValueForKey:kMoreViewCellDicKeyOpenUrl defaultValue:@""];
    if ([url length] > 0) {
        //免责声明
        if ([url isEqualToString:@"tt://m_statement"]) {
            Reachability *reachability = [((sohunewsAppDelegate *)[UIApplication sharedApplication].delegate) getInternetReachability];
            NetworkStatus currentNetStatus = [reachability currentReachabilityStatus];
            //无网时显示Native文案
            if (currentNetStatus == NotReachable) {
                TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
                [[TTNavigator navigator] openURLAction:action];
            }
            //有网时显示H5文案
            else {
                if([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight])
                    [SNUtility openProtocolUrl:[SNUtility addParamModeToURL:kH5StatementURL]];
                else
                    [SNUtility openProtocolUrl:kH5StatementURL];
            }
        }
        //其它
        else {
            if (PushSettingSwith) {
                if ([url isEqualToString:@"tt://pushSeting"]) {
                    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"kPushAction"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [SNNewsReport reportADotGif:@"_act=pushsetting&_tp=pv"];
                    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://pushSeting"] applyAnimated:YES] applyQuery:dic];
                    [[TTNavigator navigator] openURLAction:urlAction];
                }else{
                    TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
                    [[TTNavigator navigator] openURLAction:action];
                }
            }else{
                if ([url isEqualToString:@"tt://pushSeting"]) {
                    [SNNewsReport reportADotGif:@"_act=pushsetting&_tp=pv"];
                }
                TTURLAction *action = [[TTURLAction actionWithURLPath:url] applyAnimated:YES];
                [[TTNavigator navigator] openURLAction:action];
            }
        }
    }
}

- (void)kickOpenMoreApp:(SNSettingBaseCell *)cell{
    NSString *urlStr = kUrlMoreApp;
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        urlStr = [urlStr stringByAppendingString:@"&mode=1"];
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"moreApp", @""), @"title", urlStr, @"url", nil];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://m_moreApp"] applyAnimated:YES] applyQuery:dict];
    [[TTNavigator navigator] openURLAction:urlAction];
}

@end
