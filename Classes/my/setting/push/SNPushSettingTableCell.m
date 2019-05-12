//
//  SNPushSettingTableCell.m
//  sohunews
//
//  Created by Dan on 8/10/11.
//  update by sampanli
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPushSettingTableCell.h"
#import "SNPushSettingTableItem.h"
#import "SNPushSettingModel.h"
#import "UIColor+ColorUtils.h"
#import "SNBookShelf.h"
#import "SNUserSettingRequest.h"


#define kMoreViewCellHeight             (41)
#define CELL_HEIGHT 45

@implementation SNPushSettingTableCell
@synthesize item=_item;
@synthesize switcher=_switcher,nameLabel=_nameLabel,indicatorView = _indicatorView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self)
    {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        //5.9.3 wangchuanwen update
        //self.backgroundColor = [UIColor  clearColor];
        //换成abTest背景色 5.9.3 by wangchuanwen
        self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        float yPos = (CELL_HEIGHT-18.0f)/2;
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, yPos, 215, 18)];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        [self.contentView addSubview:_nameLabel];
        
        yPos = (CELL_HEIGHT-kPushSettingSwitcherHeight)/2;
        _switcher = [[SNMoreSwitcher alloc]initWithFrame:CGRectMake(kAppScreenWidth-85, yPos, kPushSettingSwitcherWidth, kPushSettingSwitcherHeight)];
        [self.contentView addSubview:_switcher];
        _switcher.delegate=self;
        
        UIImage *imgArrow = [UIImage themeImageNamed:@"arrow.png"];
        _indicatorView = [[UIImageView alloc] initWithImage:imgArrow];
        _indicatorView.frame = CGRectMake(kAppScreenWidth-20, (kMoreViewCellHeight - imgArrow.size.height) / 2, imgArrow.size.width, imgArrow.size.height);
        [self.contentView addSubview:_indicatorView];
        _indicatorView.hidden = YES;
    }
    return self;
}

+(float)cellHeight
{
    return CELL_HEIGHT;
}

-(void)dealloc
{
     //(_item);
     //(_switcher);
     //(_nameLabel);
}

- (void)setObject:(id)object {
	if (_item == object)
	{
		return;
	}
    //hzbook小说push设置
    if ([object isKindOfClass:[SNBook class]]) {
        SNBook * book = ((SNBook *)object);
        novelBook = book;
        novelBook.bookId = book.bookId;
        _switcher.hidden = NO;
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        //推送总开关状态
        NSString *novelSwitch = [userDefault objectForKey:kReaderPushSet];
        
        if (novelBook.bookId.length > 0) {
            CGRect rect = _nameLabel.frame;
            rect.origin.x = 25;
            _nameLabel.frame = rect;
            _nameLabel.text = book.title;
            BOOL remind = book.remind;
            novelPushSet = YES;
            
            [_switcher setCurrentIndex:remind animated:NO inEvent:NO];
            
            if ([novelSwitch isEqualToString:@"1"]) {
                _switcher.enabel = YES;
                _switcher.userInteractionEnabled = YES;
                //5.9.3 wangchuanwen update
                //_nameLabel.textColor = SNUICOLOR(kThemeText1Color);
                //换成abTest字体色 5.9.3 by wangchuanwen
                _nameLabel.textColor = SNUICOLOR(kThemeTextRIColor);
            } else {
                
                _switcher.enabel = NO;
                _switcher.userInteractionEnabled = NO;
                _nameLabel.textColor = SNUICOLOR(kThemeText3Color);
            }
            
        }else{
            _nameLabel.text = book.title;
            //5.9.3 wangchuanwen update
            //_nameLabel.textColor = SNUICOLOR(kThemeText1Color);
            //换成abTest字体色 5.9.3 by wangchuanwen
            _nameLabel.textColor = SNUICOLOR(kThemeTextRIColor);
            [_switcher setCurrentIndex:[novelSwitch integerValue] animated:NO inEvent:NO];
            novelPushSet = NO;
        }
        
        return;
    }

	self.item=object;
    
    if (self.item) {
        
        novelPushSet = NO;
        //数据缓存失败 iphone7
        if (![_item.pushSettingItem isKindOfClass:[SNPushSettingItem class]]) {
            
            return;
        }
        _nameLabel.text = _item.pushSettingItem.pubName;
        //5.9.3 wangchuanwen update
        //_nameLabel.textColor = SNUICOLOR(kThemeText1Color);
        //换成abTest字体色 5.9.3 by wangchuanwen
        _nameLabel.textColor = SNUICOLOR(kThemeTextRIColor);
        
        if ([_item.pushSettingItem.pubPush isEqualToString:@"pubPush"]) {
            _switcher.hidden = YES;
            _indicatorView.hidden = YES;
        }
        else{
            _switcher.hidden = NO;
            _indicatorView.hidden = YES;
            _switcher.switchName = _item.pushSettingItem.pubName;
            if ([_item.pushSettingItem.pubPush isEqualToString:@"0"]) {
                //状态"关"
                [_switcher setCurrentIndex:0 animated:NO inEvent:NO];
            }else
            {
                //状态"开"
                [_switcher setCurrentIndex:1 animated:NO inEvent:NO];
            }
        }
        if (_item.pushSettingItem.isNovelPushSetting) {
            _indicatorView.hidden = NO;
            self.isNovelPushSetting = YES;
        }
        else if (_item.pushSettingItem.isSNSPushSetting) {
            _indicatorView.hidden = NO;
            self.isSNSPushSetting = YES;
        }
        else {
            _indicatorView.hidden = YES;
            self.isNovelPushSetting = NO;
        }
    }
    
}

- (void)openPushViewWithIndex:(NSInteger)cellIndex{
    if (![_item.pushSettingItem.pubPush isEqualToString:@"pubPush"]){
        return;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:cellIndex forKey:@"kPushAction"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://pushSeting"] applyAnimated:YES] applyQuery:nil];
    [[TTNavigator navigator] openURLAction:urlAction];
}

#pragma -SNPushSwitcherDelegate
- (void)swither:(SNPushSwitcher *)switcher indexDidChanged:(int)newIndex
{
    if (_switcher==switcher&&switcher!=nil) {
        if (novelBook) {//每一本小说推送
            if (novelPushSet) {
                if (novelBook.bookId.length > 0) {
                    [SNBookShelf bookPushEnable:newIndex bookId:novelBook.bookId complete:^(BOOL success) {
                        if (success) {
                            
                            for (SNBook * book in [SNPushSettingModel instance].settingNovels) {
                                if ([book.bookId isEqualToString:novelBook.bookId]) {
                                    book.remind = newIndex;
                                    break;
                                }
                            }
                        }else{
                            
                            [switcher setCurrentIndex:newIndex == 0?1:0 animated:YES];
                            NSString *msg = nil;
                            NSString *str = NSLocalizedString(@"Change push setting failed",@"");
                            NSString *strNet = @"网络不稳定";
                            msg	= [NSString  stringWithFormat:@"%@,%@",strNet,str];
                            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeError];
                        }
                    }];
                }
            } else {//小说推送总开关
                
                [[[SNUserSettingRequest alloc]initWithUserSettingMode:SNUserSettingNovelPushMode andModeString:[NSString stringWithFormat:@"%d",newIndex]]send:^(SNBaseRequest *request, id responseObject) {
                    
                    //小说推送设置
                    [self novelPushSetWithIndex:newIndex];
                    
                } failure:^(SNBaseRequest *request, NSError *error) {
                    [switcher setCurrentIndex:newIndex == 0?1:0 animated:YES];
                    int currIndex = (newIndex == 0?1:0);
                    //小说推送设置
                    [self novelPushSetWithIndex:currIndex];
                    NSString *msg = nil;
                    NSString *str = NSLocalizedString(@"Change push setting failed",@"");
                    NSString *strNet = @"网络不稳定";
                    msg	= [NSString  stringWithFormat:@"%@,%@",strNet,str];
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeError];
                }];
            }
            return;
        }
        //发送网络请求
        SNPushSettingController *controller = self.item.pushSettingController;
        [controller changePushSettingWith:self.item.pushSettingItem switchCtl:switcher];
        
    }
}

#pragma mark 小说推送设置
-(void)novelPushSetWithIndex:(int)index
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if (index == 1) {
        [userDefault setObject:@"1" forKey:kReaderPushSet];
    } else {
        
        [userDefault setObject:@"0" forKey:kReaderPushSet];
    }
    
    [userDefault synchronize];
    [SNNotificationManager postNotificationName:NovelPushSwtichNotification object:nil
    ];
}
@end
